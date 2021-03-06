-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/12/2014
-- Description:  Stored Procedure to update TCHEK Data transactions to complete

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_SetMemoTransactionDataComplete]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_SetMemoTransactionDataComplete]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_SetMemoTransactionDataComplete] (
	@CardCTS varchar(50),
	@CardLast4 int,
	@TransactionDate varchar(10),
	@TransactionTime varchar (10),
    @ErrorMessage varchar(300) OUT
  
) AS

BEGIN TRY
	BEGIN
			UPDATE [dbo].[RTMC_MemoTransactionDataResponse]
			SET 
			Complete = 1,
			LastModifiedDate = getdate()
			WHERE CardCTS = @CardCTS
			AND  CardLast4 = @CardLast4
			AND TransactionDate = @TransactionDate
			AND TransactionTime = @TransactionTime
	 END
END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO
