-------------------------------------------------------------------------------
-- Author:       E
-- Create date:  8/12/2014
-- Description:  Stored Procedure to update TCHEK Data transactions to complete

IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_SetRejectTransactionDataComplete]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_SetRejectTransactionDataComplete]
GO

CREATE PROCEDURE [dbo].[prc_RTMC_SetRejectTransactionDataComplete] (
	@CardCTS varchar(50),
	@CardLast4 varchar(50),
	@ProcessDate varchar(10),
	@ProcessTime varchar (10),
    @ErrorMessage varchar(300) OUT
  
) AS

BEGIN TRY
	BEGIN
			UPDATE [dbo].[RTMC_RejectTransactionDataResponse]
			SET 
			Complete = 1,
			LastModifiedDate = getdate()
			WHERE CardCTS = @CardCTS
			AND  CardLast4 = @CardLast4
			AND ProcessDate = @ProcessDate
			AND ProcessTime = @ProcessTime
	 END
END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH




GO
