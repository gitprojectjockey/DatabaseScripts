/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorporateSearchDetails]    Script Date: 8/28/2014 9:55:08 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorporateSearchDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorporateSearchDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorporateSearchDetails]    Script Date: 8/28/2014 9:55:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorporateSearchDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: [prc_CWI_GetCorporateSearchDetails]
* Purpose : This PROC would be called TO bind Corporate grid 
* Invoked from : Client.aspx
* CREATED: Vijesh Mahi
* CREATED ON : 26 Aug 2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

********************************************************************** 
exec dbo.prc_CWI_GetCorporateSearchDetails 
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetCorporateSearchDetails] 
	
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT 
				C.Id as CorporateID,			
				C.ClientCode as CorporateCode,
				C.ClientName as CorporateName,
				A.StateName +''/''+A.City  as CorporateAddress,
				L1.ID as ClientStatusLookup,
				L1.LookupName as CorporateStatus,
				L2.ID as ClientHierarchyType,
				ISNULL( C.ParentID,0) as ParentId,
				L2.LookupName,			
				C.LastStatusModifiedBy,
				C.LastStatusModifiedOn,
				C.CreatedBy,
				C.CreatedOn,
				ISNULL( convert(varchar(20),C.LastInvoicedDate,101) , '''') as LastDateInvoiced,
				ISNULL(B.BudgetForecast,0) as BudgetForecast,
				ISNULL(B.BudgetTotalValue,0) as BudgetTotalValue,
				ISNULL(B.BudgetUsedValue,0) as BudgetUsedValue,
				ISNULL(B.BudgetCommitted,0) as BudgetCommitted
			
		FROM 
				dbo.CWI_Client AS C
			
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
				--LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON 
				--B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID
				LEFT OUTER JOIN (select 
					C.ParentID,
					SUM(ISNULL(BudgetForecast,0)) as BudgetForecast, 
					SUM(ISNULL(BudgetAvailable,0)) as BudgetTotalValue,
					SUM(ISNULL(BudgetUsed,0)) as BudgetUsedValue,	
					SUM(ISNULL(BudgetCommitted,0)) as BudgetCommitted
					from 
					CWI_ClientBudget CB
					INNER JOIN CWI_Client C
					ON C.Id = CB.ClientID
					AND C.ParentID IS NOT NULL
					WHERE
					CAST(getdate() as date) between BudgetFrom AND BudgetTo
					GROUP BY C.ParentID
					)B ON B.ParentID=C.ID 
		WHERE 
				C.HierarchyTypeLookupID=523 ---523 IS CORPORATE LOOKUP


	SET NOCOUNT OFF;

END	




	



' 
END
GO
