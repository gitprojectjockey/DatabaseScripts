/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientGeneralInfo]    Script Date: 9/22/2014 4:16:53 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientGeneralInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientGeneralInfo]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientGeneralInfo]    Script Date: 9/22/2014 4:16:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientGeneralInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientGeneralInfo
* Purpose : This PROC would be called TO get Client General Information (from Client General Tab)
* Invoked from : Client.aspx
* CREATED: Ajay Thacker
* CREATED ON : 1Mar2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
 28/08/2014 Vijesh		Modified for retrieving general information for corporate           
 18/09/2014 Vijesh		Included corporate name in result list 
 22/09/2014 Vijesh		For checking Isremoved column as false in cwi_clientassociation table
**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetClientGeneralInfo @inClientID=13957
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientGeneralInfo]    
    @inClientID int	
AS
BEGIN
	BEGIN TRY

	declare @heirarchyLookupId int,@BudgetForecast money,@BudgetUsed money
	select @heirarchyLookupId=(select HierarchyTypeLookupID from CWI_Client where id=@inClientID)

	declare @corporate varchar(max),@corporateId int=null
	if @heirarchyLookupId=521 ---heirarchy type look 521 is for Client
	begin	
		if exists(select ClientId from CWI_ClientAssociation where ClientId=@inClientID and IsRemoved=0)
		begin
			select @corporateId=Id, @corporate = ClientCode+'' - ''+ClientName from CWI_Client 
			where Id=(select CoporateId from CWI_ClientAssociation where ClientId=@inClientID and IsRemoved=0)
		end
		else
		begin
			select @corporateId=null, @corporate = ''''
		end				
	end
	else
	begin
		select @corporateId=null, @corporate = ''''
	end

	
	select 	@BudgetForecast=SUM(ISNULL(BudgetForecast,0)), 			
			@BudgetUsed=SUM(ISNULL(BudgetUsed,0))			
			from CWI_ClientBudget CB
			INNER JOIN CWI_Client C
			ON C.Id = CB.ClientID
			AND C.ParentID =@inClientID
			WHERE
			CAST(getdate() as date) between BudgetFrom AND BudgetTo				
					

	if @heirarchyLookupId = 523 -- 523 is lookup id for corporate
	begin
		SELECT 		
			C.Id as ClientID,
			C.ClientCode,
			C.ClientName,
			A.AddressLine1,
			isnull(A.AddressLine2,'''') AddressLine2,
			A.CountryID,
			A.StateID,
			A.City,
			A.Zip,
			dbo.fnc_FormatRemovalPhone(A.WorkPhone,default) as WorkPhone,
			isnull(A.WorkExtn,'''') as WorkExtn,
			dbo.fnc_FormatRemovalPhone(A.WorkFax,default) as WorkFax,
			C.ClientStatusLookupID as ClientStatusLookup,
			C.HierarchyTypeLookupID as ClientHierarchyType,
			case when c.LastStatusModifiedBy is not null then			
				u2.Names + '' ('' + FORMAT(C.[LastStatusModifiedOn], ''MM/dd/yy hh:mm tt'') + '')''
				else '''' 
			end as LastStatusModified,
			U.Names + '' ('' + FORMAT(C.CreatedOn, ''MM/dd/yy hh:mm tt'') + '')'' as Created,
			ISNULL(FORMAT( LastInvoicedDate, ''MM/dd/yyyy'' ),''Not invoiced yet'') as LastDateInvoiced,
			FORMAT(ISNULL(@BudgetForecast,0), ''C'', ''en-us'')  as OrgBudgetValue,
			FORMAT(ISNULL(@BudgetUsed,0), ''C'', ''en-us'') as OrgBudgetUsedValue,
			case when CA.ID is not null then
				''Activation Requested by '' 
					+ u3.Names + '' ('' + FORMAT(CA.ActivationRequestedOn, ''MM/dd/yy hh:mm tt'')  + '')''
			else ''''
			end as ActivationRequest,
			isnull(@corporate,'''') as Corporate,
			isnull(@corporateId,0) as CorporateId

		FROM dbo.CWI_Client AS C
			INNER JOIN dbo.CWI_Address AS A
				ON C.AddressID=A.Id			
			inner join CWI_User U
				ON U.Id = C.CreatedBy
			left join CWI_ClientActivation CA
				ON CA.ClientID = C.ID
			left join CWI_User U2
				on U2.ID = C.LastStatusModifiedBy
			left join CWI_User U3
				on U3.ID = CA.ActivationRequestedBy	

		WHERE C.ID = @inClientID

	end
	else
	begin
		
		SELECT 
			C.Id as ClientID,
			C.ClientCode,
			C.ClientName,
			A.AddressLine1,
			isnull(A.AddressLine2,'''') AddressLine2,
			A.CountryID,
			A.StateID,
			A.City,
			A.Zip,
			dbo.fnc_FormatRemovalPhone(A.WorkPhone,default) as WorkPhone,
			isnull(A.WorkExtn,'''') as WorkExtn,
			dbo.fnc_FormatRemovalPhone(A.WorkFax,default) as WorkFax,
			C.ClientStatusLookupID as ClientStatusLookup,
			C.HierarchyTypeLookupID as ClientHierarchyType,
			case when c.LastStatusModifiedBy is not null then
				u2.Names + '' ('' + FORMAT(C.[LastStatusModifiedOn], ''MM/dd/yy hh:mm tt'') + '')''
				else '''' 
			end as LastStatusModified,
			U.Names + '' ('' + FORMAT(C.CreatedOn, ''MM/dd/yy hh:mm tt'') + '')'' as Created,
			ISNULL(FORMAT( LastInvoicedDate, ''MM/dd/yyyy'' ),''Not invoiced yet'') as LastDateInvoiced,
			FORMAT(ISNULL(B.BudgetForecast,0), ''C'', ''en-us'')  as OrgBudgetValue,
			FORMAT(ISNULL(B.BudgetUsed,0), ''C'', ''en-us'') as OrgBudgetUsedValue,
			case when CA.ID is not null then
				''Activation Requested by '' 
					+ u3.Names + '' ('' + FORMAT(CA.ActivationRequestedOn, ''MM/dd/yy hh:mm tt'')  + '')''
			else ''''
			end as ActivationRequest,
			isnull(@corporate,'''') as Corporate,
			isnull(@corporateId,0) as CorporateId

		FROM dbo.CWI_Client AS C
			INNER JOIN dbo.CWI_Address AS A
				ON C.AddressID=A.Id			
			inner join CWI_User U
				ON U.Id = C.CreatedBy
			left join CWI_ClientActivation CA
				ON CA.ClientID = C.ID
			left join CWI_User U2
				on U2.ID = C.LastStatusModifiedBy
			left join CWI_User U3
				on U3.ID = CA.ActivationRequestedBy
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID
		WHERE C.ID = @inClientID

	end
		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END



' 
END
GO
