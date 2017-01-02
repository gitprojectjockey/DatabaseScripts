/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobAwaitingInvoiceApproval]    Script Date: 5/7/2014 9:57:15 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobAwaitingInvoiceApproval]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobAwaitingInvoiceApproval]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobAwaitingInvoiceApproval]    Script Date: 5/7/2014 9:57:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobAwaitingInvoiceApproval]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobAwaitingInvoiceApproval 
* Purpose : This PROC would be called to update job staus as awaiting invoice authorization 
			based on cost and media buy status 
* Invoked from : Jobs.aspx, [CWI_TR_JobMediaBuy_Update]
* CREATED: MohanKumar 06MAY14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_SetJobAwaitingInvoiceApproval] @jobid =4, @ = NULL

**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetJobAwaitingInvoiceApproval]
	@jobId bigint = NULL, 
	@MediabuyId bigint = NULL
AS

IF @jobId IS NULL
Begin
	SELECT  @jobId = JobId FROM CWI_JobMediaBuy
	WHERE Id = @MediabuyId
End

IF @jobid IS NOT NULL
Begin
	DECLARE @tblJobActionAttribute tt_CWI_JobActionAttribute
	INSERT INTO @tblJobActionAttribute
	EXECUTE prc_CWI_GetJobActionAttributes @jobId

	IF EXISTS ( 
		SELECT top 1 1 FROM @tblJobActionAttribute WHERE InvoiceId IS NULL
		AND IsCancelled = 0 
		AND IsQuote = 0
		AND ( IsInsertionOrderGenerated = 1 OR
			ClassificationId IN (404, 407)/* Insertion order not applicable to Job Boards and Digital media */
			)
		)/* If job not cancelled and not authorized */
	BEGIN
		IF EXISTS (
				select TOP 1 1 from CWI_JobMediaBuy
				where JobId = @jobId
				AND IsCancelled= 0
				AND IsRemoved = 0
				AND DNR = 0
				AND ( 
					ISNULL(ActualCost,0) <=0 AND IsComplimentary = 0
					)
			) /*  If cost not collected for atleast one valid media buy */
		Begin
			UPDATE CWI_Job SET JobStatusLookupId = 8001 /* In Progress */
			WHERE Id = @jobId
		End
		Else
		Begin
			UPDATE CWI_Job SET JobStatusLookupId = 8002 /* Awaiting Invoice Authorization */
			WHERE Id = @jobId
		End

	END
End


' 
END
GO


