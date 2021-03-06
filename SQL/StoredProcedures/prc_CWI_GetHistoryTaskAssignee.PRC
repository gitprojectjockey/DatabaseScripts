/****** Object:  StoredProcedure [dbo].[prc_CWI_GetHistoryTaskAssignee]    Script Date: 7/10/2014 7:01:37 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetHistoryTaskAssignee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetHistoryTaskAssignee]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetHistoryTaskAssignee]    Script Date: 7/10/2014 7:01:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetHistoryTaskAssignee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetHistoryTaskAssignee
* Purpose : This PROC would be called to return the task assignee history details
* Invoked from : multiple pages
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
  prc_CWI_GetHistoryTaskAssignee  18

**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetHistoryTaskAssignee]
	@TaskId bigint
	
AS
BEGIN
	
SELECT 
	  t.TaskAssigneeId,
	  t.OldIsRemoved,t.NewIsRemoved,
	  t.IsCopied,
	  Us.Names as OldUserName,
	  U.Names as NewUserName,
	  Gr.GroupName as OldGroupName,
	  G.GroupName as NewGroupName,
	  UM.Names ModifiedBy,T.NewModifiedOn
	  FROM CWI_History_TaskAssignee t 
	  INNER JOIN CWI_TaskAssignee ta ON ta.Id=t.TaskAssigneeId 

	  INNER JOIN CWI_User UM ON UM.Id=t.ModifiedBy
	  LEFT OUTER JOIN CWI_User Us ON Us.id = t.OldUserId
	  LEFT OUTER JOIN CWI_User U ON U.id = t.NewUserId
	  LEFT OUTER JOIN CWI_Group Gr ON Gr.id = t.OldGroupId
	  LEFT OUTER JOIN CWI_Group G ON G.id = t.NewGroupId
	  WHERE ta.TaskId = @TaskId ORDER BY t.ID DESC
END



' 
END
GO


