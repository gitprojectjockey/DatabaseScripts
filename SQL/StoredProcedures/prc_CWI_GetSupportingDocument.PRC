IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetSupportingDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetSupportingDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetSupportingDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



/*******************************************************************  
* PROCEDURE: prc_CWI_GetSupportingDocument  
* Purpose : This PROC would be called TO get the supporting document for Id
* Invoked from : SupportingDocument.ascx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
prc_CWI_GetSupportingDocument	1
**********************************************************************
*/

CREATE PROCEDURE [dbo].[prc_CWI_GetSupportingDocument]
	@ID int
AS
	SELECT 
		SD.Id,
		SD.Title,
		SD.ObjectID,
		SD.ObjectLookupID as CategoryID,
		DocCategoryId,
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
	SD.Id = @ID
	AND SD.IsDelete=0



' 
END
GO
