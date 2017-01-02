

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardBudgetDivisionDetails]    Script Date: 6/27/2013 6:26:49 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetDashboardBudgetDivisionDetails')
DROP PROCEDURE [dbo].[prc_CWI_GetDashboardBudgetDivisionDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardBudgetDivisionDetails]    Script Date: 6/27/2013 6:26:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: [prc_CWI_GetDashboardBudgetDivisionDetails]
* Purpose : This PROC would be called TO get all the division details of the logged in user
* Invoked from : Dashboard.aspx
* CREATED: Vijesh Mahi
* CREATED ON : 09 May 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetDashboardBudgetDivisionDetails 7
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetDashboardBudgetDivisionDetails] 
	@inUserId int
AS
BEGIN
	
	SET NOCOUNT ON;	

	DECLARE @TBL_DIVISION TABLE (ParentId int)

	INSERT INTO @TBL_DIVISION
	SELECT C.ID FROM CWI_Client C INNER JOIN CWI_ClientTeamRelationship TR ON TR.ClientId=C.ID
	WHERE TR.UserId=@inUserId  AND  ISNULL( C.ParentID,0)<>0 AND (TR.RelationshipInActivateDate IS NULL
	OR TR.RelationshipInActivateDate >= CONVERT(DATE,GETDATE()))

	INSERT INTO @TBL_DIVISION
	SELECT C.ParentID FROM CWI_Client C INNER JOIN CWI_ClientTeamRelationship TR ON TR.ClientId=C.ID
	WHERE TR.UserId=@inUserId  AND  ISNULL( C.ParentID,0)<>0 AND (TR.RelationshipInActivateDate IS NULL
	OR TR.RelationshipInActivateDate >= CONVERT(DATE,GETDATE()))
	--SELECT * FROM @TBL_DIVISION

	SELECT DISTINCT  ISNULL(B.[ID],0) as BudgetId,C.ClientCode as DivisionCode,C.ClientName as DivisionName,
	C.[ID] as ClientID,ISNULL( C.ParentID,0) as ParentID
	--,B.[BudgetForecast],B.[BudgetUsed],B.[BudgetCommitted],B.[BudgetAvailable]
	,ISNULL(CAST(B.[BudgetForecast] as decimal(20,2)) ,0.00) as BudgetForecast
	,ISNULL(CAST(B.[BudgetUsed] as decimal(20,2)),0.00) as BudgetUsed
	,ISNULL(CAST(B.[BudgetCommitted]as decimal(20,2)),0.00) as BudgetCommitted
	,ISNULL(CAST(B.[BudgetAvailable]as decimal(20,2)),0.00) as BudgetAvailable			
	FROM [dbo].CWI_Client AS C
	LEFT OUTER JOIN [dbo].[CWI_DivisionBudget] AS B ON C.ID=B.DivisionID 
	LEFT OUTER JOIN dbo.CWI_ClientTeamRelationship TR ON  C.ID = TR.ClientId AND TR.UserId=@inUserId					
	INNER JOIN @TBL_DIVISION D ON D.ParentId = C.ParentID 
	WHERE  ISNULL( C.ParentID,0)<>0	
	----AND (C.ID = TR.ClientId AND TR.UserId=@inUserId)
	OR GETDATE() BETWEEN B.[BudgetFrom] AND B.[BudgetTo]
	

END



GO

