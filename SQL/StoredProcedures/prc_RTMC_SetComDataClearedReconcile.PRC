-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/20/2014
-- Description:  Stored Procedure to upsert RTCM cleared data to ClientWise ComDataReconcile table

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_SetComDataClearedReconcile]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_SetComDataClearedReconcile]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_SetComDataClearedReconcile] (
	@ClearedID int,
    @CardCTS   varchar(20),
	@TransactionID varchar(15),
	@CompanyNumber varchar(15),
	@AccountNumber varchar(15),
	@TCC char(1),
	@TransactionDateTime datetime,
	@ProcessDateTime DateTime = NULL,
	@ClearingReferenceNumber varchar(15),
	@AuthorizationCode varchar(10),
	@BillInvoiceAmount decimal(18,2),
	@CCNumber varchar(25),
	@MCC varchar(15),
	@SettlementID bigint,
	@ErrorMessage varchar(300) OUT
	
)
	
AS
DECLARE 
	
	@ExistingRecord_Count  int,
	@JobMediaBuy_MMRPO  varchar(50), 
	@Vendor_ID  varchar(15), 
	@IsCredit_Code char(1) 

BEGIN TRY

	SELECT	
	@JobMediaBuy_MMRPO = CONVERT(varchar,jmb.MMRPO),
	@Vendor_ID = CONVERT(varchar,v.ID) 
	FROM CWI_JobMediaBuy jmb
	LEFT JOIN CWI_Vendor v 
	ON jmb.VendorID = v.ID
	WHERE jmb.ID = @SettlementID

   SET  @ExistingRecord_Count = 0;
   SELECT @ExistingRecord_Count = Count(ID)
   FROM [dbo].[COMDATAReconcile] cdr
   WHERE cdr.CardNo = @CCNumber
   AND cdr.CardCTS = @CardCTS
   AND cdr.TransactionDate = @TransactionDateTime
  
   Set @IsCredit_Code = case when @BillInvoiceAmount >= 0 then 'C' else 'D' end;
  
 IF @ExistingRecord_Count > 0 
	BEGIN
		UPDATE [dbo].[COMDATAReconcile]
		SET Identifier = 0,
			TransactionId =  @TransactionID,
			NwProcessedTransaction = NULL,
			CustomerAccountCode = @CompanyNumber,
			CustomerCorpCode =  @AccountNumber,
			CustomerID = @CompanyNumber,
			isCredit =  @IsCredit_Code,
			BillingType = @TCC,
			SourceCurrency = NULL,
			BillingCurrCode = NULL,
			ConversionRate = NULL,
			isAutomated = NULL,
			TransactionDate = @TransactionDateTime,
			TransactionTime = @TransactionDateTime,
			PostedDate = @ProcessDateTime,
			PostedTime = @ProcessDateTime,
			AdjTransactionNO  = NULL,
			AdjTransactionDate  = NULL,
			isInvoiced = '0',
			Invoicedate  = NULL,
			PaymentDueDate  = NULL,
			InternalTransNo = @ClearingReferenceNumber,
			ControlNo =0,
			MerchantInvoiceNo =NULL,
			BankAuthorisationNO = @AuthorizationCode,
			BillingFlag = NULL,
			TotalAmountDue = @BillInvoiceAmount,
			DiscountAmt = 0,
			TransactionFee = 0,
			ReportingLevel = NULL,
			CardNO = @CCNumber,
			MerchantCode = @MCC,
			isMTSDException =NULL,
			AHException =NULL,
			DDLEException =NULL,
			DTLEException =NULL,
			WeekendService =NULL,
			DuplicateTransaction = NULL,
			ForcePostbyMerchant = NULL,
			isVirtualTempDifferent = NULL,
			CustomerPoNo = @JobMediaBuy_MMRPO,
			VirtualCardVendorNO = @Vendor_ID,
			IsValidated = 0,
			Result = NULL,
			FileName = NULL,
			MMRPaymentDate = NULL,
			MMRCheckNumber = NULL,
			CreatedDateTime = getdate(),
			CreatedBy = 'prc_RTMC_SetComDataClearedReconcile',
			CitiVCNTransDumpID = @ClearedID,
			CardCTS = @CardCTS
	END
ELSE
	BEGIN
		INSERT INTO  [dbo].[COMDATAReconcile]
			([Identifier]
			,[TransactionId]
			,[NwProcessedTransaction]
			,[CustomerAccountCode]
			,[CustomerCorpCode]
			,[CustomerID]
			,[isCredit]
			,[BillingType]
			,[SourceCurrency]
			,[BillingCurrCode]
			,[ConversionRate]
			,[isAutomated]
			,[TransactionDate]
			,[TransactionTime]
			,[PostedDate]
			,[PostedTime]
			,[AdjTransactionNO]
			,[AdjTransactionDate]
			,[isInvoiced]
			,[Invoicedate]
			,[PaymentDueDate]
			,[InternalTransNo]
			,[ControlNo]
			,[MerchantInvoiceNo]
			,[BankAuthorisationNO]
			,[BillingFlag]
			,[TotalAmountDue]
			,[DiscountAmt]
			,[TransactionFee]
			,[ReportingLevel]
			,[CardNO]
			,[MerchantCode]
			,[isMTSDException]
			,[AHException]
			,[DDLEException]
			,[DTLEException]
			,[WeekendService]
			,[DuplicateTransaction]
			,[ForcePostbyMerchant]
			,[isVirtualTempDifferent]
			,[CustomerPoNo]
			,[VirtualCardVendorNO]
			,[IsValidated]
			,[Result]
			,[FileName]
			,[MMRPaymentDate]
			,[MMRCheckNumber]
			,[CreatedDateTime]
			,[CreatedBy]
			,[CitiVCNTransDumpID]
			,[CardCTS])
   VALUES 
			(0,
			 @TransactionID,
			 NULL,
			 @CompanyNumber,
			 @AccountNumber,
			 @CompanyNumber,
			 @IsCredit_Code,
			 @TCC,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 @TransactionDateTime,
			 @TransactionDateTime,
			 @ProcessDateTime,
			 @ProcessDateTime,
			 NULL,
			 NULL,
			 '0',
			 NULL,
			 NULL,
			 @ClearingReferenceNumber,
			 0,
			 NULL,
			 @AuthorizationCode,
			 NULL,
			 @BillInvoiceAmount,
			 0,
			 0,
			 NULL,
			 @CCNumber,
			 @MCC,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 @JobMediaBuy_MMRPO,
			 @Vendor_ID,
			 0,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 getdate(),
			 'prc_RTMC_SetComDataClearedReconcile',
			 @ClearedID,
			 @CardCTS)
	END
END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO
