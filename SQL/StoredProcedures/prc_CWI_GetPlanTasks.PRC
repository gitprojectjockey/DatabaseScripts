/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPlanTasks]    Script Date: 11/3/2014 3:37:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPlanTasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetPlanTasks]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPlanTasks]    Script Date: 11/3/2014 3:37:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPlanTasks]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetPlanTasks
* Purpose : This PROC would be called TO get the tasks of plan or job
* Invoked from : MarketingPlan.aspx
* CREATED: Saravanan  31 OCT 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION             

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetPlanTasks 3,1,1,1  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetPlanTasks]
	@PlanId int = NULL,
	@InvoiceDate datetime = NULL,
		@ClassId int = NULL,
	@jobId bigint = NULL
AS

	DECLARE @tblTask TABLE
	(
		taskId bigint
	)

	IF  @jobId IS NOT NULL
	BEGIN
		INSERT INTO @tblTask
		SELECT Id FROm CWI_Task WHERE ObjectLookupId = 205 /* job*/ and ObjectId = @jobId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTask
		SELECT T.Id FROm CWI_Task T
		INNER JOIN CWI_Job J
			ON T.ObjectId = J.ID
			AND T.ObjectLookupId = 205 /* job*/
		WHERE  J.MarketingPlanId= @PlanId
			AND (@InvoiceDate IS NULL OR J.InvoiceDate = @InvoiceDate)
			AND (@ClassId IS NULL OR ClassificationId = @ClassId)
	END
         
	SELECT
		T.* ,
		(SELECT STUFF((SELECT '',''+CONVERT(VARCHAR(100),ISNULL(Names,G.GroupName)) FROM CWI_TaskAssignee TA 
		LEFT OUTER JOIN [CWI_User] U
		ON TA.UserId=U.Id AND TA.TaskId=T.Id AND TA.IsRemoved=0
		LEFT OUTER JOIN [CWI_Group] G
		ON TA.GroupId=G.Id AND TA.TaskId=T.Id AND TA.IsRemoved=0
		FOR XML PATH('''')),1,1,'''')) Assignee,
		UA.Names CreatedUser,
		UA.Email AuthorEmail,
		UM.Names ModifiedUser,
		LS.LookupName [Status],
		LP.LookupName [Priority]
       
	FROM
		@tblTask Temp
		
		INNER JOIN CWI_Task T
		ON Temp.taskId=T.Id
		INNER JOIN Lookup LS
		ON LS.Id = T.StatusLookupId 
		INNER JOIN Lookup LP
		ON LP.Id = T.PriorityLookupId
		INNER JOIN CWI_User UA
		ON UA.Id = T.CreatedBy
		INNER JOIN CWI_User UM
		ON UM.Id = T.ModifiedBy
		LEFT JOIN CWI_JOB J
		ON J.ID=T.ObjectId AND T.ObjectLookupId = 205 /* JOB */

		ORDER BY T.DueDate ASC;
		

	' 
END
GO


