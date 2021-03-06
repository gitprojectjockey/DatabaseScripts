/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobAssigneeIDByUser]    Script Date: 10/15/2013 3:53:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobAssigneeIDByUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobAssigneeIDByUser]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobAssigneeIDByUser]    Script Date: 10/15/2013 3:53:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobAssigneeIDByUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobAssigneeIDByUser
* Purpose : This PROC would be called TO get assigness for Job
* Invoked from : Add Assignee.ascx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetJobAssigneeIDByUser @JobID=80
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetJobAssigneeIDByUser] 
	@UserID int ,
	@GroupID Int,
	@JobID INT
AS
BEGIN
	SELECT 
		distinct ID,
		GroupId,
		ISNULL(UserId,0) as UserId,
		'''' as UserName,
		'''' as GroupName,
		IsCC
	FROM 
		CWI_JobAssignee 
			
	Where JobID=@JobID AND GroupId=@GroupID AND USERID=@UserID and IsAssigned=1;
	
END
' 
END
GO
