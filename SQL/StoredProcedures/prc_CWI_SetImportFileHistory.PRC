/****** Object:  StoredProcedure [dbo].[prc_CWI_SetImportFileHistory]    Script Date: 8/26/2014 9:59:40 AM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetImportFileHistory' )
 DROP PROCEDURE [dbo].[prc_CWI_SetImportFileHistory]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetImportFileHistory]    Script Date: 8/26/2014 9:59:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*******************************************************************************************************************************************  
* PROCEDURE: prc_CWI_SetImportFileHistory
* Purpose : This PROC would be called to insert a row into [CWI_ImportFileHistory] table
* Invoked from : <TBD>
* CREATED: Lino Garcia
* MODIFICATION HISTORY  
* DATE            AUTHOR          DESCRIPTION              
  08/19/2014
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_SetImportFileHistory 1,1,null,'DigitalResponse-Nov2014.csv'
********************************************************************************************************************************************/ 
  
ALTER PROCEDURE [dbo].[prc_CWI_SetImportFileHistory]
	@FileID INT,
	@UserID INT,
	@FileName VARCHAR(200)
AS
BEGIN

	BEGIN TRY

		INSERT INTO [dbo].[CWI_ImportFileHistory]
			([FileID]
			,[UserID]
			,[CreatedOn]
			,[FileName])
		VALUES
			(@FileID
			,@UserID
			,GETDATE()
			,@FileName)

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END

