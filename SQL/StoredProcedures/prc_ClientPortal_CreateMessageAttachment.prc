SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_CreateMessageAttachment]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_CreateMessageAttachment]
GO

CREATE PROC [dbo].[prc_ClientPortal_CreateMessageAttachment]
	@MessageID int
       ,@FileName  varchar(100)
       ,@AttachmentFilePath varchar(500)
       ,@CreatedAttachmentID int OUT
       ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

DECLARE @Identity int

BEGIN TRY

  INSERT INTO [dbo].[CWI_MessageAttachment]
	(MessageID,
	 FileName,
	 AttachmentFilePath)
   VALUES 
	(@MessageID,
	 @FileName,
	 @AttachmentFilePath)

	SELECT @CreatedAttachmentID = SCOPE_IDENTITY()
	

END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH


GO