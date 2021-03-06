IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientSearchParentDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientSearchParentDetails]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientSearchParentDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetClientSearchParentDetails]
* Purpose : This PROC would be called TO get Client Search
* Invoked from : Client.aspx
* CREATED: Saravanan M
* CREATED ON : 08 Apr 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example fnc_GetClientsForUser	
**********************************************************************  

exec dbo.prc_CWI_GetClientSearchParentDetails @ClientCode='''',@ClientName='''',@DivisionCode='''',@DivisionName='''',@ClientStatus=''All'', @UserId = 3

**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetClientSearchParentDetails] 
	@ClientCode varchar(max),	
	@ClientName varchar(max),
	@DivisionCode varchar(max),
	@DivisionName varchar(max),
	@ClientStatus varchar(max),
	@UserId	int = 0
	
AS
BEGIN
	
	SET NOCOUNT ON;

	
IF ISNULL(@UserId,0) <> 0
BEGIN
IF(@ClientStatus =''All'')

	SELECT 
			C.Id as ClientID,			
			C.ClientCode,
			C.ClientName,
			A.StateName +''/''+A.City  as ClientAddress,
			L1.ID as ClientStatusLookup,
			L1.LookupName as ClientStatus,
			L2.ID as ClientHierarchyType,
			ISNULL( C.ParentID,0) as ParentId,
			L2.LookupName,			
			C.LastStatusModifiedBy,
			C.LastStatusModifiedOn,
			C.CreatedBy,
			C.CreatedOn,
			ISNULL( convert(varchar(20),C.LastInvoicedDate,101) , '''') as LastDateInvoiced,
			ISNULL(BudgetForecast,0) as	BudgetForecast, 
			ISNULL(BudgetAvailable,0) as BudgetTotalValue,
			ISNULL(BudgetUsed,0) as BudgetUsedValue,	
			ISNULL(BudgetCommitted,0) as BudgetCommitted		
			
	FROM dbo.CWI_Client AS C
			INNER JOIN dbo.fnc_GetClientsForUser(@UserId, ''C'') UC
				ON UC.ClientId = C.ID
			INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 
				dbo.vw_CWI_Address A
			ON
				C.AddressID = A.ID
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID
			
		WHERE C.ParentID IS NULL and ((C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%'')); --AND L1.LookupName=@ClientStatus); 
		
	ELSE
	
	SELECT 
			C.Id as ClientID,			
			C.ClientCode,
			C.ClientName,
			A.StateName+''/''+A.City  as ClientAddress,
			L1.ID as ClientStatusLookup,
			L1.LookupName as ClientStatus,
			L2.ID as ClientHierarchyType,
			ISNULL( C.ParentID,0) as ParentId,
			L2.LookupName,
			C.LastStatusModifiedBy,
			C.LastStatusModifiedOn,
			C.CreatedBy,
			C.CreatedOn,
			ISNULL( convert(varchar(20),C.LastInvoicedDate,101) , '''') as LastDateInvoiced,
			ISNULL(BudgetForecast,0) as	BudgetForecast, 
			ISNULL(BudgetAvailable,0) as BudgetTotalValue,
			ISNULL(BudgetUsed,0) as BudgetUsedValue,	
			ISNULL(BudgetCommitted,0) as BudgetCommitted	
			

	FROM dbo.CWI_Client AS C
			INNER JOIN dbo.fnc_GetClientsForUser(@UserId, ''C'') UC
				ON UC.ClientId = C.ID
			INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 
				dbo.vw_CWI_Address A
			ON
				C.AddressID = A.ID
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID			
		WHERE C.ParentID IS NULL and (((C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%'')) AND  L1.LookupName=@ClientStatus); 

END
ELSE
BEGIN
IF len(@DivisionCode) > 0 or len(@DivisionName) > 0
begin
IF(@ClientStatus =''All'')

	SELECT 
			C.Id as ClientID,			
			C.ClientCode,
			C.ClientName,
			A.StateName +''/''+A.City  as ClientAddress,
			L1.ID as ClientStatusLookup,
			L1.LookupName as ClientStatus,
			L2.ID as ClientHierarchyType,
			ISNULL( C.ParentID,0) as ParentId,
			L2.LookupName,			
			C.LastStatusModifiedBy,
			C.LastStatusModifiedOn,
			C.CreatedBy,
			C.CreatedOn,
			ISNULL( convert(varchar(20),C.LastInvoicedDate,101) , '''') as LastDateInvoiced,
			ISNULL(BudgetForecast,0) as	BudgetForecast, 
			ISNULL(BudgetAvailable,0) as BudgetTotalValue,
			ISNULL(BudgetUsed,0) as BudgetUsedValue,	
			ISNULL(BudgetCommitted,0) as BudgetCommitted	
		

	FROM dbo.CWI_Client AS C
			
			INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 
				dbo.vw_CWI_Address A
			ON
				C.AddressID = A.ID
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID
			
		WHERE 
		(
		C.ParentID IS NULL and ((C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%''))
		)
		OR
		(  C.Id in 
			(
			SELECT 
			C.ParentID		

	FROM dbo.CWI_Client AS C
			
			INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 
				dbo.vw_CWI_Address A
			ON
				C.AddressID = A.ID
			
		WHERE 
		C.ParentID IS NOT NULL and ((C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%''))
		))
		
	ELSE
	
	SELECT 
			C.Id as ClientID,			
			C.ClientCode,
			C.ClientName,
			A.StateName+''/''+A.City  as ClientAddress,
			L1.ID as ClientStatusLookup,
			L1.LookupName as ClientStatus,
			L2.ID as ClientHierarchyType,
			ISNULL( C.ParentID,0) as ParentId,
			L2.LookupName,
			C.LastStatusModifiedBy,
			C.LastStatusModifiedOn,
			C.CreatedBy,
			C.CreatedOn,
			ISNULL( convert(varchar(20),C.LastInvoicedDate,101) , '''') as LastDateInvoiced,
			ISNULL(BudgetForecast,0) as	BudgetForecast, 
			ISNULL(BudgetAvailable,0) as BudgetTotalValue,
			ISNULL(BudgetUsed,0) as BudgetUsedValue,	
			ISNULL(BudgetCommitted,0) as BudgetCommitted			

	FROM dbo.CWI_Client AS C
			
			INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 
				dbo.vw_CWI_Address A
			ON
				C.AddressID = A.ID
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID			
		WHERE 
		(
		C.ParentID IS NULL and (((C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%'')) AND  L1.LookupName=@ClientStatus)
		)
		OR
		(  C.Id in 
			(
			SELECT 
			C.ParentID		

	FROM dbo.CWI_Client AS C
			
			INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 
				dbo.vw_CWI_Address A
			ON
				C.AddressID = A.ID
			
		WHERE 
		C.ParentID IS NOT NULL and ( ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%'')) AND  L1.LookupName=@ClientStatus
		)) 
end
else
begin		
IF(@ClientStatus =''All'')

	SELECT 
			C.Id as ClientID,			
			C.ClientCode,
			C.ClientName,
			A.StateName +''/''+A.City  as ClientAddress,
			L1.ID as ClientStatusLookup,
			L1.LookupName as ClientStatus,
			L2.ID as ClientHierarchyType,
			ISNULL( C.ParentID,0) as ParentId,
			L2.LookupName,			
			C.LastStatusModifiedBy,
			C.LastStatusModifiedOn,
			C.CreatedBy,
			C.CreatedOn,
			ISNULL( convert(varchar(20),C.LastInvoicedDate,101) , '''') as LastDateInvoiced,
			ISNULL(BudgetForecast,0) as	BudgetForecast, 
			ISNULL(BudgetAvailable,0) as BudgetTotalValue,
			ISNULL(BudgetUsed,0) as BudgetUsedValue,	
			ISNULL(BudgetCommitted,0) as BudgetCommitted		

	FROM dbo.CWI_Client AS C
			INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 
				dbo.vw_CWI_Address A
			ON
				C.AddressID = A.ID
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID			
		WHERE 
		C.ParentID IS NULL and ((C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%'')); --AND L1.LookupName=@ClientStatus); 
		
		
		
	ELSE
	
	SELECT 
			C.Id as ClientID,			
			C.ClientCode,
			C.ClientName,
			A.StateName+''/''+A.City  as ClientAddress,
			L1.ID as ClientStatusLookup,
			L1.LookupName as ClientStatus,
			L2.ID as ClientHierarchyType,
			ISNULL( C.ParentID,0) as ParentId,
			L2.LookupName,
			C.LastStatusModifiedBy,
			C.LastStatusModifiedOn,
			C.CreatedBy,
			C.CreatedOn,
			ISNULL( convert(varchar(20),C.LastInvoicedDate,101) , '''') as LastDateInvoiced,
			ISNULL(BudgetForecast,0) as	BudgetForecast, 
			ISNULL(BudgetAvailable,0) as BudgetTotalValue,
			ISNULL(BudgetUsed,0) as BudgetUsedValue,	
			ISNULL(BudgetCommitted,0) as BudgetCommitted				

	FROM dbo.CWI_Client AS C
			INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 
				dbo.vw_CWI_Address A
			ON
				C.AddressID = A.ID
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID			
		WHERE C.ParentID IS NULL and (((C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%'')) AND  L1.LookupName=@ClientStatus); 

end
END
END


' 
END
GO


