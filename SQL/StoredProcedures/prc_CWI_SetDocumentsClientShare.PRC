

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetDocumentsClientShare]    Script Date: 5/17/2013 5:55:28 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetDocumentsClientShare')
DROP PROCEDURE [dbo].[prc_CWI_SetDocumentsClientShare]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetDocumentsClientShare]    Script Date: 5/17/2013 5:55:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*******************************************************************  
* PROCEDURE: prc_CWI_SetDocumentsClientShare
* Purpose : This PROC would be called to update the documents to sharewith the client
* Invoked from : SupportingDocument.ascx
* CREATED: MohanKumar Sundaram
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
exec [prc_CWI_SetDocumentsClientShare] @DocIds = '87,89,90', @Author = 3
**********************************************************************/ 
CREATE PROCEDURE [dbo].prc_CWI_SetDocumentsClientShare 
	(
				@DocIds varchar(max),
				@Author int
	)
AS
BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @tbl TABLE
		(
			id1 int
		)

		INSERT INTO @tbl
		SELECT CAST(Items as int) FROM dbo.fnc_utl_Split(@DocIds,',') 

		UPDATE [CWI_SupportingDocument] SET IsShared = 1, ModifiedOn=getdate(), ModifiedBy=@Author
		FROM @tbl t
		WHERE  ID = t.id1
	END TRY
		BEGIN CATCH
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
END



GO

