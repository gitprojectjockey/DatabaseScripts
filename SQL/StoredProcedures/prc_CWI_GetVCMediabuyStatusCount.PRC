/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCMediabuyStatusCount]    Script Date: 7/11/2014 6:42:03 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCMediabuyStatusCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVCMediabuyStatusCount]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCMediabuyStatusCount]    Script Date: 7/11/2014 6:42:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCMediabuyStatusCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetVCMediabuyStatusCount  
* Purpose : This PROC would be called TO get the virtual card counts by status
* Invoked from : ManageVirtaulCard.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVCMediabuyStatusCount
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
  
CREATE PROC [dbo].[prc_CWI_GetVCMediabuyStatusCount]
	 @invoicedtfrom datetime = NULL
	, @invoicedtto	 datetime= NULL
	, @jobno	bigint = NULL
	, @jobname varchar(100)	 = NULL
	, @vendorcode varchar(50) = NULL
	, @vendorname  varchar(100)= NULL
    , @MMRPO	bigint = NULL
	, @vcNo varchar(16) = NULL
	, @vcExpiry varchar(7) = NULL
	, @isDefault bit = 1

AS

IF @isDefault = 1
BEGIN


	SELECT LS.LookupName VCStatusName,LS.Id  VCStatusLookupId,LS.LookupTypeId VCStatusType , ISNULL(t.Count,0) StatusCount FROM
	(
		SELECT VCMB.VCStatusLookupId, count(*) [Count] FROM SettlementComDataCCNumber VCM
		INNER JOIN CWI_JobMediaBuy JMB
			ON JMB.Id = VCM.SettlementID
		INNER JOIN CWI_VCMediaBuy VCMB
			ON JMB.Id = VCMB.MediaBuyId
		INNER JOIN CWI_Job  J
			ON J.Id = JMB.JobId
		WHERE
			J.IsCancelled = 0
			AND J.IsQuote = 0
			AND JMB.IsCancelled = 0
			AND JMB.DNR=0
			AND JMB.IsRemoved = 0
			AND J.InvoiceId IS NULL

		GROUP BY VCMB.VCStatusLookupId
	) t
	RIGHT OUTER JOIN Lookup LS
		ON LS.Id = t.VCStatusLookupId 
	WHERE LS.LookupTypeId IN (51,52)

	RETURN
END

SET @vendorcode = ISNULL(@vendorcode,'''')
SET @vendorname = ISNULL(@vendorname,'''')
SET @jobname = ISNULL(@jobname,'''')
SET @vcNo = ISNULL(@vcNo,'''')
SET @vcExpiry = ISNULL(@vcExpiry,'''')



SELECT  LS.LookupName VCStatusName,LS.Id  VCStatusLookupId,LS.LookupTypeId VCStatusType, ISNULL(t.Count,0) StatusCount FROM
	(
		SELECT VCMB.VCStatusLookupId, count(*) [Count] FROM SettlementComDataCCNumber VCM
		INNER JOIN CWI_JobMediaBuy JMB
			ON JMB.Id = VCM.SettlementID
		INNER JOIN CWI_VCMediaBuy VCMB
			ON JMB.Id = VCMB.MediaBuyId
		INNER JOIN CWI_Job  J
			ON J.Id = JMB.JobId
		INNER JOIN CWI_Vendor V
			ON V.Id = JMB.VendorId

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
		GROUP BY VCMB.VCStatusLookupId
	) t
	RIGHT OUTER JOIN Lookup LS
		ON LS.Id = t.VCStatusLookupId
	
' 
END
GO


