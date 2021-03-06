/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyClassificationDetailsByClassificationID]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyClassificationDetailsByClassificationID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCopyClassificationDetailsByClassificationID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyClassificationDetailsByClassificationID]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyClassificationDetailsByClassificationID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_SetCopyClassificationDetailsByClassificationID]  
* Purpose : This PROC would be called to insert(copy) the Budget details from one Classification to another Classification
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************
Declare  @OutClassificationID int=0;
exec prc_CWI_SetCopyClassificationDetailsByClassificationID @ClassificationID=0,@ClassificationLookupID=407,@BudgetMonthID=358,@UserID=8,@OutClassificationID =381
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetCopyClassificationDetailsByClassificationID] 
	@ClassificationID  INT,
	@ClassificationLookupID INT,
	@BudgetMonthID INT,
	@UserID int,
	@OutClassificationID  int Out
AS
BEGIN
DECLARE @DivisionBudgetID int =0,@UpdateClassifficationID int,@ClientBudgetID int=0;

SET @UpdateClassifficationID=(SELECT ID from CWI_BudgetMonthClassification Where ClassificationLookupID=@ClassificationLookupID and BudgetMonthID=@BudgetMonthID );
 SET  @DivisionBudgetID= (Select DivisionBudgetID from CWI_BudgetMonth where ID=@BudgetMonthID);
	 SET @ClientBudgetID=(Select ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetID);

IF( (NOT EXISTS(SELECT ID from CWI_BudgetMonthClassification Where ClassificationLookupID=@ClassificationLookupID and BudgetMonthID=@BudgetMonthID )) AND @OutClassificationID=0)
BEGIN

 INSERT INTO [dbo].[CWI_BudgetMonthClassification]
           ([BudgetMonthID]
           ,[ClassificationLookupID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           --,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
SELECT		@BudgetMonthID
           ,@ClassificationLookupID
           ,[BudgetForecast]
           ,0
           ,0
           --,[BudgetForecast]
           ,@UserID
           ,GETDate()
           ,@UserID
           ,GETDATE()
  FROM [dbo].[CWI_BudgetMonthClassification] WHERE ID=@ClassificationID;

  Set @OutClassificationID=SCOPE_IDENTITY();

 -- IF(@OutClassificationID>0)
  --BEGIN
		 /*Updating BudgetMonth Table */
	
	--EXEC prc_CWI_SetClassificationMonthBudgetHistory 0,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
	--END
	

END
ELSE IF(@ClassificationID=0 and @OutClassificationID>0)
BEGIN

 INSERT INTO [dbo].[CWI_BudgetMonthClassification]
           ([BudgetMonthID]
           ,[ClassificationLookupID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           --,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
SELECT		@BudgetMonthID
           ,@ClassificationLookupID
           ,[BudgetForecast]
           ,0
           ,0
          -- ,BudgetForecast
           ,@UserID
           ,GETDate()
           ,@UserID
           ,GETDATE()
  FROM [dbo].[CWI_BudgetMonthClassification] WHERE ID=@OutClassificationID;

  Set @OutClassificationID=SCOPE_IDENTITY();

 -- IF(@OutClassificationID>0)
 -- BEGIN
	--	 /*Updating BudgetMonth Table */
	
	--EXEC prc_CWI_SetClassificationMonthBudgetHistory 0,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
	--END
	

END
ELSE
BEGIN
BEGIN TRANSACTION
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
	 From CWI_BudgetMonthClassification Where ID=@UpdateClassifficationID;
	  

IF( @OutClassificationID=0 )
BEGIN

 SET @OutClassificationID=@ClassificationID;

END

	 UPDATE [CWI_BudgetMonthClassification]
			SET
				[BudgetMonthID]=@BudgetMonthID,
				[ClassificationLookupID]= @ClassificationLookupID,
				[BudgetForecast]=(select  sum(BudgetForecast) from CWI_BudgetMonthClassification where ID=@OutClassificationID),
				--[BudgetAvailable]=(select  sum(BudgetForecast) from CWI_BudgetMonthClassification where ID=@OutClassificationID)-BudgetUsed+BudgetCommitted,				
				[ModifiedBy]=@UserId,
				[ModifiedOn]=GETDATE()
				--from 
				--@tblSourceClassification TC
			WHERE
				id=@UpdateClassifficationID;

				Set @OutClassificationID=@UpdateClassifficationID;
			--IF(@OutClassificationID>0)
 -- BEGIN
	--	 /*Updating BudgetMonth Table */

	
	--EXEC prc_CWI_SetClassificationMonthBudgetHistory 0,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
	
	--END

IF( @@ROWCOUNT>0 )
		BEGIN

			COMMIT; 

		END
ELSE
		BEGIN
		
			ROLLBACK Transaction;
			SET @OutClassificationID=0;
		END

		

  
END
END

' 
END
GO
