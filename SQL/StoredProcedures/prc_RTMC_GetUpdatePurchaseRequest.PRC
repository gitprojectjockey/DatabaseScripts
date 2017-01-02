/*******************************************************************      
* PROCEDURE: prc_RTMC_GetApprovedPurchaseRequest  
* Purpose : This PROC will be invoked from console app prc_RTMC_GetUpdatePurchaseRequest.sln
                      
* CREATED:  Saiganesh Rajamani 06/23/2014 for T-CHEK RTMC Webservice
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************/      
IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[prc_RTMC_GetUpdatePurchaseRequest]') AND TYPE IN (N'P'))
   DROP PROCEDURE [DBO].[prc_RTMC_GetUpdatePurchaseRequest]
GO

CREATE PROC [dbo].[prc_RTMC_GetUpdatePurchaseRequest]
@ErrorMessage varchar(300) output     
AS
BEGIN TRY
	SELECT
	   COMM.ID AS ComDataCommunicationControlID
	  ,COMM.SettlementID
	  ,COMM.CCLimit
	  ,SCC.CCNumber
	  ,'SettlementID: ' + CONVERT(VARCHAR(20), COMM.SETTLEMENTID) AS Notes
	  ,ISNULL(COMM.Retries,0) AS Retries
	FROM COMDATACOMMUNICATIONCONTROL COMM  
	INNER JOIN CWI_JobMediaBuy JMB ON JMB.ID = COMM.SETTLEMENTID  
	INNER JOIN SETTLEMENTComDataCCNumber SCC ON SCC.SETTLEMENTID = COMM.SETTLEMENTID
	WHERE COMM.COMDATATEMPLATEID = 2 -- UPDATE REQUEST  
	AND COMM.PROCESSEDDATE IS NULL  
	AND COMM.RETRIES < 5
        ORDER BY COMM.CREATED
END TRY
BEGIN CATCH
	SELECT @ErrorMessage = ERROR_MESSAGE()	
END CATCH
GO

