/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUserGroups]    Script Date: 10/15/2013 3:53:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetUserGroups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetUserGroups]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUserGroups]    Script Date: 10/15/2013 3:53:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetUserGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetUserGroups 
* Purpose : This PROC would be called TO get groupwise Users
* Invoked from : Add Assignee.ascx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetUserGroups 
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetUserGroups] 
	
AS
BEGIN
	SELECT 
		G.Id as GroupId,
		U.Id as UserId,
		U.Names as UserName,
		G.GroupName,
		UG.ID as UserGroupID
	FROM 
		CWI_UserGroup UG 	
	INNER JOIN
		CWI_Group G ON UG.GroupID=G.Id AND G.IsActive = 1
	INNER JOIN
		CWI_User U ON UG.UserID=U.Id AND U.IsActive = 1
	
	

END

' 
END
GO
