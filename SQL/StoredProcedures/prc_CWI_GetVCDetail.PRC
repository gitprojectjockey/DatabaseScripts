/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCDetail]    Script Date: 11/5/2014 4:20:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVCDetail]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCDetail]    Script Date: 11/5/2014 4:20:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCDetail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetVCDetail]  
* Purpose : This PROC would be called to virtaul carddetails
* Invoked from : ManageVirtualCard.aspx
* CREATED: Mohankumar 06JUN14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetVCDetail] @inVCId  = 28
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetVCDetail] 
	@inVCId bigint 
AS
BEGIN

	BEGIN TRY
		SELECT 
			MP.PlanName,
			MP.PlanFrom,
			MP.PlanTo,
			JMB.MMRPO,
			JMB.JobId,
			JMB.ID as MediaBuyId,
			J.JobName,
			ISNULL(JMB.ActualCost,0.00) NetCost,
			ISNULL(JMB.ActualInvoice,0.00) Invoice,
			JMB.InsertionDeliveredOn LastDeliveryOn,
			ISNULL(LS.LookupName,'''') DeliveryStatus,
			RIGHT(	VC.CCNumber,9) VCNumber,
			VC.ExpirationDate,
			VC.CVC2Number,
			JMB.IsCancelled,
			JMB.CancelledDate,
			JMB.DNR,
			dbo.fnc_CWI_GetJobMediabuyRundatesScalar(NULL,JMB.Id) RunDates,
			J.InvoiceDate,
			CL.ClientCode+''-''+CL.ClientName AS Client,
			CL.ID AS ClientId,
			DV.ClientCode+''-''+DV.ClientName AS Division,
			DV.ID AS DivisionId,
			JMB.VendorId AS VendorId,
			V.VendorCode  AS VendorCode,
			V.VendorName AS VendorName,
			J.InvoiceId,
			JMB.IsRemoved,
			JMB.IsActualCostFreeze,
			JMB.IsComplimentaryInvoice,
			JMB.IsActualInvoiceFreeze,
			JMB.IsComplimentary,
			JMB.PayMethodLookupId as PayMethodLookupId,
			DV.MarkupPct,
			JN.AdCopyFileName,
			J.ClassificationId
		FROM CWI_JobMediaBuy JMB (NOLOCK)
		
		INNER JOIN CWI_VCMediaBuy VCMB
			ON JMB.Id = VCMB.MediaBuyId					
		INNER JOIN CWI_Job  J (NOLOCK)
			ON J.Id = JMB.JobId
		INNER JOIN CWI_JobNewspaper JN
			ON J.ID=JN.JobId
		INNER JOIN CWI_MarketingPlan MP (NOLOCK)
			ON MP.Id = J.MarketingPlanId
		INNER JOIN CWI_Vendor V (NOLOCK)
			ON V.Id = JMB.VendorId
		
		INNER JOIN CWI_Client DV  (NOLOCK)
			ON DV.ID=J.DivisionId
		INNER JOIN CWI_Client CL  (NOLOCK)
			ON DV.ParentID=CL.ID
		INNER JOIN Lookup LC 
			ON LC.Id=J.ClassificationId
		LEFT OUTER JOIN SettlementComDataCCNUmber VC (NOLOCK)
			ON VC.SettlementID = JMB.Id	
		LEFT OUTER JOIN Lookup LS (NOLOCK)
			ON LS.Id = JMB.InsertionStatusLookupId		
		LEFT JOIN CWI_User U (NOLOCK)
			ON U.Id = VCMB.VCLastWorkedBy
	
		WHERE
			VC.Id = @inVCId
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END



' 
END
GO
