/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediaBuyStatus]    Script Date: 2/19/2014 6:08:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediaBuyStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobMediaBuyStatus]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediaBuyStatus]    Script Date: 2/19/2014 6:08:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediaBuyStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: [prc_CWI_GetJobMediaBuyStatus] 
* Purpose : This PROC would be called TO get  the Job status
* Invoked from : Job.aspx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetJobMediaBuyStatus @JobId =111
  
**********************************************************************/ 
  
CREATE PROC [dbo].[prc_CWI_GetJobMediaBuyStatus]
	@JobId BigInt
AS
BEGIN
	
	SELECT 
		distinct(JMB.StatusId) JobStatusLookupId,
		L.LookupName StatusName 
	FROM CWI_Job J
		INNER JOIN CWI_JobMediaBuy JMB 
			ON J.ID=JMB.JobId
		INNER JOIN Lookup L
			ON L.Id=JMB.StatusId WHERE J.ID=@JobId
		
		
	
		
END





' 
END
GO
