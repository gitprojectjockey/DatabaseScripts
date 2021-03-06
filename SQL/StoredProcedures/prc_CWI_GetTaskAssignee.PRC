/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskAssignee]    Script Date: 10/29/2013 1:47:47 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskAssignee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskAssignee]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskAssignee]    Script Date: 10/29/2013 1:47:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskAssignee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*******************************************************************  
* PROCEDURE: prc_CWI_GetTaskAssignee
* Purpose : This PROC would be called TO get the assigness for task
* Invoked from : Child/Tasks.aspx
* CREATED: Mohankumar Sundaram  23 OCT 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTaskAssignee 1
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetTaskAssignee]
	@TaskId bigint
AS
	SELECT 
		
		UserId,
		GroupId,
		U.Names UserName,
		G.GroupName,
		IsCopied,
		IsRemoved,
		TA.CreatedBy,
		TA.CreatedOn,
		TA.ModifiedBy,
		TA.ModifiedOn 
	FROM  CWI_TaskAssignee TA
	LEFT OUTER JOIN CWI_User U ON U.id = TA.UserId
	LEFT OUTER JOIN CWI_Group G ON G.id = TA.GroupId
	WHERE TaskId = @TaskId
	AND TA.IsRemoved = 0

' 
END
GO
