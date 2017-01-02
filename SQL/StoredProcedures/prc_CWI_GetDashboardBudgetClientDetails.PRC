

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardBudgetClientDetails]    Script Date: 6/27/2013 6:26:22 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetDashboardBudgetClientDetails')
DROP PROCEDURE [dbo].[prc_CWI_GetDashboardBudgetClientDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardBudgetClientDetails]    Script Date: 6/27/2013 6:26:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: [prc_CWI_GetDashboardBudgetClientDetails]
* Purpose : This PROC would be called TO get all the clients of logged user
* Invoked from : Dashboard.aspx
* CREATED: Vijesh Mahi
* CREATED ON : 09 May 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetDashboardBudgetClientDetails 7
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetDashboardBudgetClientDetails] 
	@inUserId int	
AS
BEGIN
	
	SET NOCOUNT ON; 

	DECLARE @TBL_DIVISION TABLE (ParentId int)

	INSERT INTO @TBL_DIVISION
	SELECT C.ID FROM CWI_Client C INNER JOIN CWI_ClientTeamRelationship TR ON TR.ClientId=C.ID
	WHERE TR.UserId=@inUserId  AND  ISNULL( C.ParentID,0)=0 AND (TR.RelationshipInActivateDate IS NULL	
	OR TR.RelationshipInActivateDate >= CONVERT(DATE,GETDATE()))
	
	INSERT INTO @TBL_DIVISION
	SELECT C.ParentID FROM CWI_Client C INNER JOIN CWI_ClientTeamRelationship TR ON TR.ClientId=C.ID
	WHERE TR.UserId=@inUserId  AND  ISNULL( C.ParentID,0)<>0 AND (TR.RelationshipInActivateDate IS NULL	
	OR TR.RelationshipInActivateDate >= CONVERT(DATE,GETDATE()))	
		
	SELECT DISTINCT  ISNULL(B.[ID],0) as BudgetId,C.ClientCode,C.ClientName as ClientName,
	C.[ID] as ClientID,ISNULL( C.ParentID,0) as ParentID
	,ISNULL(CAST((select  sum(CWI_DivisionBudget.BudgetForecast) from CWI_DivisionBudget where ClientBudgetID=B.ID)	as decimal(20,2)) ,0.00) as BudgetForecast
	,ISNULL(CAST((select  sum(CWI_DivisionBudget.BudgetUsed)  from CWI_DivisionBudget where ClientBudgetID=B.ID) as decimal(20,2)),0.00) as BudgetUsed
	,ISNULL(CAST((select  sum(CWI_DivisionBudget.BudgetCommitted) from CWI_DivisionBudget where ClientBudgetID=B.ID) as decimal(20,2)),0.00) as BudgetCommitted
	,ISNULL(CAST((select  sum(CWI_DivisionBudget.BudgetAvailable) from CWI_DivisionBudget where ClientBudgetID=B.ID) as decimal(20,2)),0.00) as BudgetAvailable		
	FROM [dbo].CWI_Client AS C
	LEFT OUTER JOIN [dbo].[CWI_ClientBudget] AS B ON C.ID=B.ClientID
	LEFT OUTER JOIN dbo.CWI_ClientTeamRelationship TR ON B.ClientID = TR.ClientId AND TR.UserId=@inUserId					
	INNER JOIN @TBL_DIVISION D ON C.ID=D.ParentId 
	WHERE  ISNULL( C.ParentID,0)=0
	OR GETDATE() BETWEEN B.[BudgetFrom] AND B.[BudgetTo]
			
END


GO

