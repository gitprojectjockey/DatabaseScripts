IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentTypesByGroupId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDocumentTypesByGroupId]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentTypesByGroupId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetDocumentTypesByGroupId  
* Purpose : This PROC would be called TO get all the document types of the group
* Invoked from : Groups.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetDocumentTypesByGroupId @GroupId = 2
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetDocumentTypesByGroupId] 
    @GroupId int  
AS

-- LookupTypeId is 1 for the supportind documents
SELECT
 
	UID DocTypeId, L.LookupName DocName, ObjectLookupId,
	GD.IsRead, GD.IsReadWrite, GD.IsDelete
	
FROM 
	(
	
	select s.Id, s.UId, DocTypeLookupId , ObjectLookupId, LookupName from 
	(
	select Id,''M'' + cast(Id as varchar(10)) UId,  DocTypeLookupId, ''P'' + cast(ObjectLookupId as varchar(10)) ObjectLookupId  FROM CWI_DocCategory
	where IsActive = 1
	UNION ALL
	select distinct ObjectLookupId Id, ''P'' + cast(ObjectLookupId as varchar(10)) UId,  ObjectLookupId, NULL from CWI_DocCategory
	where IsActive = 1
	) s

	INNER JOIN  Lookup LD ON LD.Id = s.DocTypeLookupID
	) L
	LEFT OUTER JOIN CWI_GroupDocument GD
		ON L.Id = GD.DocCategoryId AND GD.GroupId = @GroupId

RETURN 0 




' 
END
GO


