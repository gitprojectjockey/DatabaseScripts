/****** Object:  StoredProcedure [dbo].[prc_CWI_GetActivitiesByPageWithoutIcons]    Script Date: 6/19/2013 1:48:23 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetActivitiesByPageWithoutIcons')
 DROP PROCEDURE [dbo].[prc_CWI_GetActivitiesByPageWithoutIcons]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetActivitiesByPageWithoutIcons]    Script Date: 6/19/2013 1:48:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetActivitiesByPageWithoutIcons  
* Purpose : This PROC would be called TO get all the activity details for the passed page.
					It will return only those activities from CWI_Activity where IsFeature = 1
						This will be used for example : 
								To show/hide "Activate Client" button
* Invoked from : All pages where activities for pages are available
* CREATED: Ajay Thacker 20-may-2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetActivitiesByPageWithoutIcons @groups='IDC,IDC1', @Page = 'Client.aspx'
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetActivitiesByPageWithoutIcons]
	@Groups VARCHAR(MAX),
	@Page VARCHAR(300)
AS
	SELECT
		A.Id, A.ActivityName, A.ActivityLocation, A.ActivityPage,A.ActivityImage,A.IsFeature,ISNULL(OA.LookupId,'') AS LookupId,
		CASE WHEN t.IsDelete >0 THEN 'D' WHEN t.IsReadWrite > 0 THEN 'RW' WHEN t.IsRead > 0 THEN 'R' ELSE '' END ActivityRights 
	FROM
	(
		SELECT 
			GA.ActivityId,  sum(cast(IsRead as int)) IsRead, sum(cast(IsReadWrite as int)) IsReadWrite, sum(cast(IsDelete as int)) IsDelete
		FROM 
			CWI_GroupActivity GA 
			INNER JOIN CWI_Group G ON GA.GroupId = G.Id  and G.IsActive = 1 
				AND GroupName in (select * FROM dbo.fnc_utl_Split(@Groups,','))
			INNER JOIN CWI_MenuActivity MA ON MA.ActivityId = GA.ActivityId 
			INNER JOIN CWI_Menu M ON MA.MenuId = M.Id AND M.IsActive = 1 AND M.MenuPage = @Page 
		GROUP BY 
			GA.ActivityId
	)t
	INNER JOIN CWI_Activity A ON t.ActivityId = A.Id and A.IsActive = 1 and A.IsFeature=1
	INNER JOIN CWI_MenuActivity MA ON MA.ActivityId = t.ActivityId
	Left Outer JOIN CWI_PageObjectActivity OA ON t.ActivityId=OA.ActivityId
	WHERE (t.IsDelete + t.IsReadWrite + IsRead) >0
	ORDER BY MA.SortOrder


GO
