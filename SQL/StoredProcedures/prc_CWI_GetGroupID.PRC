IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetGroupID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetGroupID]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetGroupID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetGroupID  
* Purpose : This PROC would be called to get all the groupId based groupwise user
* Invoked from : ManageSupportingDoc.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetGroupID] @Group=''IDC''
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetGroupID] 
	-- Add the parameters for the stored procedure here
	@Group varchar(max)
AS
BEGIN

	SELECT 		
		 DISTINCT(gd.GroupId)
	
	FROM 
		Lookup L
	LEFT OUTER JOIN 
		CWI_GroupDocument GD
	ON 
		L.Id = GD.DocCategoryId
	inner join
		CWI_Group G
	On
		g.Id=gd.GroupId 
	AND 
		g.GroupName= @Group;
		
		
END

' 
END
GO


