IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetDocumentTags]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetDocumentTags]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetDocumentTags]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[prc_CWI_SetDocumentTags] 
(
	@DocId INT,
	@Tags VARCHAR(MAX)
)
AS
BEGIN

	  UPDATE [CWI_SupportingDocument]
			   SET [Tags] = @Tags
		WHERE
			Id = @DocId
END
' 
END
