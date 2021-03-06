-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/6/2014
-- Description:  Stored Procedure to upsert TCHEK Last Process Data Transactions

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_SetLastProcessedTransactionData]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_SetLastProcessedTransactionData]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_SetLastProcessedTransactionData] (
	@TransactionType varchar(50) = NULL,
	@TransactionID varchar(50)  = NULL,
	@AccountNumber varchar(50) = NULL,
	@Company varchar(50) = NULL,
	@LastProcessDate datetime  = NULL,
	@LastProcessedResponseCode int = NULL,
	@LastProcessedMessage varchar(max) = NULL,
	@LastProcessedRecordCount int = null,
    @ErrorMessage varchar(300) OUT
  
) AS

DECLARE 
	
	@ExistingRecord_Count      int  

BEGIN TRY

 set @ExistingRecord_Count = 0;

  SELECT @ExistingRecord_Count = Count(ID)
  FROM [dbo].[RTMC_LastProcessedTransactionData] ltd
  WHERE TransactionType = @TransactionType
  
  IF @ExistingRecord_Count > 0 

		BEGIN
			UPDATE [dbo].[RTMC_LastProcessedTransactionData]
			SET 
				TransactionType = @TransactionType,
				TransactionID = @TransactionID,
				AccountNumber = @AccountNumber,
				Company = @Company,
				LastProcessDate = @LastProcessDate,
				LastProcessedResponseCode = @LastProcessedResponseCode, 
				LastProcessedMessage = @LastProcessedMessage,
				LastProcessedRecordCount = @LastProcessedRecordCount,
				CreatedBy = 'RTMC_TransactionDataDelivery',
				ModifiedDate = getdate()
			WHERE TransactionType = @TransactionType
		END
	ELSE
		BEGIN
			INSERT INTO  [dbo].[RTMC_LastProcessedTransactionData]
				([TransactionType],
				[TransactionID],
				[AccountNumber],
				[Company],
				[LastProcessDate],
				[LastProcessedResponseCode],
				[LastProcessedMessage],
			    [LastProcessedRecordCount],
				[CreatedBy],
				[CreatedDate], 
				[ModifiedDate])
		     VALUES 
				(@TransactionType,
				 @TransactionID,
				 @AccountNumber,
				 @Company,
			 	 @LastProcessDate,
				 @LastProcessedResponseCode,
				 @LastProcessedMessage,
				 @LastProcessedRecordCount,
				 'RTMC_TransactionDataDelivery',
				 getdate(),
				 getdate())
	END

END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH





GO
