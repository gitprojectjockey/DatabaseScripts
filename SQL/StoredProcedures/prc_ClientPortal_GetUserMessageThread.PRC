SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetUserMessageThread]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetUserMessageThread]
GO

CREATE PROC prc_ClientPortal_GetUserMessageThread
    @UserID int
   ,@MessageID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

WITH MessageList As
 (SELECT M.ID
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
        ,M.CreatedOn
        ,dbo.fnc_ClientPortal_GetRootMessageID(M.ID) AS RootMessageID
        ,A.ArchiveDate
  FROM CWI_Message M
  INNER JOIN Lookup L ON L.ID = M.MessageTypeLookupID
  LEFT JOIN CWI_PortalUserMessageArchive A ON (A.MessageID = dbo.fnc_ClientPortal_GetRootMessageID(M.ID) AND A.PortalUserID = @UserID)
  WHERE M.ID = @MessageID
  AND ((M.SourceUserID = @UserID AND M.SourceIsClient = 1) OR
        EXISTS ( Select 1 FROM CWI_MessageRecipient MR
		         WHERE MR.MessageID = M.ID
				 AND MR.RecipientUserID = @UserID
				 AND MR.RecipientIsClient = 1))

  UNION ALL

  SELECT R.ID
        ,R.ParentMessageID
        ,R.MessageTypeLookupID
        ,R.MessageHeader
        ,R.MessageDetail
        ,R.SourceUserID
        ,R.SourceIsClient
        ,dbo.fnc_ClientPortal_GetUserName(R.SourceUserID, R.SourceIsClient) SentBy
        ,dbo.fnc_ClientPortal_GetRecipientNames(R.ID) RecipientNames
        ,L.LookupName MessageType
        ,R.JobID
        ,R.MarketingPlanID
        ,R.TaskID
        ,R.CreatedOn
        ,dbo.fnc_ClientPortal_GetRootMessageID(R.ID) AS RootMessageID
        ,MessageList.ArchiveDate
  FROM CWI_Message R
  INNER JOIN Lookup L ON L.ID = R.MessageTypeLookupID
  INNER JOIN MessageList ON R.ParentMessageID = MessageList.ID
  WHERE R.ParentMessageID IS NOT NULL
  )
  
  SELECT * FROM MessageList
  ORDER BY ID
  
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH