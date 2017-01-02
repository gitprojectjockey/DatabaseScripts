IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocsByGroups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDocsByGroups]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocsByGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetDocsByGroups  
* Purpose : This PROC would be called TO get all the document types for the passed groups 
* Invoked from : ManageSupportingDoc.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetDocsByGroups] @groups=''IDC,IDC1'' 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetDocsByGroups]
	@Groups VARCHAR(MAX)
AS
	SELECT
		L.Id, L.LookupName,
		CASE WHEN t.IsDelete >0 THEN ''D'' WHEN t.IsReadWrite > 0 THEN ''RW'' WHEN t.IsRead > 0 THEN ''R'' ELSE '''' END ActivityRights 
	FROM
	(
		SELECT 
			GD.DocCategoryId DocCategoryId,  sum(cast(IsRead as int)) IsRead, sum(cast(IsReadWrite as int)) IsReadWrite, sum(cast(IsDelete as int)) IsDelete
		FROM 
			CWI_GroupDocument GD
			INNER JOIN CWI_Group G ON GD.GroupId = G.Id  and G.IsActive = 1 
				AND GroupName in (select * FROM dbo.fnc_utl_Split(@Groups,'',''))
		GROUP BY 
			GD.DocCategoryId
	)t
	INNER JOIN Lookup  L ON t.DocCategoryId = L.Id and L.IsActive = 1 AND L.[LookupTypeId] = 1
	--WHERE (t.IsDelete + t.IsReadWrite + IsRead) >0
	


' 
END
GO
