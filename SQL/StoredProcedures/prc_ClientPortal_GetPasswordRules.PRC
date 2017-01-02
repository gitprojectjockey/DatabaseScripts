SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetPasswordRules]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetPasswordRules]
GO

CREATE PROC prc_ClientPortal_GetPasswordRules
   @ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY
	SELECT pr.MaxLoginAttempts
             , pr.MinimumPasswordLength
             , pr.PasswordHistoryEnabled
             , pr.PasswordHistoryCount
             , pr.PasswordExpireEnabled
             , pr.PasswordExpirePeriod
             , pr.UserInactiveEnabled
             , pr.UserInactivePeriod
        FROM CWI_PasswordRule pr
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO