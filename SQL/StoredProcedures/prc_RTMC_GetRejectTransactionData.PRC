------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/11/2014
-- Description:  Stored Procedure to get TCHEK REJECT transaction data

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_GetRejectTransactionData]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_GetRejectTransactionData] 
GO

CREATE PROCEDURE [dbo].[prc_RTMC_GetRejectTransactionData] (
    @ErrorMessage varchar(300) OUT
  
) AS
 
BEGIN TRY
		BEGIN
			SELECT
			 [ID]
			,[AccountNumber]
			,[CompanyNumber]
			,[TransactionID]
			,[CardCTS]
			,[CardGroup]
			,[CardLast4]
			,[CardMemo]
			,[CardHolderName]
			,[MCC]
			,[MerchantCity]
			,[MerchantCountry]
			,[MerchantName]
			,[MerchantStateProv]
			,[MerchantZip]
			,[ProcessDate]
			,[ProcessTime]
			,[ReasonCode]
			,[ReasonSubCode]
			,[RejectMessage]
			,[RejectCode]
			,[TCC]
			,[TransactionAmount]
			,[TransactionDate]
			,[TransactionTime]
			,[MessageSet]
			,[ResponseCode]
			,[CreatedBy]
			,[CreatedDate]
			,[LastModifiedDate]
			FROM [RTMC_RejectTransactionDataResponse]
			WHERE Complete = 0
		END
END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH


GO
