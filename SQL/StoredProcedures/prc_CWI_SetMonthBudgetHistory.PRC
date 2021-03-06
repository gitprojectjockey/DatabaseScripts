/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMonthBudgetHistory]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMonthBudgetHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetMonthBudgetHistory]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMonthBudgetHistory]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMonthBudgetHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetMonthBudget  
* Purpose : This PROC would be called to Update the Month budget details , division and client with history
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 
EXEC prc_CWI_SetMonthBudgetHistory

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetMonthBudgetHistory]
	@UserID int,
	@DivisionBudgetID Int,
	@ClientBudgetID int
	AS
BEGIN
	BEGIN
/*history DivisionBudget*/
INSERT INTO 
		[dbo].[CWI_History_DivisionBudget]
           ([ClientBudgetId]
           ,[DivisionBudgetId]
           ,[DivisionID]
           ,[BudgetName]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[BudgetFrom]
           ,[BudgetTo]
           ,[RevisionId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
		   	SELECT 
		 [ClientBudgetID]
	  ,[ID]
      ,[DivisionID]
      ,[BudgetName]
      ,[BudgetForecast]
      ,[BudgetUsed]
	  ,[BudgetCommitted]
      ,[BudgetAvailable]
      ,[BudgetFrom]
      ,[BudgetTo]
      ,[RevisionId]
      ,[CreatedBy]
      ,[CreatedOn]
      ,[ModifiedBy]
      ,[ModifiedOn]
    
  FROM [dbo].[CWI_DivisionBudget] WHERE ID=@DivisionBudgetId ; 

  UPDATE CWI_DivisionBudget SET
		   BudgetForecast=(select sum(BudgetForecast) from CWI_BudgetMonth where DivisionBudgetID=@DivisionBudgetID),
		   --BudgetUsed=(select sum(BudgetUsed) from CWI_BudgetMonth where DivisionBudgetID=@DivisionBudgetID),
		  -- BudgetAvailable=(select sum(BudgetAvailable) from CWI_BudgetMonth where DivisionBudgetID=@DivisionBudgetID),
		   --BudgetCommitted=(select sum(BudgetCommitted) from CWI_BudgetMonth where DivisionBudgetID=@DivisionBudgetID),
		   ModifiedBy=@UserId,
		   ModifiedOn=GETDATE()
		   Where CWI_DivisionBudget.ID=@DivisionBudgetID;

 /*Client Budget History*/
		   INSERT INTO 
		[dbo].[CWI_History_ClientBudget]
           ([ClientBudgetId]
           ,[ClientID]
           ,[BudgetName]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[BudgetFrom]
           ,[BudgetTo]
           ,[RevisionId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
	SELECT [ID]
		  ,[ClientID]
		  ,[BudgetName]
		  ,[BudgetForecast]
		  ,[BudgetUsed]
		  ,[BudgetCommitted]
		  ,[BudgetAvailable]
		  ,[BudgetFrom]
		  ,[BudgetTo]
		  ,[RevisionId]
		  ,[CreatedBy]
		  ,[CreatedOn]
		  ,[ModifiedBy]
		  ,GETDATE()
  FROM [dbo].[CWI_ClientBudget] WHERE ID=@ClientBudgetID;

	UPDATE CWI_ClientBudget SET
			BudgetForecast=(select sum(BudgetForecast) from CWI_DivisionBudget where ClientBudgetID=@ClientBudgetID),
		  -- BudgetUsed=(select sum(BudgetUsed) from CWI_DivisionBudget where ClientBudgetID=@ClientBudgetID),
		   --BudgetAvailable=(select sum(BudgetAvailable) from CWI_DivisionBudget where ClientBudgetID=@ClientBudgetID),
		   --BudgetCommitted=(select sum(BudgetCommitted) from CWI_DivisionBudget where ClientBudgetID=@ClientBudgetID),
		   ModifiedBy=@UserId,
		   ModifiedOn=GETDATE()
		   Where CWI_ClientBudget.ID=@ClientBudgetID; 

END	
END
' 
END
GO
