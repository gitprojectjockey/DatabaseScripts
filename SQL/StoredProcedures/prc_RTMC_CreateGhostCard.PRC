/*******************************************************************      
* PROCEDURE: prc_RTMC_CreateGhostCard  
* Purpose : This PROC will be invoked from Console app RTMC_CreateApprovedPurchaseRequest.sln
                      
* CREATED:  Saiganesh Rajamani 10/13/2014 for T-CHEK RTMC Webservice
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************/      
IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[prc_RTMC_CreateGhostCard]') AND TYPE IN (N'P'))
   DROP PROCEDURE [DBO].[prc_RTMC_CreateGhostCard]
GO

CREATE PROC [dbo].[prc_RTMC_CreateGhostCard]
  @ComDataCommunicationControlID bigint
 ,@SettlementID bigint
 ,@ResponseCode int
 ,@MessageSet varchar(Max)
 ,@Retries int
 ,@ErrorMessage varchar(300) OUT
 AS
SET NOCOUNT ON;

BEGIN TRANSACTION

BEGIN TRY
   
IF @Retries >= 4
BEGIN
	-- Update ComDataCommunicationControl
	UPDATE COMDATACOMMUNICATIONCONTROL 
	SET PROCESSEDDATE=GETDATE(),
	    RESPONSECODE=@RESPONSECODE, 
	    RESPONSEMESSAGE= LEFT(@MESSAGESET,79)
	WHERE ID=@COMDATACOMMUNICATIONCONTROLID
	
	-- Update JobMediaBuy and set the PayMethodLookupID to 'Ghost Card'
	UPDATE CWI_JobMediaBuy
	SET PayMethodLookupID = 854 -- Ghost Card
	WHERE ID=@SETTLEMENTID
	
	-- Call FaxImage
        -- EXEC prc_GenerateFaxImageBySettlementID @SettlementID
        UPDATE CWI_Correspondence SET IsReadyToProcess = 1
	WHERE JobMediaBuyId = @SettlementID
	AND IsTrashed = 0
	AND IsReadyToProcess = 0 
	AND CorrespondenceTypeLookupId IN (701,709) /*Insertion and Change order */
END
ELSE
BEGIN
	UPDATE COMDATACOMMUNICATIONCONTROL 
	SET RETRIES=RETRIES+1 
	WHERE ID=@COMDATACOMMUNICATIONCONTROLID	
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
  ROLLBACK TRANSACTION
END CATCH
GO 
   
   
 