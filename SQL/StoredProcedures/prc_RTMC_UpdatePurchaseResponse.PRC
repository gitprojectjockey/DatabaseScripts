/*******************************************************************      
* PROCEDURE: prc_RTMC_UpdatePurchaseResponse  
* Purpose : This PROC will be invoked from Console app RTMC_UpdateRequest.sln
                      
* CREATED:  Saiganesh Rajamani 07/17/2014 for T-CHEK RTMC Webservice
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************/      
IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[prc_RTMC_UpdatePurchaseResponse]') AND TYPE IN (N'P'))
   DROP PROCEDURE [DBO].[prc_RTMC_UpdatePurchaseResponse]
GO

CREATE PROC [dbo].[prc_RTMC_UpdatePurchaseResponse]
  @ComDataCommunicationControlID bigint
 ,@SettlementID bigint
 ,@TransactionID varchar(50)
 ,@VirtualMasterCardNumber varchar(25)
 ,@ResponseCode int
 ,@MessageSet varchar(Max)
 ,@Retries int
 ,@ErrorMessage varchar(300) OUT
 AS
SET NOCOUNT ON;

BEGIN TRANSACTION

BEGIN TRY
 
   /* Insert the raw response for Audit trail */
   INSERT INTO [dbo].[RTMC_UpdatePurchaseResponse]
           ([ComDataCommunicationControlID]
           ,[SettlementID]
           ,[TransactionID]
           ,[VirtualMasterCardNumber]
           ,[ResponseCode]
           ,[MessageSet]
           ,[Retries]
           ,[CreatedBy]
           ,[CreatedDate])
   VALUES(@ComDataCommunicationControlID
         ,@SettlementID
         ,@TransactionID
         ,@VirtualMasterCardNumber
         ,@ResponseCode
         ,@MessageSet
         ,@Retries
         ,'RTMC_UpdateRequest Console App'
         ,GetDate())
  COMMIT TRANSACTION
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
  ROLLBACK TRANSACTION
END CATCH
GO 
   
   
 