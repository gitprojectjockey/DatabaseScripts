SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_CreateMessageRecipient]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_CreateMessageRecipient]
GO

CREATE PROC [dbo].[prc_ClientPortal_CreateMessageRecipient]
    @MessageID int
   ,@RecipientUserID int
   ,@RecipientIsClient bit
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  INSERT INTO [dbo].[CWI_MessageRecipient]
	([MessageID],
	[RecipientUserID],
	[RecipientIsClient])
   VALUES 
	(@MessageID,
	 @RecipientUserID,
	 @RecipientIsClient)

END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH


GO