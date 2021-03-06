/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUsersGroups]    Script Date: 10/15/2013 3:53:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetUsersGroups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetUsersGroups]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUsersGroups]    Script Date: 10/15/2013 3:53:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetUsersGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[prc_CWI_GetUsersGroups]
AS

select 
	''G'' + CAST(G.Id as varchar(10)) Id, G.GroupName Name,  NULL ParentId    
from 
  CWI_group G
	WHERE G.IsActive = 1

UNION ALL
	SELECT ''G0'' Id, ''Individual'' Name, NULL

UNION ALL

	select 
		''U'' + CAST(U.Id as varchar(10)) + ''-'' + ''G'' + cast(UG.GroupID as varchar(10)) Id, U.Names   ,  ''G'' + cast(UG.GroupID as varchar(10))
	from CWI_UserGroup UG
	INNER JOIN  CWI_group G
		ON UG.GroupID = G.Id AND G.IsActive = 1
	INNER JOIN  CWI_User U
		ON UG.UserID = U.Id AND U.IsActive = 1
UNION ALL
	SELECT distinct
		''U'' + CAST(U.Id as varchar(10)) + ''-'' + ''G0''  Id, U.Names   , 
		 ''G0''
	FROM 
		CWI_UserGroup UG 	
	INNER JOIN
		CWI_Group G ON UG.GroupID=G.Id AND G.IsActive = 1
	INNER JOIN
		CWI_User U ON UG.UserID=U.Id AND U.IsActive = 1

		


' 
END
GO