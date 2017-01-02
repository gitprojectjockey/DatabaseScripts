SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetUserArchives]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetUserArchives]
GO

CREATE PROC prc_ClientPortal_GetUserArchives
    @UserID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  SELECT DISTINCT TOP 6 Convert( varchar, DATENAME(mm, M.CreatedOn) + ' ' + DATENAME(yyyy, M.CreatedOn)) Created
  FROM CWI_Message M
  INNER JOIN CWI_PortalUserMessageArchive PA ON PA.MessageID = M.ID
  WHERE PA.PortalUserID = @UserID
  ORDER BY Created DESC
	
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO
