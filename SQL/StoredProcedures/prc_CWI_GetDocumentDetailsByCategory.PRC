IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentDetailsByCategory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDocumentDetailsByCategory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentDetailsByCategory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetDocumentDetailsByCategory  
* Purpose : This PROC would be called to get all the document details based on Category 
* Invoked from : ManageSupportingDoc.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetDocumentDetailsByCategory] @ObjectId=1, @ObjectLookupID =201,@AuthorID=8
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetDocumentDetailsByCategory] 
	@ObjectId int,
	@ObjectLookupID int,
	@AuthorId int
	
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
		SD.Id,
		SD.Title,
		SD.ObjectID,
		SD.ObjectLookupID as CategoryID,
		ISNULL(DocCategoryId,0) DocCategoryId,
		LU.LookupName as ''DocumentCategory'',
		U.Names as ''Author'',
		SD.[Version],
		SD.Summary,
		SD.IsShared,
		SD.FilePath,
		SD.CreatedOn,
		SD.ModifiedBy,
		SD.ModifiedOn,
		SD.CreatedBy AuthorID,
		ISNULL(Tags,'''') Tags
		
	FROM 
		CWI_SupportingDocument AS SD 
		INNER JOIN CWI_User AS U
			ON SD.CreatedBy=U.ID 
		LEFT JOIN CWI_DocCategory DC
			ON DC.Id = SD.DocCategoryId
		LEFT JOIN [Lookup] as  LU 
			ON DC.DoctypeLookupID=LU.Id
	WHERE
		SD.ObjectLookupID= @ObjectLookupID
		AND SD.ObjectID= @ObjectId
		AND SD.IsDelete=0
	ORDER BY SD.ModifiedOn DESC
END


' 
END
GO
