/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUserGroupByUser]    Script Date: 10/15/2013 3:53:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetUserGroupByUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetUserGroupByUser]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUserGroupByUser]    Script Date: 10/15/2013 3:53:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetUserGroupByUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetUserGroupByUser
* Purpose : This PROC would be called TO get groupwise Users
* Invoked from : Add Assignee.ascx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetUserGroupByUser @userid=,@groupId= 
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetUserGroupByUser] 
@UserId int,
@GroupId INT	
AS
BEGIN
	SELECT top 1
		G.Id as GroupId,
		U.Id as UserId,
		U.Names as UserName,
		G.GroupName,
		UG.ID as UserGroupID
	FROM 
		CWI_UserGroup UG 	
	INNER JOIN
		CWI_Group G ON UG.GroupID=G.Id
	INNER JOIN
		CWI_User U ON UG.UserID=U.Id  WHERE UG.UserID=@UserId AND UG.GroupID=@GroupId;
	
END
' 
END
GO
