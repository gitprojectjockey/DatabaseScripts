

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMenuActivitiesByGroupId]    Script Date: 4/25/2013 2:31:27 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetMenuActivitiesByGroupId')
DROP PROCEDURE [dbo].[prc_CWI_GetMenuActivitiesByGroupId]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMenuActivitiesByGroupId]    Script Date: 4/25/2013 2:31:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_GetMenuActivitiesByGroupId  
* Purpose : This PROC would be called TO get all the menu activities of the group
* Invoked from : Groups.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetMenuActivitiesByGroupId @GroupId = 1
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetMenuActivitiesByGroupId] 
    @GroupId int  
AS


SELECT MA.Id MenuActivityId,M.Id MenuId, MA.ActivityId
	, GA.Id GroupActivityId, GA.IsRead IsActivityRead, GA.IsReadWrite IsActivityReadWrite, GA.IsDelete IsActivityDelete
	, A.ActivityName
FROM CWI_Menu M
	LEFT OUTER JOIN CWI_MenuActivity MA
	ON M.Id = MA.MenuId  
	LEFT OUTER JOIN CWI_GroupActivity GA ON GA.ActivityId = MA.ActivityId AND GA.GroupId = @GroupId
	LEFT OUTER JOIN CWI_Activity A ON A.Id = MA.ActivityId and A.IsActive = 1


	
RETURN 0 


GO

