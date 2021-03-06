/****** Object:  StoredProcedure [dbo].[prc_CWI_GetSettlement]    Script Date: 3/24/2014 2:49:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetSettlement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetSettlement]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetSettlement]    Script Date: 3/24/2014 2:49:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetSettlement]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetSettlement  
* Purpose : This PROC would be called to retrieve all the settlement details
* Invoked from : ManageSettlement.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetSettlement] @inMMRPO  = 1126
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetSettlement] 
	@inMMRPO bigint = NULL,
	@inMediabuyId bigint = NULL
AS
BEGIN

	BEGIN TRY
		
		DECLARE @inJobId bigint,@vcRundates VARCHAR(MAX)
		DECLARE @TBL_RUNDATE TABLE (Dates varchar(1000))

		

		SELECT 
			@inJobId = JobId,
			@inMediabuyId = Id,
			@inMMRPO = MMRPO
		FROM CWI_JobMediaBuy 
		WHERE MMRPO=@inMMRPO OR Id = @inMediabuyId 


		INSERT INTO @TBL_RUNDATE
		SELECT DISTINCT FieldValue FROM fnc_CWI_GetJobMediabuyRundates(@inJobId, @inMediaBuyId)
	
		SET @vcRundates = (SELECT STUFF((SELECT '',''+CONVERT(VARCHAR(100),Dates) FROM @TBL_RUNDATE FOR XML PATH('''')),1,1,''''))

		SELECT 
		MB.Id MediabuyId,
		MB.MMRPO,
		J.ClassificationId,
		J.ID AS JobNo,
		J.JobName AS JobName,
		J.JobSummary AS JobDescription,
		J.IsQuote AS IsQuote,
		DV.ClientCode+''-''+DV.ClientName AS Client,
		DV.ID AS ClientId,
		CL.ClientCode+''-''+CL.ClientName AS Division,
		CL.ID AS DivisionId,
		MB.VendorId AS VendorId,
		V.VendorCode+''-''+V.VendorName AS Vendor,
		V.VendorCode  AS VendorCode,
		V.VendorName AS VendorName,
		JN.AdCopyFileName,
		V.AgencyDisc AS AgencyDisc,
		--VC.Id AS VendorContactId,
		--VC.Name AS VendorContactName,
		--VC.Email AS VendorContactEmail,
		--VC.PhoneWork AS VendorPhone,
		--VC.Fax AS VendorFAX,
		ISNULL(MB.ActualCost,0) AS NetCost,
		ISNULL(MB.ActualInvoice,0) AS GrossInvoice,
		ISNULL(MB.QuotedCost,0) AS QuotedCost,
		ISNULL(MB.CostType,''Net'') AS CostType,
		--ISNULL(MB.QuotedBy,0) AS QuotedBy,
		ISNULL(U.Names,'''') AS QuotedBy,
		ISNULL(MB.QuotedDate,'''') AS QuotedDate,
		ISNULL(MB.DNR,0) AS DNR,
		--MB.IsCancelled,
		--CASE WHEN MB.StatusId = 20104 THEN 1 ELSE 0 END AS IsCancelled,	
		CAST (CASE WHEN MB.StatusId = 20104 THEN 1 ELSE 0 END AS BIT) AS IsCancelled,		
		ISNULL(MB.CancelledDate,'''') AS CancelledDate,
		dbo.fnc_CWI_AvgActualCost(MB.VendorId,J.ID) as AvgNetCost,
		@vcRundates AS Rundates,
		ISNULL(J.InvoiceId,0) AS InvoiceID
		FROM CWI_JobMediaBuy MB
		INNER JOIN CWI_JOB J ON MB.JobId=J.ID
		INNER JOIN CWI_JobNewspaper JN ON J.ID=JN.JobId
		INNER JOIN CWI_Client CL ON CL.ID=J.DivisionId
		INNER JOIN CWI_Client DV ON CL.ParentID=DV.ID
		INNER JOIN CWI_Vendor V ON V.Id=MB.VendorId
		--INNER JOIN CWI_VendorContact VC ON VC.VendorId=MB.VendorId	
		LEFT OUTER JOIN CWI_User AS U ON MB.QuotedBy=U.Id	
		WHERE MB.Id=@inMediabuyId
		--AND VC.Id = (SELECT MIN(ID) FROM CWI_VendorContact WHERE VendorId=MB.VendorId)	

	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END






' 
END
GO
