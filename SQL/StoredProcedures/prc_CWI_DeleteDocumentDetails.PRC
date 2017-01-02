

/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteDocumentDetails]    Script Date: 4/25/2013 2:41:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_DeleteDocumentDetails')
DROP PROCEDURE [dbo].[prc_CWI_DeleteDocumentDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteDocumentDetails]    Script Date: 4/25/2013 2:41:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteDocumentDetail  
* Purpose : This PROC would be called to Remove the document details
* Invoked from : ManageSupportingDoc.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
Declare  @RowCount int
exec [prc_CWI_DeleteDocumentDetails] @ID=1,7, @RowCount= @RowCount output;
 **********************************************************************/

CREATE PROCEDURE [dbo].[prc_CWI_DeleteDocumentDetails]
		@DocumentId int,
		@UserId int,
		@RowCount int output
AS
BEGIN  
	BEGIN TRY
		UPDATE [dbo].[CWI_SupportingDocument]
		SET 
			IsDelete=1,
			[ModifiedBy]=@UserId
		WHERE 
			[Id]=@DocumentId ; 
			 
	SET @RowCount = (SELECT @@ROWCOUNT as RowAffected)
	END TRY

	BEGIN CATCH

		EXEC PRC_CWI_APPRAISEERROR; 
		THROW;

	END CATCH
END

GO

