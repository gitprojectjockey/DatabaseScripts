/*******************************************************************      
* PROCEDURE: prc_RTMC_CreateApprovedPurchaseResponse  
* Purpose : This PROC will be invoked from Console app RTMC_CreateApprovedPurchaseRequest.sln
                      
* CREATED:  Saiganesh Rajamani 06/23/2014 for T-CHEK RTMC Webservice
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************/      
IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[prc_RTMC_CreateApprovedPurchaseResponse]') AND TYPE IN (N'P'))
   DROP PROCEDURE [DBO].[prc_RTMC_CreateApprovedPurchaseResponse]
GO

CREATE PROC [dbo].[prc_RTMC_CreateApprovedPurchaseResponse]
  @ComDataCommunicationControlID bigint
 ,@SettlementID bigint
 ,@TransactionID varchar(50)
 ,@BillingAddress varchar(50)
 ,@CardGroup int
 ,@City varchar(50)
 ,@StateProv varchar(10)
 ,@PostalCode varchar(10)
 ,@VirtualMasterCardNumber varchar(25)
 ,@CVC int
 ,@ExpirationDate varchar(10)
 ,@CardCTS varchar(50)
 ,@ResponseCode int
 ,@MessageSet varchar(Max)
 ,@Retries int
 ,@ErrorMessage varchar(300) OUT
 AS
SET NOCOUNT ON;

BEGIN TRANSACTION

BEGIN TRY
 
   /* Insert the raw response for Audit trail */
   INSERT INTO [dbo].[RTMC_CreateApprovedPurchaseResponse]
           ([ComDataCommunicationControlID]
           ,[SettlementID]
           ,[TransactionID]
           ,[BillingAddress]
           ,[CardGroup]
           ,[City]
           ,[StateProv]
           ,[PostalCode]
           ,[VirtualMasterCardNumber]
           ,[CVC]
           ,[ExpirationDate]
           ,[CardCTS]
           ,[ResponseCode]
           ,[MessageSet]
           ,[Retries]
           ,[CreatedBy]
           ,[CreatedDate])
   VALUES(@ComDataCommunicationControlID
         ,@SettlementID
         ,@TransactionID
         ,@BillingAddress
         ,@CardGroup
         ,@City
         ,@StateProv
         ,@PostalCode
         ,@VirtualMasterCardNumber
         ,@CVC
         ,@ExpirationDate
         ,@CardCTS
         ,@ResponseCode
         ,@MessageSet
         ,@Retries
         ,'RTMC_CreateRequest Console App'
         ,GetDate())
   
  
  COMMIT TRANSACTION
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
  ROLLBACK TRANSACTION
END CATCH
GO 
   
   
 