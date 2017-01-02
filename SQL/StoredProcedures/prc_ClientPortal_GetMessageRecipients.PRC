SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetMessageRecipients]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetMessageRecipients]
GO

CREATE PROC prc_ClientPortal_GetMessageRecipients
    @MessageID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

   SELECT
       [ID]
      ,[MessageID]
      ,[RecipientUserID]
      ,[RecipientIsClient]
      ,dbo.fnc_ClientPortal_GetUserName([RecipientUserID],[RecipientIsClient]) RecipientName
   FROM CWI_MessageRecipient
   WHERE MessageID = @MessageID
   ORDER BY RecipientName
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH