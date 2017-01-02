IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDocumentHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDocumentHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetDocumentHistory 
* Purpose : This PROC would be called to Get the document Version History
* Invoked from : ManageSupportingDoc.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_GetDocumentHistory] @DocId=44

**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetDocumentHistory] 	
	(@DocId INT)
AS
BEGIN
	BEGIN TRY	
		SET NOCOUNT ON;
		IF(@DocId=0)
			THROW 50000,''No Records Found'',11
		ELSE
		 SELECT 
				HSD.[ID],
				HSD.Title,	
				HSD.DocCategoryId,			
				LU.LookupName as ''Category''
			  ,HSD.[Summary]
			  ,HSD.[Version]
    		  ,HSD.[ModifiedOn]
    		  ,U.Names as ''ModifiedBy''
    		  ,HSD.[FilePath]
			  ,LU.Id as LookupId
		  FROM 
				[dbo].[CWI_History_SupportingDocument] HSD 
				INNER JOIN [dbo].[CWI_User] U
					ON HSD.ModifiedBy=U.Id
				INNER JOIN CWI_DocCategory DC
					ON DC.Id = HSD.DocCategoryId
				INNER JOIN [Lookup] as  LU 
					ON DC.DoctypeLookupID=LU.Id

		  WHERE
			HSD.SupportingDocumentId = @DocId;

	END TRY

	BEGIN CATCH

		EXEC prc_CWI_AppRaiseError; 

		THROW;

	END CATCH

END



' 
END
GO
