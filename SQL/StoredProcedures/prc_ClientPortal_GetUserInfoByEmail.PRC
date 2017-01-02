SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetUserInfoByEmail]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetUserInfoByEmail]
GO

CREATE PROC prc_ClientPortal_GetUserInfoByEmail
    @Email varchar(100)
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY
	SELECT  CWP.Email UserEmail
               ,CWP.LastLoginDate
               ,CWP.IsPasswordReset
	       ,C.ID ClientID
               ,C.ClientName
	       ,CC.Name UserName
        FROM CWI_ClientContactPortal CWP
        INNER JOIN CWI_ClientContact CC
        ON CWP.Email = CC.Email
        INNER JOIN CWI_Client C
        ON C.ID = CC.ClientID
        WHERE CC.IsDeleted = 0
        AND CC.IsCWPortalUser = 1
        AND CWP.Email = @Email
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO
