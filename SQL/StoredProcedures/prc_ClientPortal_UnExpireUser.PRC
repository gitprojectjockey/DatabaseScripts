SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_UnExpireUser]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_UnExpireUser]
GO

CREATE PROC prc_ClientPortal_UnExpireUser
    @UserID int
   ,@AppUserID  int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRANSACTION
BEGIN TRY
	UPDATE CWI_ClientContactPortal
	SET IsExpired = 0
	   ,IsPasswordReset = 1
	   ,ClientModifiedBy = @AppUserID
	   ,ClientModifiedOn = GetDate()
	WHERE ID = @UserID
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
  ROLLBACK TRANSACTION
END CATCH

GO
