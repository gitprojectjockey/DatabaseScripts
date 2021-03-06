

-- Author:       E
-- Create date:  8/6/2014
-- Description:  Stored Procedure to get TCHEK Last Process Data 

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_GetLastProcessedTransactionData]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_GetLastProcessedTransactionData] 
GO

CREATE PROCEDURE [dbo].[prc_RTMC_GetLastProcessedTransactionData] (
	@TransactionType varchar(50) = NULL,
    @ErrorMessage varchar(300) OUT
  
) AS

DECLARE 
	
	@ExistingRecord_Count      int  

BEGIN TRY
		BEGIN
			SELECT
				TransactionType,
				TransactionID,
				AccountNumber,
				Company, 
				LastProcessDate,
				LastProcessedResponseCode,
				LastProcessedMessage
			FROM [RTMC_LastProcessedTransactionData] ltd
			WHERE ltd.TransactionType = @TransactionType
		END
END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH






GO
