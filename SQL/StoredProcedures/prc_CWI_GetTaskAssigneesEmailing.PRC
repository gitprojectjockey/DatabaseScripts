/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskAssigneesEmailing]    Script Date: 7/10/2014 6:43:23 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskAssigneesEmailing]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskAssigneesEmailing]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskAssigneesEmailing]    Script Date: 7/10/2014 6:43:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskAssigneesEmailing]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetTaskAssigneesEmailing 
* Purpose : This PROC would be called TO get the task assignee details to send emails
* Invoked from : tasks.aspx
* CREATED: MohanKumar Sundaram  7/3/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTaskAssigneesEmailing 40858, 1, 0
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetTaskAssigneesEmailing] 
	@taskId bigint,
	@includeAuthor bit,
	@isIncludeRemoval bit = 0
AS

SELECT distinct A.*, U.Email, U.Names FROM
(
	SELECT  ISNULL(TA.UserID,UG.UserID) UserID, 
		TA.IsCopied, TA.IsRemoved,0 IsAuthor
	FROM CWI_TaskAssignee TA (NOLOCK)
	LEFT OUTER JOIN CWI_Group G (NOLOCK)
		ON G.Id = TA.GroupID
	LEFT OUTER JOIN CWI_UserGroup UG (NOLOCK)
		ON UG.GroupID = G.Id 
	WHERE
		TA.TaskId = @taskId
		AND  ( @isIncludeRemoval = 1 OR TA.IsRemoved = 0)
	UNION ALL
	SELECT CreatedBy,0,0,  1 FROM CWI_Task (NOLOCK) 
	WHERE Id = @taskId  and ( @includeAuthor = 1  OR IsNotificationRequired = 1)
) A
INNER JOIN CWI_User U (NOLOCK)
	ON U.Id = A.UserID
	AND ISNULL(Email,'''') <> ''''
' 
END
GO


