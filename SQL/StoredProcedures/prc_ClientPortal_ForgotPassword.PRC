SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_ForgotPassword]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_ForgotPassword]
GO

CREATE PROC prc_ClientPortal_ForgotPassword
    @Email     varchar(100)
   ,@Password  varchar(50)
   ,@ErrorMessage varchar(500) OUT
AS

DECLARE  @UserID int
        ,@PassPhrase varchar(50)

SET NOCOUNT ON;
BEGIN TRANSACTION

BEGIN TRY

       /* Get Pass Phrase */
	SELECT @PassPhrase = PasswordPassPhrase
        FROM [dbo].CWI_PasswordRule
        
        SELECT @UserID = ID
	FROM [dbo].CWI_ClientContactPortal
	WHERE Email = @Email
	
	UPDATE [dbo].CWI_ClientContactPortal
	SET Password = ENCRYPTBYPASSPHRASE(@PassPhrase,@Password)
	   ,PasswordChangeDate = GetDate()
	   ,IsPasswordReset = 1
	   ,LoginAttempts = 0
	   ,IsExpired = 0
	   ,IsLocked = 0
	   ,ClientModifiedBy = @UserID
	   ,ClientModifiedOn = GetDate()
	WHERE Email = @Email
	
	COMMIT  TRANSACTION;
   
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
  ROLLBACK TRANSACTION;
END CATCH

GO
