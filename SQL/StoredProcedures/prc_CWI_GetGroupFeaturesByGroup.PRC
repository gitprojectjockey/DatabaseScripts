IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetGroupFeaturesByGroup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetGroupFeaturesByGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetGroupFeaturesByGroup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetGroupFeaturesByGroup  
* Purpose : This PROC would be called TO get all the menu of the group
* Invoked from : Groups.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetGroupFeaturesByGroup @Group = ''IDC'', @author=''oss\msundaram''
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetGroupFeaturesByGroup] 
    @Group varchar(max),
	@author varchar(max) 
AS

declare @GroupId int
exec prc_CWI_SetGroup @group=@group, @author =@author, @groupid =@GroupId output

SELECT
 
	''M'' + CAST(M.Id as varchar(10)) ItemId, ''M'' + cast(m.ParentId as varchar(10)) ParentId,M.MenuCaption Caption, GF.Id BridgeId,
	GF.IsRead , GF.IsReadWrite , GF.IsDelete,
	CASE WHEN GF.IsDelete >0 THEN ''D'' WHEN GF.IsReadWrite > 0 THEN ''RW'' WHEN GF.IsRead > 0 THEN ''R'' ELSE ''N'' END Rights,  
	@GroupId GroupId, ''Feature'' Type
	
FROM 
	CWI_Menu M
	LEFT OUTER JOIN CWI_GroupFeature GF
		ON M.Id = GF.MenuId AND M.IsActive = 1 AND GF.GroupId = @GroupId
		
UNION ALL

SELECT ''A'' + CAST(MA.ActivityId as varchar(10)) ItemId, ''M'' + CAST(M.Id as varchar(10)) ParentId, 
    A.ActivityName Caption, GA.Id BridgeId, 
	GA.IsRead , GA.IsReadWrite , GA.IsDelete,
	CASE WHEN GA.IsDelete >0 THEN ''D'' WHEN GA.IsReadWrite > 0 THEN ''RW'' WHEN GA.IsRead > 0 THEN ''R'' ELSE ''N'' END Rights,   
	@GroupId GroupId, CASE IsFeature WHEN 1 THEN ''Area'' ELSE ''Activity'' END Type
FROM CWI_Menu M
	INNER JOIN CWI_MenuActivity MA
	ON M.Id = MA.MenuId  
	LEFT OUTER JOIN CWI_GroupActivity GA ON GA.ActivityId = MA.ActivityId AND GA.GroupId = @GroupId
	LEFT OUTER JOIN CWI_Activity A ON A.Id = MA.ActivityId and A.IsActive = 1

	

' 
END
GO
