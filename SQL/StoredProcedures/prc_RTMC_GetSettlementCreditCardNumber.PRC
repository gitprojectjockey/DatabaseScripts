IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_GetSettlementCreditCardNumber]') AND TYPE IN (N'P'))
DROP PROCEDURE [dbo].[prc_RTMC_GetSettlementCreditCardNumber] 
GO

CREATE PROCEDURE [dbo].[prc_RTMC_GetSettlementCreditCardNumber] (
	@CardCTS varchar(50),
	@CardLast4 varchar(4),
	@ErrorMessage varchar(300) OUT
	
)
	
AS

BEGIN TRY

  SELECT TOP 1 scd.CCNumber,scd.SettlementID
  FROM [dbo].[SettlementComDataCCNumber] scd
  WHERE scd.CardCTS = @CardCTS
  AND  scd.CardLast4 = @CardLast4

END TRY

BEGIN CATCH
     SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH
GO