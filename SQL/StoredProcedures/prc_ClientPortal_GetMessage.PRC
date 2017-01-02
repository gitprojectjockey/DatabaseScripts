SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetMessage]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetMessage]
GO

CREATE PROC prc_ClientPortal_GetMessage
    @UserID int
   ,@MessageID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  SELECT M.ID
        ,M.ParentMessageID
        ,M.MessageTypeLookupID
        ,M.MessageHeader
        ,M.MessageDetail
        ,M.SourceUserID
        ,M.SourceIsClient
        ,dbo.fnc_ClientPortal_GetUserName(M.SourceUserID, M.SourceIsClient) SentBy
        ,dbo.fnc_ClientPortal_GetRecipientNames(M.ID) RecipientNames
        ,L.LookupName MessageType
        ,M.JobID
        ,M.MarketingPlanID
        ,M.TaskID
        ,M.ClientID
        ,M.CreatedOn
        ,dbo.fnc_ClientPortal_GetRootMessageID(M.ID) AS RootMessageID
        ,A.ArchiveDate
  FROM CWI_Message M
  INNER JOIN Lookup L ON L.ID = M.MessageTypeLookupID
  LEFT JOIN CWI_PortalUserMessageArchive A ON (A.MessageID = dbo.fnc_ClientPortal_GetRootMessageID(M.ID) AND A.PortalUserID = @UserID)
  WHERE M.ID = @MessageID
  
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH