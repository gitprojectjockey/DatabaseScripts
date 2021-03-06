/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCMediabuyStatusDetails]    Script Date: 7/11/2014 6:42:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCMediabuyStatusDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVCMediabuyStatusDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCMediabuyStatusDetails]    Script Date: 7/11/2014 6:42:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCMediabuyStatusDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVCMediabuyStatusDetails  
* Purpose : This PROC would be called TO get the virtual card details by status
* Invoked from : ManageVirtaulCard.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVCMediabuyStatusDetails
@invoicedtfrom  = NULL
	, @invoicedtto	 = NULL
	, @jobno	 = NULL
	, @jobname	 = NULL
	, @vendorcode  = NULL
	, @vendorname  = NULL
    , @MMRPO	 = 1
	, @vcNo  = NULL
	, @vcExpiry  = NULL
	, @isDefault  = 1
  
**********************************************************************/ 
  
CREATE PROC [dbo].[prc_CWI_GetVCMediabuyStatusDetails]
	 @invoicedtfrom datetime = NULL
	, @invoicedtto	 datetime= NULL
	, @jobno	bigint = NULL
	, @jobname varchar(100)	 = NULL
	, @vendorcode varchar(50) = NULL
	, @vendorname  varchar(100)= NULL
    , @MMRPO	bigint = NULL
	, @vcNo varchar(16) = NULL
	, @vcExpiry varchar(7) = NULL
	, @inStatus int = NULL
	, @inStatusType int = NULL
	, @isDefault bit = 1

AS

IF @isDefault = 1
BEGIN
	SELECT 
		VCM.Id,
		JMB.Id MediaBuyId,
		JMB.MMRPO,
		V.VendorCode,
		V.Id VendorId,
		J.InvoiceDate,
		LS.LookupName VCStatus,
		JMB.ActualCost,
		JMB.ActualInvoice,
		U.Names VCLastWorkedBy,
		VCMB.VCLastWorkedOn VCLastWorkedOn,
		VCMB.VCLastComment
	FROM SettlementComDataCCNumber VCM
	INNER JOIN CWI_JobMediaBuy JMB
		ON JMB.Id = VCM.SettlementID
	INNER JOIN CWI_VCMediaBuy VCMB
		ON JMB.Id = VCMB.MediaBuyId
	INNER JOIN CWI_Job  J
		ON J.Id = JMB.JobId
	INNER JOIN Lookup LS
		ON LS.Id = VCMB.VCStatusLookupId
	INNER JOIN CWI_Vendor V
		ON V.Id = JMB.VendorId
	LEFT OUTER  JOIN CWI_User U
		ON U.Id = VCMB.VCLastWorkedBy

	WHERE
		J.IsCancelled = 0
		AND J.IsQuote = 0
		AND JMB.IsCancelled = 0
		AND JMB.DNR=0
		AND JMB.IsRemoved = 0
		AND J.InvoiceId IS NULL
		AND  ( @jobno IS NULL OR JMB.JobId=@jobno)
		AND ( @inStatus IS NULL OR VCMB.VCStatusLookupId = @inStatus)
		AND ( @inStatusType IS NULL OR LS.LookupTypeId = @inStatusType)

	RETURN
END

SET @vendorcode = ISNULL(@vendorcode,'''')
SET @vendorname = ISNULL(@vendorname,'''')
SET @jobname = ISNULL(@jobname,'''')
SET @vcNo = ISNULL(@vcNo,'''')
SET @vcExpiry = ISNULL(@vcExpiry,'''')


SELECT 
	VCM.Id,
	JMB.Id MediaBuyId,
	JMB.MMRPO,
	V.VendorCode,
	V.Id VendorId,
	J.InvoiceDate,
	LS.LookupName VCStatus,
	JMB.ActualCost,
	JMB.ActualInvoice,
	U.Names VCLastWorkedBy,
	VCMB.VCLastWorkedOn,
	VCMB.VCLastComment
FROM SettlementComDataCCNumber VCM
INNER JOIN CWI_JobMediaBuy JMB
	ON JMB.Id = VCM.SettlementID
INNER JOIN CWI_VCMediaBuy VCMB
	ON JMB.Id = VCMB.MediaBuyId
INNER JOIN CWI_Job  J
	ON J.Id = JMB.JobId
INNER JOIN Lookup LS
	ON LS.Id = VCMB.VCStatusLookupId
INNER JOIN CWI_Vendor V
	ON V.Id = JMB.VendorId
LEFT OUTER  JOIN CWI_User U
	ON U.Id = VCMB.VCLastWorkedBy

WHERE
	J.IsCancelled = 0
	AND J.IsQuote = 0
	AND JMB.IsCancelled = 0
	AND JMB.DNR=0
	AND JMB.IsRemoved = 0
	AND J.InvoiceId IS NULL
	AND J.InvoiceDate >= ISNULL(@invoicedtfrom,''2013-01-01'') 
	AND J.InvoiceDate <= ISNULL(@invoicedtto,''2300-01-01'')
	AND V.VendorCode like +''%''+@vendorcode+''%''
	AND V.VendorName like +''%''+@vendorname+''%''
	AND J.JobName like +''%''+@jobname+''%''
	AND  ( @jobno IS NULL OR J.Id = @jobno)
	AND  ( @MMRPO IS NULL OR JMB.MMRPO = @MMRPO)
	AND VCM.CCNumber like +''%''+@vcNo+''%''
	AND VCM.ExpirationDate like +''%''+@vcExpiry+''%''
	AND  ( @jobno IS NULL OR JMB.JobId=@jobno)
	AND ( @inStatusType IS NULL OR LS.LookupTypeId = @inStatusType)


' 
END
GO


