/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientSearchChildDetails]    Script Date: 2/27/2014 7:34:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientSearchChildDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientSearchChildDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientSearchChildDetails]    Script Date: 2/27/2014 7:34:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientSearchChildDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetClientSearchChildDetails]
* Purpose : This PROC would be called TO get Client Search
* Invoked from : Client.aspx
* CREATED: Saravanan M
* CREATED ON : 08 Apr 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec dbo.[prc_CWI_GetClientSearchChildDetails] @ClientCode='''',@ClientName='''',@DivisionCode='''',@DivisionName='''',@ClientStatus=''All''
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetClientSearchChildDetails] 
	@ClientCode varchar(max),	
	@ClientName varchar(max),
	@DivisionCode varchar(max),
	@DivisionName varchar(max),
	@ClientStatus varchar(max)
	
AS
BEGIN
	
	SET NOCOUNT ON;

--If user has entered a Division Code / Division Name as Search Criteria 
--as user is looking for division match
IF len(@DivisionCode) > 0 or len(@DivisionName) > 0
BEGIN
		SELECT 
			C.Id as ClientID,			
			C.ClientCode as DivisionCode,
			C.ClientName as DivisionName,
			A.StateName +''/''+A.City as DivisionAddress,
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
				INNER JOIN 	dbo.Lookup L1
			ON  C.ClientStatusLookupID = L1.ID
			INNER JOIN  dbo.Lookup L2
			ON  	C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 	dbo.vw_CWI_Address A
			ON	C.AddressID = A.ID
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID			
 WHERE ISNULL( C.ParentID,0)<>0
  and (
				(
					
					 (
					  C.ClientCode LIKE +''%''+@DivisionCode+''%''
					   AND C.ClientName LIKE +''%''+@DivisionName+''%''
					   )
				)
				 AND  L1.LookupName= CASE WHEN @ClientStatus = ''All'' THEN L1.LookupName ELSE @ClientStatus END
			 ); 
END

ELSE if  len(@ClientCode) > 0 or len(@ClientName) > 0
--User is looking to filter on client, so we need to show all Divisions of the Client 
BEGIN

DECLARE @Parent TABLE
(ParentID int)

Insert into @Parent
SELECT 
			C.Id

	FROM dbo.CWI_Client AS C
				INNER JOIN 	dbo.Lookup L1
			ON  C.ClientStatusLookupID = L1.ID
			INNER JOIN  dbo.Lookup L2
			ON  	C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 	dbo.vw_CWI_Address A
			ON	C.AddressID = A.ID
			
 WHERE
   				(
						C.ClientCode like +''%''+@ClientCode+''%'' 
						AND C.ClientName like +''%''+@ClientName+''%''
					 )
				 AND  L1.LookupName=CASE WHEN @ClientStatus = ''All'' THEN L1.LookupName ELSE @ClientStatus END
		

SELECT 
			C.Id as ClientID,			
			C.ClientCode as DivisionCode,
			C.ClientName as DivisionName,
			A.StateName +''/''+A.City as DivisionAddress,
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
				INNER JOIN 	dbo.Lookup L1
			ON  C.ClientStatusLookupID = L1.ID
			INNER JOIN  dbo.Lookup L2
			ON  	C.HierarchyTypeLookupID = L2.ID
			INNER JOIN 	dbo.vw_CWI_Address A
			ON	C.AddressID = A.ID
			LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID			
 WHERE ISNULL( C.ParentID,0) in (Select ParentID from @Parent)
  and (
				(
					(
						C.ClientCode like +''%''+@DivisionCode+''%'' 
						AND C.ClientName like +''%''+@DivisionName+''%''
					 )
					
				)
				 AND  L1.LookupName=CASE WHEN @ClientStatus = ''All'' THEN L1.LookupName ELSE @ClientStatus END
			 ); 



END

ELSE IF(@ClientStatus =''All'')

	SELECT 
			C.Id as ClientID,			
			C.ClientCode as DivisionCode,
			C.ClientName as DivisionName,
			A.StateName +''/''+A.City as DivisionAddress,
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
			
		WHERE ISNULL( C.ParentID,0)<>0 and ((C.ClientCode like +''%''+@ClientCode+''%'' OR C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%'')); --AND L1.LookupName=@ClientStatus); 
		
	ELSE
	
	SELECT 
			C.Id as ClientID,			
			C.ClientCode as DivisionCode,
			C.ClientName as DivisionName,
			A.StateName +''/''+A.City as DivisionAddress,
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

		WHERE ISNULL( C.ParentID,0)<>0 and (((C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'') 
		AND ( C.ClientCode LIKE +''%''+@DivisionCode+''%'' AND C.ClientName LIKE +''%''+@DivisionName+''%'')) AND  L1.LookupName=@ClientStatus); 
		
END




' 
END
GO


