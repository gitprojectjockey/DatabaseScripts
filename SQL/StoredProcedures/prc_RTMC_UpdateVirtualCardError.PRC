/*******************************************************************      
* PROCEDURE: prc_RTMC_UpdateVirtualCardError  
* Purpose : This PROC will be invoked from Console app RTMC_UpdateRequest.sln
                      
* CREATED:  Saiganesh Rajamani 10/14/2014 for T-CHEK RTMC Webservice
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************/      
IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[prc_RTMC_UpdateVirtualCardError]') AND TYPE IN (N'P'))
   DROP PROCEDURE [DBO].[prc_RTMC_UpdateVirtualCardError]
GO

CREATE PROC [dbo].[prc_RTMC_UpdateVirtualCardError]
  @ComDataCommunicationControlID bigint
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