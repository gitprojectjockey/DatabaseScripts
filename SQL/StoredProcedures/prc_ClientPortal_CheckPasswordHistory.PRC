SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_CheckPasswordHistory]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_CheckPasswordHistory]
GO

CREATE PROC prc_ClientPortal_CheckPasswordHistory
   @UserID int
  ,@Password varchar(50)
  ,@ErrorMessage varchar(500) OUT
AS
DECLARE 
 @PassPhrase varchar(50)
 
SET NOCOUNT ON;

BEGIN TRY

	SET @PassPhrase = (SELECT PasswordPassPhrase
        FROM [dbo].[CWI_PasswordRule])
                	
	SELECT ID
        FROM [CWI_History_PortalUserPassword]
        WHERE PortalUserID = @UserID
        AND DECRYPTBYPASSPHRASE(@PassPhrase,Password) = @Password  
        
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO