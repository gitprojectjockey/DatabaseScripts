IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentDetailsByObject]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDocumentDetailsByObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentDetailsByObject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetDocumentDetailsByObject  
* Purpose : This PROC would be called to get all the document details for Object 
* Invoked from : SupportingDocument.ascx
* CREATED: MohanKumar Sundaram
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetDocumentDetailsByObject] @ObjectId=4, @ObjectLookupID =201,@AuthorID=8
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetDocumentDetailsByObject] 
	@ObjectId bigint,
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
		SD.DocCategoryId,
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
		LU.Id as LookupId,
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
