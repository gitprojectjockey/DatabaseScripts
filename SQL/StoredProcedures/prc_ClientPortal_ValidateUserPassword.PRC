SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_ValidateUserPassword]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_ValidateUserPassword]
GO

CREATE PROC prc_ClientPortal_ValidateUserPassword
    @UserID int
   ,@Password varchar(50)
   ,@ErrorMessage varchar(500) OUT
AS

DECLARE 
  @PassPhrase varchar(50)
  
SET NOCOUNT ON;

BEGIN TRY

	SELECT @PassPhrase = PasswordPassPhrase
	FROM [dbo].CWI_PasswordRule
	
	SELECT ID UserID
        FROM CWI_ClientContactPortal
	WHERE ID = @UserID
	AND Convert(varchar,DECRYPTBYPASSPHRASE(@PassPhrase,Password)) = @Password
	
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO
