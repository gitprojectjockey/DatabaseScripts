

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUserSkin]    Script Date: 4/25/2013 2:43:37 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetUserSkin')
DROP PROCEDURE [dbo].[prc_CWI_SetUserSkin]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUserSkin]    Script Date: 4/25/2013 2:43:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_AddUser  
* Purpose : This PROC would be called to update the recently selected theme
* Invoked from : ClientWise.master
* CREATED:  Vijesh
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

DECLARE @inRowCount int
exec prc_CWI_SetUserSkin 7,'Forest', @inRowCount output
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetUserSkin] 	
	@inUserId int,
	@vcSkinValue varchar(50),
	@inRowCount int OUTPUT  	
AS
BEGIN
		 
	BEGIN TRY
		IF NOT EXISTS(SELECT UserID FROM CWI_UserSkin WHERE UserID = @inUserId)
		BEGIN
			INSERT INTO CWI_UserSkin(UserID,SkinValue) VALUES (@inUserId,@vcSkinValue)
		END
		ELSE
		BEGIN
			UPDATE CWI_UserSkin
			SET skinvalue = @vcSkinValue 
			WHERE UserID= @inUserId
		END
		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected) 
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
END


GO

