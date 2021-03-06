-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/6/2014
-- Description:  Stored Procedure to upsert CLEARED TCHEK Data Transactions

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_SetClearedTransactionDataResponse]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_SetClearedTransactionDataResponse]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_SetClearedTransactionDataResponse] (
	@AccountNumber varchar(50) =NULL,
	@CompanyNumber varchar(50),
	@TransactionID varchar(50),
	@AuthorizationCode varchar(50) =NULL,
	@CardCTS varchar(20),
	@CardEntryMode varchar(5),
	@CardGroup varchar(50) =NULL,
	@CardLast4 varchar(10),
	@CardMemo varchar(50) =NULL,
	@CardHolderName varchar(50) =NULL,
	@ClearingReferenceNumber varchar(50) =NULL,
	@ExceptionIndicator varchar(5),
	@MCC varchar(10),
	@MerchantCity varchar(50),
	@MerchantID varchar(50),
	@MerchantName varchar(max),
	@ProcessDate varchar(10),
	@ProcessTime varchar(10),
	@TCC varchar(5),
	@BillInvoiceAmount decimal(12, 2),
	@TransactionAmount decimal(12, 2),
	@TransactionDate varchar(10),
	@TransactionTime varchar(10),
	@MessageSet varchar(max),
	@ResponseCode int,
	@BillingCurrency varchar(5) = NULL,
	@Fee1 decimal(5, 2) = NULL,
	@Fee2 decimal(12, 2) = NULL,
	@RecordType varchar(5) = NULL,
	@ExchangeRate decimal(12,6) = NULL,
    @ErrorMessage varchar(300) OUT
  
  
) AS
DECLARE 
	
	@ExistingRecord_Count      int  

BEGIN TRY

  set @ExistingRecord_Count = 0;

  SELECT @ExistingRecord_Count = Count(ID)
  FROM [dbo].[RTMC_ClearedTransactionDataResponse] tdr
  WHERE tdr.CardCTS = @CardCTS
  AND  tdr.CardLast4 = @CardLast4
  AND tdr.TransactionDate = @TransactionDate
  AND tdr.TransactionTime = @TransactionTime
  
  IF @ExistingRecord_Count > 0 
	BEGIN
			UPDATE [dbo].[RTMC_ClearedTransactionDataResponse]
			SET 
			AccountNumber = @AccountNumber,
			CompanyNumber = @CompanyNumber,
			TransactionID = @TransactionID,
			AuthorizationCode = @AuthorizationCode,
			CardEntryMode = @CardEntryMode,
			CardGroup = @CardGroup, 
			CardMemo = @CardMemo,
			CardHolderName = @CardHolderName,
			ClearingReferenceNumber = @ClearingReferenceNumber,
			ExceptionIndicator = @ExceptionIndicator,
			MCC = @MCC,
			MerchantCity = @MerchantCity,
			MerchantID = @MerchantID,
			MerchantName = @MerchantName,
			ProcessDate = @ProcessDate,
			ProcessTime = @ProcessTime,
			TCC = @TCC,
			BillInvoiceAmount = @BillInvoiceAmount,
			TransactionAmount = @TransactionAmount,
			MessageSet = @MessageSet,
			ResponseCode = @ResponseCode,
			BillingCurrency = @BillingCurrency,
			Fee1 = @Fee1,
			Fee2 = @Fee2,
			RecordType = @RecordType,
			ExchangeRate = @ExchangeRate,
			LastModifiedDate = getdate(),
			Complete = 0
			WHERE CardCTS = @CardCTS
			AND  CardLast4 = @CardLast4
			AND TransactionDate = @TransactionDate
			AND TransactionTime = @TransactionTime
	END
ELSE
	BEGIN
		INSERT INTO  [dbo].[RTMC_ClearedTransactionDataResponse]
		([AccountNumber],
		[CompanyNumber],
		[TransactionID],
		[AuthorizationCode],
		[CardCTS],
		[CardEntryMode],
		[CardGroup],
		[CardLast4],
		[CardMemo],
		[CardHolderName],
		[ClearingReferenceNumber],
		[ExceptionIndicator],
		[MCC],
		[MerchantCity],
		[MerchantID],
		[MerchantName],
		[ProcessDate],
		[ProcessTime],
		[TCC],
		[BillInvoiceAmount],
		[TransactionAmount],
		[TransactionDate],
		[TransactionTime],
		[MessageSet],
		[ResponseCode],
		[BillingCurrency],
		[Fee1],
		[Fee2],
		[RecordType],
		[ExchangeRate],
		[CreatedBy],
		[LastModifiedDate])
   VALUES 
		(@AccountNumber,
		@CompanyNumber,
		@TransactionID,
		@AuthorizationCode,
		@CardCTS,
		@CardEntryMode,
		@CardGroup,
		@CardLast4,
		@CardMemo,
		@CardHolderName,
		@ClearingReferenceNumber,
		@ExceptionIndicator,
		@MCC,
		@MerchantCity,
		@MerchantID,
		@MerchantName,
		@ProcessDate,
		@ProcessTime,
		@TCC,
		@BillInvoiceAmount,
		@TransactionAmount,
		@TransactionDate,
		@TransactionTime,
		@MessageSet,
		@ResponseCode,
		@BillingCurrency,
		@Fee1,
		@Fee2,
		@RecordType,
		@ExchangeRate,
		'RTMC Cleared Transaction Data Delivery',
		getdate())
	END

END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH



GO
