SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetJob]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetJob]
GO

CREATE PROC [dbo].[prc_ClientPortal_GetJob]
    @JobID bigint
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  SELECT J.ID AS JobNumber
        ,J.AdDescription
        ,J.InvoiceDate
        ,Null AS PublishDate
        ,V.VendorCode
        ,V.VendorName
        ,ADDR.City as VendorCity
        ,ST.StateName AS Statecode
        ,CASE WHEN MB.IsComplimentaryInvoice = 0 THEN ISNULL(CONVERT(varchar(20),CAST(MB.ActualInvoice AS DECIMAL(8,2))),'NA') ELSE 'Comp' END AS EstInvoice
        ,J.ApprovedByPortalUserID
        ,dbo.fnc_ClientPortal_GetUserName(J.ApprovedByPortalUserID, 1) ApprovedBy
        ,J.ApprovedDate
FROM CWI_Job J
INNER JOIN CWI_JobMediaBuy MB on J.ID = MB.Jobid
INNER JOIN CWI_Vendor V ON MB.Vendorid = V.ID
LEFT JOIN CWI_Address ADDR ON V.AddressID_Physical = ADDR.ID
LEFT JOIN DBO.State ST ON ADDR.StateID = ST.ID 
WHERE J.ID = @JobID
AND (MB.IsCancelled = 0 and MB.DNR = 0 or MB.IsRemoved = 0)

UNION

SELECT J.ID AS JobNumber
      ,J.AdDescription
      ,J.InvoiceDate
      ,Null AS PublishDate
      ,NULL AS VendorCode
      ,JS.ServiceDescription AS VendorName
      ,NULL AS City
      ,NULL AS StateCode
      ,CASE WHEN JS.IsComplimentary = 0 THEN ISNULL(CONVERT(varchar(20),CAST(JS.ServiceFee AS DECIMAL(8,2))),'NA') ELSE 'Comp' END AS EstInvoice
      ,J.ApprovedByPortalUserID
      ,dbo.fnc_ClientPortal_GetUserName(J.ApprovedByPortalUserID, 1) ApprovedBy
      ,J.ApprovedDate
FROM CWI_Job J
INNER JOIN CWI_JobService JS ON J.ID = JS.JobID
WHERE J.ID = @JobID
and JS.IsDeleted = 0
   
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO