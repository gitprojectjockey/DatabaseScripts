-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/6/2014
-- Description:  Stored Procedure to upsert REJECT TCHEK Data Transactions

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_SetRejectTransactionDataResponse]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_SetRejectTransactionDataResponse]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_SetRejectTransactionDataResponse] (
	@AccountNumber varchar(50) =NULL,
	@CompanyNumber varchar(50),
	@TransactionID varchar(50),
	@CardCTS varchar(20) =NULL,
	@CardGroup varchar(50) =NULL,
	@CardLast4 varchar(50) =NULL,
	@CardMemo varchar(50) =NULL,
	@CardHolderName varchar(50) =NULL,
	@MCC int,
	@MerchantCity varchar(50),
	@MerchantCountry varchar(5) = NULL,
	@MerchantName varchar(max),
	@MerchantStateProv varchar(10),
	@MerchantZip varchar (10) = NULL,
	@ProcessDate varchar(10),
	@ProcessTime varchar(10),
	@ReasonCode varchar(5),
	@ReasonSubCode varchar(5),
	@RejectMessage varchar(max),
	@RejectCode varchar(10) =NULL,
	@TCC varchar(5),
	@TransactionAmount decimal(12, 2) =NULL,
	@TransactionDate varchar(10),
	@TransactionTime varchar(10),
	@MessageSet varchar(max),
	@ResponseCode int,
    @ErrorMessage varchar(300) OUT
  
  
) AS
DECLARE 

	@ExistingRecord_Count      int  

BEGIN TRY

  set @ExistingRecord_Count = 0;

  SELECT @ExistingRecord_Count = Count(ID)
  FROM [dbo].[RTMC_RejectTransactionDataResponse] tdr
  WHERE tdr.CardCTS = @CardCTS
  AND  tdr.CardLast4 = @CardLast4
  AND tdr.ProcessDate = @ProcessDate
  AND tdr.ProcessTime = @ProcessTime
  
  IF @ExistingRecord_Count > 0 
	BEGIN
			UPDATE [dbo].[RTMC_RejectTransactionDataResponse]
			SET 
				AccountNumber= @AccountNumber,
				CompanyNumber= @CompanyNumber,
				TransactionID= @TransactionID,
				CardMemo= @CardMemo,
				CardHolderName= @CardHolderName,
				MCC= @MCC,
				MerchantCity= @MerchantCity,
				MerchantCountry= @MerchantCountry,
				@MerchantName= @MerchantName,
				@MerchantStateProv= @MerchantStateProv,
				@MerchantZip= @MerchantZip,
				@ProcessDate= @ProcessDate,
				@ProcessTime= @ProcessTime,
				@ReasonCode= @ReasonCode,
				ReasonSubCode= @ReasonSubCode,
				RejectMessage= @RejectMessage,
				RejectCode= @RejectCode,
				TCC= @TCC,
				TransactionAmount= @TransactionAmount,
				MessageSet= @MessageSet,
				ResponseCode= @ResponseCode,
				LastModifiedDate = getdate(),
				Complete = 0
			WHERE CardCTS = @CardCTS
			AND  CardLast4 = @CardLast4
			AND ProcessDate = @ProcessDate
			AND ProcessTime = @ProcessTime
	END
ELSE
	BEGIN
		INSERT INTO  [dbo].[RTMC_RejectTransactionDataResponse]
		([AccountNumber],
		[CompanyNumber],
		[TransactionID],
		[CardCTS],
		[CardGroup],
		[CardLast4],
		[CardMemo],
		[CardHolderName],
		[MCC] ,
		[MerchantCity],
		[MerchantCountry],
		[MerchantName],
		[MerchantStateProv],
		[MerchantZip],
		[ProcessDate],
		[ProcessTime],
		[ReasonCode],
		[ReasonSubCode],
		[RejectMessage],
		[RejectCode],
		[TCC],
		[TransactionAmount],
		[TransactionDate],
		[TransactionTime],
		[MessageSet],
		[ResponseCode],
		[CreatedBy],
		[LastModifiedDate])
   VALUES 
		(@AccountNumber,
		@CompanyNumber,
		@TransactionID,
		@CardCTS,
		@CardGroup,
		@CardLast4,
		@CardMemo,
		@CardHolderName,
		@MCC,
		@MerchantCity,
		@MerchantCountry,
		@MerchantName,
		@MerchantStateProv,
		@MerchantZip,
		@ProcessDate,
		@ProcessTime,
		@ReasonCode,
		@ReasonSubCode,
		@RejectMessage,
		@RejectCode,
		@TCC,
		@TransactionAmount,
		@TransactionDate,
		@TransactionTime,
		@MessageSet,
		@ResponseCode, 
		'RTMC Reject Transaction Data Delivery',
		getdate())
	END

END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH








GO
