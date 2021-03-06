-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  7/30/2014
-- Description:  Stored Procedure to upsert TCHEK Data Transactions

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_SetMemoTransactionDataResponse]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_SetMemoTransactionDataResponse]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_SetMemoTransactionDataResponse] (
	@AccountNumber varchar(50)=  NULL,
	@CompanyNumber varchar(50),
	@TransactionID varchar(50),
	@AVSAddress varchar(10)= NULL,
	@AVSResult varchar(10)= NULL,
	@AVSZip varchar(10)= NULL,
	@AuthorizationCode varchar(50)=  NULL,
	@CardCTS varchar(50),
	@CardEntryMode int,
	@CardGroup varchar(50)=  NULL,
	@CardLast4 int,
	@CardMemo varchar(50)=  NULL,
	@ClearingReferenceNumber varchar(50) = NULL,
	@ExceptionIndicator varchar(5),
	@MCC int,
	@MerchantCity varchar(50),
	@MerchantID varchar (50),
	@MerchantName  varchar(max),
	@MerchantStateProv varchar(10),
	@ProcessDate varchar(10),
	@ProcessTime varchar(10),
	@TCC varchar(5),
	@TransactionAmount decimal(12, 2),
	@TransactionDate varchar(10),
	@TransactionTime varchar (10),
	@TransactionType varchar(5),
	@MessageSet varchar(max),
	@ResponseCode int,
    @ErrorMessage varchar(300) OUT
  
  
) AS
DECLARE 
	
	@ExistingRecord_Count      int  

BEGIN TRY

  set @ExistingRecord_Count = 0;

  SELECT @ExistingRecord_Count = Count(ID)
  FROM [dbo].[RTMC_MemoTransactionDataResponse] tdr
  WHERE tdr.CardCTS = @CardCTS
  AND  tdr.CardLast4 = @CardLast4
  AND tdr.TransactionDate = @TransactionDate
  AND tdr.TransactionTime = @TransactionTime
  
  IF @ExistingRecord_Count > 0 
	BEGIN
			UPDATE [dbo].[RTMC_MemoTransactionDataResponse]
			SET 
			AccountNumber = @AccountNumber,
			CompanyNumber = @CompanyNumber,
			TransactionID = @TransactionID,
			AVSAddress = @AVSAddress,
			AVSResult = @AVSResult, 
			AVSZip = @AVSZip, 
			AuthorizationCode = @AuthorizationCode, 
			CardEntryMode = @CardEntryMode,
			CardGroup = @CardGroup, 
			CardMemo = @CardMemo, 
			ClearingReferenceNumber = @ClearingReferenceNumber,
			ExceptionIndicator = @ExceptionIndicator,
			MCC = @MCC,
			MerchantCity = @MerchantCity,
			MerchantID = @MerchantID,
			MerchantName = @MerchantName,
			MerchantStateProv = @MerchantStateProv,
			ProcessDate = @ProcessDate,
			ProcessTime = @ProcessTime,
			TCC = @TCC,
			TransactionAmount = @TransactionAmount,
			TransactionType = @TransactionType,
			MessageSet = @MessageSet,
			ResponseCode = @ResponseCode,
			LastModifiedDate = getdate(),
			Complete = 0
			WHERE CardCTS = @CardCTS
			AND  CardLast4 = @CardLast4
			AND TransactionDate = @TransactionDate
			AND TransactionTime = @TransactionTime
	END
ELSE
	BEGIN
		INSERT INTO  [dbo].[RTMC_MemoTransactionDataResponse]
		([AccountNumber],
		[CompanyNumber],
		[TransactionID],
		[AVSAddress],
		[AVSResult],
		[AVSZip],
		[AuthorizationCode],
		[CardCTS],
		[CardEntryMode],
		[CardGroup],
		[CardLast4],
		[CardMemo],
		[ClearingReferenceNumber],
		[ExceptionIndicator],
		[MCC],
		[MerchantCity],
		[MerchantID],
		[MerchantName],
		[MerchantStateProv],
		[ProcessDate],
		[ProcessTime],
		[TCC],
		[TransactionAmount] ,
		[TransactionDate],
		[TransactionTime],
		[TransactionType],
		[MessageSet],
		[ResponseCode],
		[CreatedBy],
		[LastModifiedDate])
   VALUES 
		(@AccountNumber,
		@CompanyNumber,
		@TransactionID,
		@AVSAddress,
		@AVSResult,
		@AVSZip,
		@AuthorizationCode,
		@CardCTS,
		@CardEntryMode,
		@CardGroup,
		@CardLast4,
		@CardMemo,
		@ClearingReferenceNumber,
		@ExceptionIndicator,
		@MCC,
		@MerchantCity,
		@MerchantID,
		@MerchantName,
		@MerchantStateProv,
		@ProcessDate,
		@ProcessTime,
		@TCC,
		@TransactionAmount ,
		@TransactionDate,
		@TransactionTime,
		@TransactionType,
		@MessageSet,
		@ResponseCode,
		'RTMC Memo Transaction Data Delivery',
		getdate())
	END

END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH





GO
