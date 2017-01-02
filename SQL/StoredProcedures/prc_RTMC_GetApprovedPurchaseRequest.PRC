/*******************************************************************      
* PROCEDURE: prc_RTMC_GetApprovedPurchaseRequest  
* Purpose : This PROC will be invoked from console app RTMC_CreateRequest.sln
                      
* CREATED:  Saiganesh Rajamani 06/23/2014 for T-CHEK RTMC Webservice
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************/      
IF EXISTS (SELECT * 
           FROM SYS.OBJECTS 
           WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[prc_RTMC_GetApprovedPurchaseRequest]') AND TYPE IN (N'P'))
   DROP PROCEDURE [DBO].[prc_RTMC_GetApprovedPurchaseRequest]
GO

CREATE PROC [dbo].[prc_RTMC_GetApprovedPurchaseRequest]
@ErrorMessage varchar(300) output     
AS
BEGIN TRY
	SELECT
	   COMM.ID AS ComDataCommunicationControlID
	  ,COMM.SettlementID
	  ,COMM.CCLimit
	  ,JMB.MMRPO
	  ,V.VendorName
	  ,A.City
	  ,C.CountryCode
	  ,'SettlementID: ' + CONVERT(VARCHAR(20), COMM.SETTLEMENTID) AS Notes
	  ,CONVERT(VARCHAR(10),DATEADD(d,90,GetDate()),112) AS ValidThroughDate
	  ,ISNULL(COMM.Retries,0) AS Retries
	FROM COMDATACOMMUNICATIONCONTROL COMM  
	INNER JOIN CWI_JobMediaBuy JMB ON JMB.ID = COMM.SETTLEMENTID  
	INNER JOIN CWI_Vendor V ON JMB.VENDORID = V.ID
	INNER JOIN CWI_Address A ON V.AddressId_Physical = A.ID
	INNER JOIN [Country] C ON A.CountryID = C.ID
	WHERE COMM.COMDATATEMPLATEID = 1 --PURCHASE REQUEST  
	AND COMM.PROCESSEDDATE IS NULL  
	AND COMM.RETRIES < 5
        ORDER BY COMM.CREATED
END TRY
BEGIN CATCH
	SELECT @ErrorMessage = ERROR_MESSAGE()	
END CATCH
GO

