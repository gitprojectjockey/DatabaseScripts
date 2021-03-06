/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTasks]    Script Date: 7/10/2014 6:59:26 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTasks]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTasks]    Script Date: 7/10/2014 6:59:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTasks]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetTasks
* Purpose : This PROC would be called TO get the task details for task
* Invoked from : Child/Tasks.aspx
* CREATED: Mohankumar Sundaram  23 OCT 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTasks 1
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetTasks]
	@TaskId bigint = 0
AS
	SELECT 
		t.* ,
		UA.Names CreatedUser,
		UA.Email AuthorEmail,
		UM.Names ModifiedUser,
		LS.LookupName [Status],
		LP.LookupName [Priority]
	FROM CWI_Task t
	INNER JOIN Lookup LS
	ON LS.Id = t.StatusLookupId
	INNER JOIN Lookup LP
	ON LP.Id = t.PriorityLookupId
	INNER JOIN CWI_User UA
	ON UA.Id = t.CreatedBy
	INNER JOIN CWI_User UM
	ON UM.Id = t.ModifiedBy
	WHERE t.Id = CASE WHEN @TaskId = 0 THEN t.Id ELSE @TaskId END



' 
END
GO


