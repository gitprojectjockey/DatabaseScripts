SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_ArchiveMessage]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_ArchiveMessage]
GO

CREATE PROC prc_ClientPortal_ArchiveMessage
    @UserID int
   ,@RootMessageID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  INSERT INTO CWI_PortalUserMessageArchive (PortalUserID, MessageID, ArchiveDate)
  VALUES (@UserID, @RootMessageID, GetDate())
	
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO
