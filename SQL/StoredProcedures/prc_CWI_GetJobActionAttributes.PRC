/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobActionAttributes]    Script Date: 5/1/2014 9:17:38 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobActionAttributes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobActionAttributes]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobActionAttributes]    Script Date: 5/1/2014 9:17:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobActionAttributes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobActionAttributes  
* Purpose : This PROC would be called to get job''s current attributes 
			which will be useful to validate job''s actions
* Invoked from : Jobs.aspx
* CREATED: Mohankumar Sundaram		27MAR14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  02JUN14	Mohankumar		Creative ad copy fields returned            

**********************************************************************  
Execution example :
**********************************************************************  
 EXEC prc_CWI_GetJobActionAttributes 1345
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetJobActionAttributes]
	@jobId bigint
AS

SET NOCOUNT ON
DECLARE @tblMB TABLE
(
	MBId bigint,
	StatusId int, 
	IsRemoved bit, 
	IsCancelled bit, 
	DNR bit,
	VendorStatusId int,
	FinalAdCopyFileName varchar(max),
	FinalAdCopySentBy int
)

INSERT INTO @tblMB
select MMRPO, StatusId, IsRemoved , IsCancelled , DNR, V.StatusLookupId, FinalAdCopyFileName, FinalAdCopySentBy  from CWI_JobMediaBuy JMB 
INNER JOIN CWI_Vendor V
	ON V.Id = JMB.VendorId
WHERE JobId = @JobId

DECLARE @ValidMBCount int,
		@InactiveMediaBuyCount int,
		@IsFinalAdCopyAssigned bit,
		@IsFinalAdCopySent bit

SELECT @ValidMBCount = count(*) FROM @tblMB
WHERE IsCancelled = 0 AND IsRemoved = 0 AND DNR = 0

SELECT @InactiveMediaBuyCount = count(*) FROM @tblMB
WHERE IsCancelled = 0 AND IsRemoved = 0 AND DNR = 0
AND VendorStatusId <> 552

/* Check if final ad copy assigned for all valid media buys */
IF @ValidMBCount= 0 OR EXISTS (SELECT top 1 1 FROM @tblMB
	WHERE IsCancelled = 0 AND IsRemoved = 0 AND DNR = 0 AND ISNULL(FinalAdCopyFileName,'''')= '''')
Begin
	SET @IsFinalAdCopyAssigned = 0
End
ELSE
Begin
	SET @IsFinalAdCopyAssigned = 1
End
/* Check if final ad copy sent for all valid media buys */
IF @ValidMBCount= 0 OR EXISTS (SELECT top 1 1 FROM @tblMB
	WHERE IsCancelled = 0 AND IsRemoved = 0 AND DNR = 0 AND ISNULL(FinalAdCopySentBy,0)= 0)
Begin
	SET @IsFinalAdCopySent = 0
End
ELSE
Begin
	SET @IsFinalAdCopySent = 1
End

DECLARE @dt date= CAST( getdate() as date)

SELECT
*,
SubmitChangeOrderComment = 
				CASE WHEN IsCancelled =0 THEN '''' ELSE ''Job cancelled. '' END +
				CASE WHEN InvoiceId IS NULL THEN '''' ELSE ''Invoice process started. '' END +
				CASE WHEN IsQuote=0 THEN '''' ELSE ''Job is quote. '' END +
				CASE WHEN AdCopyFileName <> '''' THEN '''' ELSE ''Ad Copy not available'' END +
				CASE WHEN InsertionStatusCount >0 THEN '''' ELSE ''Media buy is not in the state of "Insertion Generated"'' END /*+
				CASE WHEN FirstRunDate IS NOT NULL AND CAST(FirstRunDate AS datetime) >= @dt  THEN '''' ELSE ''The first run date is passed. '' END*/ ,
InsertionOrderComment = 
				CASE WHEN IsCancelled =0 THEN '''' ELSE ''Job cancelled. '' END +
				CASE WHEN ClassificationId NOT IN (404,407)/*Job Boards, Digital Media*/ THEN '''' 
					ELSE ''Job''''s classification has no ability to create an insertion order. '' END +
				CASE WHEN @ValidMBCount>0 THEN '''' ELSE ''Media buy has not been selected. '' END +
				CASE WHEN @InactiveMediaBuyCount=0 THEN '''' ELSE ''All media buys are not in active status. '' END +
				CASE WHEN IsInsertionOrderGenerated =  0 THEN '''' ELSE ''Insertion order already generated'' END +
				CASE WHEN InvoiceId IS NULL THEN '''' ELSE ''Invoice process started. '' END +
				CASE WHEN AdCopyFileName <> '''' THEN '''' ELSE ''Ad Copy not available'' END

FROM
(
SELECT 
	IsCancelled, 
	IsQuote, 
	ClassificationId,
	LifeCycleId,
	InvoiceDate,
	InvoiceId,
	JobStatusLookupId,
	IsChangeOrder,
	FirstRunDate = SPACE(10),
	/*FirstRunDate = (SELECT MIN(FieldValue) FROM fnc_CWI_GetJobMediabuyRundates(J.Id, NULL)
					WHERE FieldValue IS NOT NULL),*/
	IsMediabuyAvailable = CAST((CASE WHEN @ValidMBCount = 0 THEN 0 ELSE 1 END) as bit),
	IsInsertionOrderGenerated = CASE WHEN (SELECT count( *) FROM @tblMB WHERE StatusId <> 20102 /* selected */ ) >0 THEN 1
								ELSE 0 END,
	InsertionStatusCount = (SELECT count(*) FROM @tblMB WHERE StatusId = 20103 /* Insertion Generated */),
	InactiveMediaBuyCount = @InactiveMediaBuyCount,
	LTRIM(RTRIM(ISNULL(JA.AdCopyFileName,''''))) AdCopyFileName,
	J.IsCreativeAdCopy,
	IsFinalAdCopyAssigned = @IsFinalAdCopyAssigned,
	IsFinalAdCopySent=@IsFinalAdCopySent
FROM CWI_Job J
	LEFT OUTER JOIN CWI_JobNewspaper JA
		ON J.ID = JA.JobId

WHERE
	J.Id = @JobId

) s

SET NOCOUNT OFF




' 
END
GO
