/*******************************************************************      
* PROCEDURE: prc_RTMC_UpdateVirtualCard  
* Purpose : This PROC will be invoked from Console app RTMC_UpdateRequest.sln
                      
* CREATED:  Saiganesh Rajamani 10/14/2014 for T-CHEK RTMC Webservice
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************/      
IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[prc_RTMC_UpdateVirtualCard]') AND TYPE IN (N'P'))
   DROP PROCEDURE [DBO].[prc_RTMC_UpdateVirtualCard]
GO

CREATE PROC [dbo].[prc_RTMC_UpdateVirtualCard]
  @ComDataCommunicationControlID bigint
 ,@ErrorMessage varchar(300) OUT
AS
SET NOCOUNT ON;

BEGIN TRANSACTION

BEGIN TRY
 
  -- Update ComDataCommunicationControl status
  UPDATE COMDATACOMMUNICATIONCONTROL
  SET PROCESSEDDATE = GETDATE()
     ,RESPONSEMESSAGE = 'CARD UPDATED'
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