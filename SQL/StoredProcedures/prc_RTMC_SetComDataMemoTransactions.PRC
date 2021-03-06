-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/15/2014
-- Description:  Stored Procedure to upsert RTCM Memo data to ClientWise ComDataTransactions table

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_SetComDataMemoTransactions]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_SetComDataMemoTransactions]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_SetComDataMemoTransactions] (
    @MemoID int,
	@CompanyNumber varchar(10),
	@CCNumber varchar(16),
	@TransactionDateTime datetime,
	@TransactionAmount numeric(9, 2) = NULL,
	@ProcessDateTime datetime = NULL,
	@MCC int = NULL,
	@ResponseCode int = NULL,
	@MessageSet varchar(100),
	@MerchantName  varchar(200),
	@ClearingReferenceNumber bigint = NULL,
	@CardCTS varchar(50),
	@CardLast4 varchar(4),
	@ErrorMessage varchar(300) OUT

)
	
AS
DECLARE 
	
	@ExistingRecord_Count  int

BEGIN TRY

   SET  @ExistingRecord_Count = 0;
   SELECT @ExistingRecord_Count = Count(ID)
   FROM [dbo].[COMDATATRANSACTION] cdt
   WHERE cdt.CardNo = @CCNumber
   AND cdt.TransactionDate = @TransactionDateTime
  
  
 IF @ExistingRecord_Count > 0 
	BEGIN
			UPDATE [dbo].[COMDATATRANSACTION]
			SET CustID = @CompanyNumber,
			CardNo = @CCNumber,
			TransactionDate = @TransactionDateTime,
			TransactionTime = @TransactionDateTime,
			TotalAmountBilled = @TransactionAmount,
			PostedDate = @ProcessDateTime,
			PostedTime = @ProcessDateTime,
			MCCCode = @MCC,
			ErrCode = @ResponseCode,
			ErrDescription = @MessageSet,
			StationInformation = @MerchantName,
			PreAuthAmt = @TransactionAmount,
			ApprovalNumber = @ClearingReferenceNumber,
			CreatedBy = 'prc_RTMC_SetComDataMemoTransactions',
			CitiVCNAuthsDumpID =@MemoID
			WHERE CardNo = @CCNumber
			AND TransactionDate = @TransactionDateTime
	END
ELSE
	BEGIN
		INSERT INTO  [dbo].[COMDATATRANSACTION]
			(CustID,
			CardNo,
			TransactionDate,
			TransactionTime,
			TotalAmountBilled,
			PostedDate,
			PostedTime,
			MCCCode,
			ErrCode,
			ErrDescription,
			StationInformation,
			PreAuthAmt,
			ApprovalNumber,
			CreatedDatetime,
			CreatedBy,
			CitiVCNAuthsDumpID)
   VALUES 
			(@CompanyNumber,
			 @CCNumber,
			 @TransactionDateTime,
			 @TransactionDateTime,
			 @TransactionAmount,
			 @ProcessDateTime,
			 @ProcessDateTime,
			 @MCC,
			 @ResponseCode,
			 @MessageSet,
			 @MerchantName,
			 @TransactionAmount,
			 @ClearingReferenceNumber,
			 getdate(),
			'prc_RTMC_SetComDataMemoTransactions',
			 @MemoID)
	END

END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH



GO
