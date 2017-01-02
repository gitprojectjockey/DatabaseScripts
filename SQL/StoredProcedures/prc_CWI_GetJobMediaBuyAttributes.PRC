/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediaBuyAttributes]    Script Date: 5/13/2014 10:15:27 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediaBuyAttributes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobMediaBuyAttributes]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediaBuyAttributes]    Script Date: 5/13/2014 10:15:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediaBuyAttributes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetJobMediaBuyAttributes]  
* Purpose : This PROC would be called TO get the media buy attributes
* Invoked from : JobMediaBuyRundate.aspx
* CREATED: Mohankumar 13MAY14
* MODIFICATION HISTORY  
* DATE        AUTHOR          DESCRIPTION             
  
**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetJobMediaBuyAttributes 123
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetJobMediaBuyAttributes]
	@inMediaBuyId bigint
AS
BEGIN
	SELECT 
		J.IsCancelled IsJobCancelled ,
		J.IsQuote,
		J.InvoiceId,
		JMB.JobId,
		VendorId,
		MMRPO,
		StatusId,
		ExpectedCost,
		ExpectedInvoice,
		ActualCost,
		ActualInvoice,
		IsActualCostFreeze,
		IsActualInvoiceFreeze,
		IsComplimentary,
		IsComplimentaryInvoice,
		IsRemoved,
		DNR,
		CancelledDate,
		JMB.IsCancelled,
		CostType,
		QuotedCost,
		QuotedDate,
		QuotedBy,
		JMB.CreatedBy,
		JMB.CreatedOn,
		JMB.ModifiedBy,
		JMB.ModifiedOn,
		ActionComment = CASE
			 WHEN J.InvoiceId IS NOT NULL THEN ''Job is invoiced. ''
			 WHEN J.iscancelled = 1 THEN ''Job is cancelled. ''
			 WHEN JMB.IsCancelled  = 1 THEN ''Media buy is cancelled. ''
			 WHEN JMB.IsRemoved  = 1 THEN ''Media buy is removed. ''
			 WHEN JMB.DNR  = 1 THEN ''Media buy is DNR. ''
			ELSE '''' END
	FROM CWI_JobMediaBuy JMB
	INNER JOIN CWI_Job J
		ON J.Id = JMB.JobId
	WHERE
		JMB.ID = @inMediaBuyId
END


' 
END
GO


