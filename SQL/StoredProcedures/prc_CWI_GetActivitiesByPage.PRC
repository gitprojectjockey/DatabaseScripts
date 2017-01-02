IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetActivitiesByPage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetActivitiesByPage]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetActivitiesByPage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetActivitiesByPage  
* Purpose : This PROC would be called TO get all the activity details for the passed page 
* Invoked from : All pages where activities for pages are available
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetActivitiesByPage @groups=''IDC,IDC1'', @Page = ''client.aspx''
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetActivitiesByPage]
	@Groups VARCHAR(MAX),
	@Page VARCHAR(300)
AS
	SELECT
		A.Id, A.ActivityName, A.ActivityLocation, A.ActivityPage,A.ActivityImage,A.IsFeature,
		CASE WHEN t.IsDelete >0 THEN ''D'' WHEN t.IsReadWrite > 0 THEN ''RW'' WHEN t.IsRead > 0 THEN ''R'' ELSE '''' END ActivityRights 
	FROM
	(
		SELECT ISNULL(a.ActivityId, b.ActivityId ) ActivityId , IsRead,IsReadWrite, IsDelete FROM
		(
			SELECT 
				GA.ActivityId,  sum(cast(IsRead as int)) IsRead, sum(cast(IsReadWrite as int)) IsReadWrite, sum(cast(IsDelete as int)) IsDelete
			FROM 
				CWI_GroupActivity GA 
				INNER JOIN CWI_Group G ON GA.GroupId = G.Id  and G.IsActive = 1 
					AND GroupName in (select * FROM dbo.fnc_utl_Split(@Groups,'',''))
				INNER JOIN CWI_MenuActivity MA ON MA.ActivityId = GA.ActivityId 
				INNER JOIN CWI_Menu M ON MA.MenuId = M.Id AND M.IsActive = 1 AND M.MenuPage = @Page 
			
			GROUP BY 
				GA.ActivityId
		) a
		FULL OUTER JOIN 
		(			
			SELECT MA.ActivityId FROM CWI_Menu M 
			INNER JOIN CWI_MenuActivity MA ON MA.MenuId = M.Id AND M.IsActive = 1 AND M.MenuPage = @Page 
		) b ON a.ActivityId = b.ActivityId
	)t
	INNER JOIN CWI_Activity A ON t.ActivityId = A.Id and A.IsActive = 1 
	INNER  JOIN CWI_MenuActivity MA ON MA.ActivityId = t.ActivityId
	--WHERE (t.IsDelete + t.IsReadWrite + IsRead) >0
	ORDER BY MA.SortOrder
' 
END
GO


