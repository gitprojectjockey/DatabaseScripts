/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDocumentCategories]    Script Date: 1/14/2014 10:37:43 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentCategories]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDocumentCategories]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDocumentCategories]    Script Date: 1/14/2014 10:37:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentCategories]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  

* PROCEDURE: prc_CWI_GetDocumentCategories 
* Purpose : This PROC would be called to Get the document Category 
* Invoked from : ManageSupportingDoc.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
14MAY13		MohanKumar		Modified to get the documents based on groups
**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_GetDocumentCategories] @ObjectLookupId=203, @Groups = ''IDC,IDC1''

**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetDocumentCategories] 
	@ObjectLookupId Int,
	@Groups varchar(max)
AS
BEGIN
BEGIN TRY
	SELECT
		DC.Id, L.LookupName ''DocumentCategory'',
		CASE WHEN t.IsDelete >0 THEN ''D'' WHEN t.IsReadWrite > 0 THEN ''RW'' WHEN t.IsRead > 0 THEN ''R'' ELSE '''' END Rights 
	FROM
	(
		SELECT 
			GD.DocCategoryId,  sum(cast(IsRead as int)) IsRead, sum(cast(IsReadWrite as int)) IsReadWrite, sum(cast(IsDelete as int)) IsDelete
		FROM 
			CWI_GroupDocument GD
			INNER JOIN CWI_Group G ON GD.GroupId = G.Id  and G.IsActive = 1 
				AND GroupName in (select * FROM dbo.fnc_utl_Split(@Groups,'',''))
		GROUP BY 
			GD.DocCategoryId
	)t
	LEFT JOIN CWI_DocCategory DC ON t.DocCategoryId = DC.Id and DC.IsActive = 1 AND DC.ObjectLookupId=@ObjectLookupId
	LEFT JOIN Lookup  L ON DC.DocTypeLookupID = L.Id and L.IsActive = 1 AND L.[LookupTypeId] = 1
	WHERE (t.IsDelete + t.IsReadWrite + IsRead) >0

END TRY
BEGIN CATCH

		EXEC prc_CWI_AppRaiseError;  

		THROW; 
END CATCH
END







' 
END
GO


