

/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteService]    Script Date: 4/25/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_DeleteService')
DROP PROCEDURE [dbo].[prc_CWI_DeleteService]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteService]    Script Date: 4/25/2013 2:39:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteService 
* Purpose : This PROC would be called to delete the service 
* Invoked from : Service.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_DeleteService 1 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_DeleteService]       
@inServiceId int,
@inUserId int,
@inRowCount int OUTPUT  
AS
BEGIN

	BEGIN TRY
		IF (SELECT [ServiceLastUsed] FROM [dbo].[CWI_Service] WHERE [Id]=@inServiceId) IS NULL
		BEGIN
			UPDATE [dbo].[CWI_Service]
			SET IsDeleted=1,ModifiedOn=GETDATE(),ModifiedBy=@inUserId
			WHERE Id=@inServiceId
		END
		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO

