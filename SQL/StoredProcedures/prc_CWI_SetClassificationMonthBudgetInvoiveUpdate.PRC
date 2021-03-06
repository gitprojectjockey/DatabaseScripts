/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClassificationMonthBudgetInvoiveUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClassificationMonthBudgetInvoiveUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClassificationMonthBudgetInvoiveUpdate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClassificationMonthBudgetInvoiveUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClassificationMonthBudgetInvoiveUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClassificationMonthBudgetInvoiveUpdate  
* Purpose : This PROC would be called to Create, Update the Classification Month budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 
EXEC prc_CWI_SetClassificationMonthBudgetInvoiveUpdate

 **********************************************************************/
Create PROCEDURE [dbo].[prc_CWI_SetClassificationMonthBudgetInvoiveUpdate] 
	@ID int OUT
	,@BudgetMonthID int
	,@ClassificationLookupID int      
    ,@BudgetForecast decimal(18,2)
    ,@BudgetUsed decimal(18,2)
    ,@BudgetCommitted decimal(18,2)
    ,@BudgetAvailable decimal(18,2)
    ,@UserId int
	
    
AS
BEGIN
	

IF( @ID=0 )

BEGIN

  INSERT INTO [dbo].[CWI_BudgetMonthClassification]
				   ([BudgetMonthID]
				   ,[ClassificationLookupID]
				   ,[BudgetForecast]
				   ,[BudgetUsed]
				   ,[BudgetCommitted]
				   ,[BudgetAvailable]
				   ,[CreatedBy]
				   ,[CreatedOn]
				   ,[ModifiedBy]
				   ,[ModifiedOn])
			 VALUES
				   (@BudgetMonthID
				   ,@ClassificationLookupID
				   ,@BudgetForecast
				   ,@BudgetUsed
				   ,@BudgetCommitted
				   ,@BudgetForecast-(@BudgetUsed+@BudgetCommitted)
				   ,@UserId
				   ,GETDATE()
				   ,@UserId
				   ,GETDATE());
				   SET @ID=SCOPE_IDENTITY();
END
	
	ELSE 
	

Begin
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
	 From CWI_BudgetMonthClassification Where ID=@ID;


			UPDATE [CWI_BudgetMonthClassification]
			SET
				[BudgetForecast]=@BudgetForecast,
				[BudgetAvailable]=(@BudgetForecast-(BudgetUsed+BudgetCommitted)),
				--[BudgetUsed]=@BudgetUsed,
				--[BudgetCommitted]=@BudgetCommitted,
				[ModifiedBy]=@UserId,
				[ModifiedOn]=GETDATE()
			WHERE
				ID=@ID;


	
END
END

' 
END
GO
