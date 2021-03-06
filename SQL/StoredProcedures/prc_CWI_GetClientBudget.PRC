/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientBudget]    Script Date: 7/24/2014 8:36:03 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientBudget]    Script Date: 7/24/2014 8:36:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientBudget  
* Purpose : This PROC would be called to get the client budget details with organization budget
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetClientBudget] @ClientId=15508, BudgetID
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetClientBudget] 
	@ClientId int=null,
	@BudgetId Int=null
AS
BEGIN

IF( ISNULL(@ClientId,0)>0 AND ISNULL(@BudgetId,0)=0)
BEGIN

 SELECT TOP 1 [CWI_ClientBudget].[ID] as BudgetId
		,CWI_Client.ClientName
		,[CWI_ClientBudget].[ClientID]
		,[CWI_ClientBudget].[BudgetName]
		,ISNULL(CAST( ([BudgetForecast]) as decimal(20,2)) ,0.00) as BudgetForecast
		,ISNULL(CAST( (BudgetUsed) as decimal(20,2)),0.00) as BudgetUsed
		,ISNULL(CAST((BudgetCommitted) as decimal(20,2)),0.00) as BudgetCommitted
		,ISNULL(CAST((BudgetAvailable)as decimal(20,2)),0.00) as BudgetAvailable
		,ISNULL(CAST((SalesForecast)as decimal(20,2)),0.00) as SalesForecast
		,CONVERT(varchar(07), [CWI_ClientBudget].[BudgetFrom],111) as [BudgetFrom]
		,CONVERT(varchar(07), [CWI_ClientBudget].[BudgetTo],111) as [BudgetTo]
		,[CWI_ClientBudget].[RevisionId]
		,[CWI_ClientBudget].[CreatedBy]
		,[CWI_ClientBudget].[CreatedOn]
		,[CWI_ClientBudget].[ModifiedBy]
		,[CWI_ClientBudget].[ModifiedOn]
  FROM 
	[dbo].[CWI_ClientBudget] 
  Inner JOIN
	[dbo].CWI_Client
	ON
		CWI_Client.ID=CWI_ClientBudget.ClientID
		
  WHERE ClientID=@ClientId ORDER BY [CWI_ClientBudget].ID DESC
	--GETDATE() BETWEEN [CWI_ClientBudget].[BudgetFrom] AND [CWI_ClientBudget].[BudgetTo] AND ClientID=@ClientId ;

END
else		
BEGIN

 SELECT  [CWI_ClientBudget].[ID] as BudgetId
		,CWI_Client.ClientName
		,[CWI_ClientBudget].[ClientID]
		,[CWI_ClientBudget].[BudgetName]
		,ISNULL(CAST( ([BudgetForecast]) as decimal(20,2)) ,0.00) as BudgetForecast
		,ISNULL(CAST( (BudgetUsed) as decimal(20,2)),0.00) as BudgetUsed
		,ISNULL(CAST((BudgetCommitted) as decimal(20,2)),0.00) as BudgetCommitted
		,ISNULL(CAST((BudgetAvailable)as decimal(20,2)),0.00) as BudgetAvailable
		,ISNULL(CAST((SalesForecast)as decimal(20,2)),0.00) as SalesForecast
		,CONVERT(varchar(07), [CWI_ClientBudget].[BudgetFrom],111) as [BudgetFrom]
		,CONVERT(varchar(07), [CWI_ClientBudget].[BudgetTo],111) as [BudgetTo]
		,[CWI_ClientBudget].[RevisionId]
		,[CWI_ClientBudget].[CreatedBy]
		,[CWI_ClientBudget].[CreatedOn]
		,[CWI_ClientBudget].[ModifiedBy]
		,[CWI_ClientBudget].[ModifiedOn]
  FROM 
	[dbo].[CWI_ClientBudget] 
  Inner JOIN
	[dbo].CWI_Client
	ON
		CWI_Client.ID=CWI_ClientBudget.ClientID
		
  WHERE [CWI_ClientBudget].ID=@BudgetId ORDER BY [CWI_ClientBudget].ID DESC
	

END
	
END
' 
END
GO
