SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetMessageAttachment]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetMessageAttachment]
GO

CREATE PROC prc_ClientPortal_GetMessageAttachment
    @MessageAttachmentID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

   SELECT ID, MessageID, FileName, AttachmentFilePath 
   FROM CWI_MessageAttachment
   WHERE ID = @MessageAttachmentID
  
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH