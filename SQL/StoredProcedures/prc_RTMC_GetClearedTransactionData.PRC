-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/11/2014
-- Description:  Stored Procedure to get TCHEK CLEARED transaction data

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_GetClearedTransactionData]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_GetClearedTransactionData]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_GetClearedTransactionData] (
    @ErrorMessage varchar(300) OUT
  
) AS
 
BEGIN TRY
		BEGIN
			SELECT
		     [ID]
			,[AccountNumber]
			,[CompanyNumber]
			,[TransactionID]
			,[AuthorizationCode]
			,[CardCTS]
			,[CardEntryMode]
		    ,[CardGroup]
			,[CardLast4]
			,[CardMemo]
			,[CardHolderName]
			,[ClearingReferenceNumber]
			,[ExceptionIndicator]
			,[MCC]
			,[MerchantCity]
			,[MerchantID]
			,[MerchantName]
			,[ProcessDate]
			,[ProcessTime]
			,[TCC]
			,[BillInvoiceAmount]
			,[TransactionAmount]
			,[TransactionDate]
			,[TransactionTime]
			,[MessageSet]
			,[ResponseCode]
			,[CreatedBy]
			,[CreatedDate]
			,[LastModifiedDate]
			FROM [RTMC_ClearedTransactionDataResponse]
			WHERE Complete = 0
		END
END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH







GO
