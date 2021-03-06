/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardClientBudget]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetDashboardClientBudget' )
 DROP PROCEDURE [dbo].[prc_CWI_GetDashboardClientBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardClientBudget]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetDashboardClientBudget 
* Purpose : This PROC would be called to retrieve the client budget details for the logged in user
* Invoked from : Dashboard.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetDashboardClientBudget 7
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetDashboardClientBudget]       
@inUserId int
AS
BEGIN

	BEGIN TRY

		SELECT  B.[ID] as BudgetId,B.BudgetName,B.BudgetFrom,B.BudgetTo
		,C.ClientCode +'-' +C.ClientName as Client,C.ClientCode as ClientCode, C.ClientName as ClientName
		,B.[ClientID],ISNULL(C.ParentID,0) as ParentID
		,B.[BudgetName]
		,ISNULL(CAST(B.[BudgetForecast] as decimal(8,2)) ,00000000.00) as BudgetForecast
		,ISNULL(CAST(B.[BudgetUsed] as decimal(8,2)),00000000.00) as BudgetUsed
		,ISNULL(CAST(B.[BudgetCommitted]as decimal(8,2)),00000000.00) as BudgetCommitted
		,ISNULL(CAST(B.[BudgetAvailable]as decimal(8,2)),00000000.00) as BudgetAvailable		
		FROM [dbo].[CWI_ClientBudget] AS B 
		INNER JOIN [dbo].CWI_Client AS C ON	C.ID=B.ClientID
		INNER JOIN CWI_ClientTeamRelationship TR ON TR.ClientId=C.ID
		WHERE TR.UserId=@inUserId

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO
