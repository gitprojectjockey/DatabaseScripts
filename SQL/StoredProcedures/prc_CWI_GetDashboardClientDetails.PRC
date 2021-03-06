/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardClientDetails]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetDashboardClientDetails' )
 DROP PROCEDURE [dbo].[prc_CWI_GetDashboardClientDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardClientDetails]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetDashboardClientDetails]
* Purpose : This PROC would be called TO get all the clients of logged user
* Invoked from : Dashboard.aspx
* CREATED: Vijesh Mahi
* CREATED ON : 09 May 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetDashboardClientDetails 7
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetDashboardClientDetails] 
	@inUserId int	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @TBL_DIVISION TABLE (ParentId int)

	INSERT INTO @TBL_DIVISION
	SELECT C.ID FROM CWI_Client C INNER JOIN CWI_ClientTeamRelationship TR ON TR.ClientId=C.ID
	WHERE TR.UserId=@inUserId  AND  ISNULL( C.ParentID,0)=0

	INSERT INTO @TBL_DIVISION
	SELECT C.ParentID FROM CWI_Client C INNER JOIN CWI_ClientTeamRelationship TR ON TR.ClientId=C.ID
	WHERE TR.UserId=@inUserId  AND  ISNULL( C.ParentID,0)<>0

	--SELECT * FROM @TBL_DIVISION

	SELECT DISTINCT
			C.Id as ClientID,			
			C.ClientCode,
			C.ClientName,
			A.AddressLine1+', '+CN.CountryName+', '+ST.StateName+', '+A.City+', '+A.Zip as ClientAddress,
			L1.ID as ClientStatusLookup,
			L1.LookupName as ClientStatus,
			L2.ID as ClientHierarchyType,
			ISNULL( C.ParentID,0) as ParentId,
			L2.LookupName,			
			C.LastStatusModifiedBy,
			C.LastStatusModifiedOn,
			C.CreatedBy,
			C.CreatedOn,
			'3/10/2013' as LastDateInvoiced,
			'12,000.35' as BudgetTotalValue,
			'5,000.00' as BudgetUsedValue,	
			'4,000.00' as BudgetCommitted--,
			,CASE WHEN C.ID = TR.ClientId THEN 'YES' ELSE 'NO' END AS IsAssociated	

	FROM dbo.CWI_Client AS C
			
			INNER JOIN dbo.Lookup L1 ON C.ClientStatusLookupID = L1.ID
			INNER JOIN dbo.Lookup L2 ON C.HierarchyTypeLookupID = L2.ID
			INNER JOIN dbo.CWI_Address A ON	C.AddressID = A.ID
			INNER JOIN dbo.Country CN ON A.CountryID=CN.ID
			INNER JOIN dbo.State ST	ON A.StateID=ST.ID
			LEFT OUTER JOIN dbo.CWI_ClientTeamRelationship TR ON C.ID = TR.ClientId AND TR.UserId=@inUserId					
			INNER JOIN @TBL_DIVISION D ON C.ID=D.ParentId			
			
		WHERE  ISNULL( C.ParentID,0)=0  --AND TR.UserId=@inUserId
		
		
			
END
GO
