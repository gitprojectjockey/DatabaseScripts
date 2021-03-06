/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobsByPlanClass]    Script Date: 11/3/2014 3:35:04 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobsByPlanClass]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobsByPlanClass]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobsByPlanClass]    Script Date: 11/3/2014 3:35:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobsByPlanClass]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobsByPlanClass 
* Purpose : This PROC would be called to return the job summary of plan and classification/service
* Invoked from : MarketingPlan.aspx.cs
* CREATED: MohanKumar 05SEP13
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
  prc_CWI_GetJobsByPlanClass   3, null, null

**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetJobsByPlanClass]
	@PlanId	int,
	@InvDate datetime = NULL,
	@ClassId int = NULL
AS

		
		SELECT 
			J.ID JobId,
			J.JobName JobName,
			J.JobSummary 		JobDesc,
			L.LookupName JobStatus,
			J.InvoiceDate AS InvoiceDate,
			UO.Names JobOwner,
			J.CreatedOn AS LastModifiedOn,
			UM.Names AS LastModifiedBy,
			J.JobDueBy,
			J.ClassificationId,
			LC.LookupName ClassName,
			(SELECT STUFF((SELECT '',''+CONVERT(VARCHAR(100),ISNULL(Names,G.GroupName)) FROM CWI_JobAssignee JA 
		LEFT OUTER JOIN [CWI_User] U
		ON JA.UserId=U.Id AND JA.JobId=J.ID AND JA.IsRemoved=0
		LEFT OUTER JOIN [CWI_Group] G
		ON JA.GroupId=G.Id AND JA.JobId=J.ID AND JA.IsRemoved=0
		FOR XML PATH('''')),1,1,'''')) Assignee
				

		FROM CWI_Job J
		INNER JOIN Lookup L
			ON L.Id = J.JobStatusLookupId
		INNER JOIN Lookup LC
			ON LC.Id = J.ClassificationId
		INNER JOIN CWI_User UO
			ON UO.Id = J.CreatedBy
		INNER JOIN CWI_User UM
			ON UM.Id = J.ModifiedBy
		WHERE J.MarketingPlanId = @PlanId
		AND (@ClassId IS NULL OR ClassificationId = @ClassId)
		AND (@InvDate IS NULL OR J.InvoiceDate = @InvDate)

		ORDER BY JobDueBy 
	





' 
END
GO


