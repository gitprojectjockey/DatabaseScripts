/*******************************************************************      
* PROCEDURE: prc_RTMC_CreateVirtualCard  
* Purpose : This PROC will be invoked from Console app RTMC_CreateApprovedPurchaseRequest.sln
                      
* CREATED:  Saiganesh Rajamani 10/13/2014 for T-CHEK RTMC Webservice
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************/      
IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[prc_RTMC_CreateVirtualCard]') AND TYPE IN (N'P'))
   DROP PROCEDURE [dbo].[prc_RTMC_CreateVirtualCard]
GO

CREATE PROC [dbo].[prc_RTMC_CreateVirtualCard]
  @ComDataCommunicationControlID bigint
 ,@SettlementID bigint
 ,@VirtualMasterCardNumber varchar(25)
 ,@CVC int
 ,@ExpirationDate varchar(10)
 ,@CardCTS varchar(50)
 ,@ErrorMessage varchar(300) OUT
AS
SET NOCOUNT ON;

BEGIN TRANSACTION

BEGIN TRY

        -- Insert SettlementComDataCCNumber with card details
	INSERT INTO SETTLEMENTCOMDATACCNUMBER
	(SETTLEMENTID,CCNUMBER,EXPIRATIONDATE,CVC2NUMBER,CARDCTS, CARDLAST4, CREATED)
        VALUES
        (@SETTLEMENTID,@VIRTUALMASTERCARDNUMBER,REPLACE(@EXPIRATIONDATE,'/',''), CONVERT(VARCHAR,@CVC), @CARDCTS, RIGHT(RTRIM(@VIRTUALMASTERCARDNUMBER), 4),GETDATE())
         
        -- Call FaxImage
        -- EXEC prc_GenerateFaxImageBySettlementID @SettlementID
        UPDATE CWI_Correspondence SET IsReadyToProcess = 1
	WHERE JobMediaBuyId = @SettlementID
	AND IsTrashed = 0
	AND IsReadyToProcess = 0 
	AND CorrespondenceTypeLookupId IN (701,709) /*Insertion and Change order */
	
	
        -- Update ComDataCommunicationControl status
	UPDATE COMDATACOMMUNICATIONCONTROL
	SET PROCESSEDDATE = GETDATE()
	   ,RESPONSEMESSAGE = 'CARD ADDED'
	   ,RESPONSECODE = 0
	   ,RETRIES = 0
	WHERE ID = @ComDataCommunicationControlID
 
        COMMIT TRANSACTION
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
  ROLLBACK TRANSACTION
END CATCH
GO 
   
   
 