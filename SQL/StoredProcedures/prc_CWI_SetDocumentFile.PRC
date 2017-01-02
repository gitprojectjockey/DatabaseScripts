

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetDocumentFile]    Script Date: 5/17/2013 5:55:02 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetDocumentFile')
DROP PROCEDURE [dbo].[prc_CWI_SetDocumentFile]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetDocumentFile]    Script Date: 5/17/2013 5:55:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_SetDocumentFile  
* Purpose : This PROC would be called to update the document's file 
* Invoked from : SupportingDocamument.ascx
* CREATED: MohanKumar Sundar
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetDocumentFile]  @DocTypeId=85,@FilePath='c:\test'
**********************************************************************/ 
CREATE PROCEDURE prc_CWI_SetDocumentFile 
(
	@DocId INT,
	@FilePath VARCHAR(1000)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	

	  UPDATE [CWI_SupportingDocument]
			   SET [FilePath] = @FilePath
		WHERE
			Id = @DocId
		
SET NOCOUNT OFF;


END

GO
