/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorBudgetUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorBudgetUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorBudgetUpdate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorBudgetUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorBudgetUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_SetVendorBudgetUpdate]  
* Purpose : This PROC would be called to Create, Update the Vendor budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_SetVendorBudgetUpdate]

**********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetVendorBudgetUpdate] 
	--@BudgetForecast money,
	@BudgetMonthClassificationID int,
	@BudgetMonthID int,
	@DivisionBudgetID int,
	@ClientBudgetID int,
	@UserId int
AS
BEGIN

			/*History class*/
	INSERT INTO [dbo].[CWI_History_BudgetMonthClassification]
           ([BudgetMonthClassificationID]
           ,[BudgetMonthID]
           ,[ClassificationLookupID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
     
	 SELECT [ID],
			[BudgetMonthID]
           ,[ClassificationLookupID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
	 From CWI_BudgetMonthClassification Where ID=@BudgetMonthClassificationID;
	
			   /*Updating CWI_BudgetMonthClassification Table */
	UPDATE CWI_BudgetMonthClassification SET 
				BudgetForecast=(Select sum(BudgetForecast) From CWI_BudgetMonthClassVendor WHERE BudgetMonthClassificationID =@BudgetMonthClassificationID),
				BudgetAvailable = (Select sum(BudgetForecast-( BudgetUsed + BudgetCommitted)) From CWI_BudgetMonthClassVendor WHERE BudgetMonthClassificationID=@BudgetMonthClassificationID),
				BudgetUsed=(Select sum(BudgetUsed) From CWI_BudgetMonthClassVendor WHERE BudgetMonthClassificationID=@BudgetMonthClassificationID),
				BudgetCommitted=(Select sum(BudgetCommitted) From CWI_BudgetMonthClassVendor WHERE BudgetMonthClassificationID=@BudgetMonthClassificationID),
				ModifiedBy=@UserId,ModifiedOn=GETDATE()	 
	 WHERE ID=@BudgetMonthClassificationID;

				/*Updating BudgetMonth Table and History */			
		
	INSERT INTO [dbo].[CWI_History_BudgetMonth]
           ([BudgetMonthId]
           ,[DivisionBudgetID]
           ,[Month]
           ,[Year]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
		   SELECT [ID]
		   ,[DivisionBudgetID]
           ,[Month]
           ,[Year]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
		   FROM CWI_BudgetMonth WHERE ID=@BudgetMonthID;
		 
				UPDATE CWI_BudgetMonth SET 
				BudgetUsed = (Select sum(BudgetUsed ) From CWI_BudgetMonthClassification WHERE BudgetMonthID=@BudgetMonthID),
				BudgetForecast = (Select sum(BudgetForecast ) From CWI_BudgetMonthClassification WHERE BudgetMonthID=@BudgetMonthID),
				BudgetCommitted = (Select sum(BudgetCommitted ) From CWI_BudgetMonthClassification WHERE BudgetMonthID=@BudgetMonthID),
				BudgetAvailable = (Select sum(BudgetForecast-( BudgetUsed + BudgetCommitted)) From CWI_BudgetMonthClassification WHERE BudgetMonthID=@BudgetMonthID),
				ModifiedBy=@UserId,ModifiedOn=GETDATE()				 
	WHERE ID=@BudgetMonthID;
				    /*---------------------------------------------------------------------*/

				 /*Updating Division Budget Table */
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
    
	FROM [dbo].[CWI_DivisionBudget] WHERE ID=@DivisionBudgetID;

	UPDATE CWI_DivisionBudget SET
			BudgetForecast=(select sum(BudgetForecast) from CWI_BudgetMonth where ID=@BudgetMonthID and DivisionBudgetID=@DivisionBudgetID),
			BudgetUsed=(select sum(BudgetUsed) from CWI_BudgetMonth where ID=@BudgetMonthID and DivisionBudgetID=@DivisionBudgetID),
			BudgetAvailable=(select sum(BudgetForecast-( BudgetUsed + BudgetCommitted)) from CWI_BudgetMonth where ID=@BudgetMonthID and DivisionBudgetID=@DivisionBudgetID),
			BudgetCommitted=(select sum(BudgetCommitted) from CWI_BudgetMonth where ID=@BudgetMonthID and DivisionBudgetID=@DivisionBudgetID),
			ModifiedBy=@UserId,ModifiedOn=GETDATE()
	WHERE CWI_DivisionBudget.ID=@DivisionBudgetID;	
			   
			   /*Client Budget*/	 
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
		BudgetUsed=(select sum(BudgetUsed) from CWI_DivisionBudget where ClientBudgetID=@ClientBudgetID),
		BudgetAvailable=(select sum(BudgetForecast-( BudgetUsed + BudgetCommitted)) from CWI_DivisionBudget where ClientBudgetID=@ClientBudgetID),
		BudgetCommitted=(select sum(BudgetCommitted) from CWI_DivisionBudget where ClientBudgetID=@ClientBudgetID),
		ModifiedBy=@UserId,
		ModifiedOn=GETDATE()
Where CWI_ClientBudget.ID=@ClientBudgetID;
  
				   
			   END
' 
END
GO
