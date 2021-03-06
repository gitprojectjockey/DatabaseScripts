/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobSubmissionOrderDetails]    Script Date: 7/10/2014 7:03:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobSubmissionOrderDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobSubmissionOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobSubmissionOrderDetails]    Script Date: 7/10/2014 7:03:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobSubmissionOrderDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobSubmissionOrderDetails  
* Purpose : This PROC would be called TO get all the contacts for the client id
* Invoked from : Client.aspx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetJobSubmissionOrderDetails 1314
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetJobSubmissionOrderDetails] 
	@JobId BIGINT
AS
BEGIN
Declare @Rundate dateTime;

Select @Rundate=Min(Convert(datetime,fieldvalue))  FROM fnc_CWI_GetJobMediabuyRundates(@JobId, NULL);
	Select 
	distinct(J.ID) AS JobId,
	@Rundate as Rundate	  
FROM CWI_Job J
INNER JOIN 
	CWI_JobMediaBuy JMB
ON	J.ID=JMB.JobId
INNER JOIN
	CWI_JobNewspaper JN

ON JN.JobId=J.ID
--left JOIN
--	CWI_JobMediaBuyRundateTemplateData JMT ON JMT.MediaBuyId=JMB.ID
	 where J.ID=@JobId and J.JobStatusLookupId!=803 AND J.JobStatusLookupId!=806 ;
END

' 
END
GO


