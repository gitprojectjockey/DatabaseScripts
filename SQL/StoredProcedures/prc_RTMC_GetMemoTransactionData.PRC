-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/11/2014
-- Description:  Stored Procedure to get TCHEK MEMO transaction data

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_GetMemoTransactionData]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_GetMemoTransactionData] 
GO
CREATE PROCEDURE [dbo].[prc_RTMC_GetMemoTransactionData] (
    @ErrorMessage varchar(300) OUT
  
) AS
 
BEGIN TRY
		BEGIN
			SELECT
			 [ID]
			,[AccountNumber]
			,[CompanyNumber]
			,[TransactionID]
			,[AVSAddress]
			,[AVSResult]
			,[AVSZip]
			,[AuthorizationCode]
			,[CardCTS]
			,[CardEntryMode]
			,[CardGroup]
			,[CardLast4]
			,[CardMemo]
			,[ClearingReferenceNumber]
			,[ExceptionIndicator]
			,[MCC]
			,[MerchantCity]
			,[MerchantID]
			,[MerchantName]
			,[MerchantStateProv]
			,[ProcessDate]
			,[ProcessTime]
			,[TCC]
			,[TransactionAmount]
			,[TransactionDate]
			,[TransactionTime]
			,[TransactionType]
			,[MessageSet]
			,[ResponseCode]
			,[CreatedBy]
			,[CreatedDate]
			[LastModifiedDate]
			FROM [RTMC_MemoTransactionDataResponse]
			WHERE Complete = 0
		END
END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH






GO
