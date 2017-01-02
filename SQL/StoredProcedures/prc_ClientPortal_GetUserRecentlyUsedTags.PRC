SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetUserRecentlyUsedTags]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetUserRecentlyUsedTags]
GO

CREATE PROC prc_ClientPortal_GetUserRecentlyUsedTags
    @UserID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

WITH MessageList As
 (SELECT M.ID
  FROM CWI_Message M
  WHERE M.ParentMessageID IS NULL
  AND ((M.SourceUserID = @UserID AND M.SourceIsClient = 1) OR
        EXISTS ( Select 1 FROM CWI_MessageRecipient MR
		         WHERE MR.MessageID = M.ID
				 AND MR.RecipientUserID = @UserID
				 AND MR.RecipientIsClient = 1))

  UNION ALL

  SELECT R.ID
  FROM CWI_Message R
  INNER JOIN MessageList ON R.ParentMessageID = MessageList.ID
  WHERE R.ParentMessageID IS NOT NULL
  )
  
 SELECT DISTINCT TOP 10 
       MT.[Id]
      ,MT.[MessageID]
      ,MT.[SearchTag]
      ,MT.[IsSystemTag]
      ,MT.[CreatedOn]
 FROM CWI_MessageTag MT
 WHERE MT.[MessageID] IN ( SELECT ID FROM MessageList)
 ORDER BY MT.[CreatedOn] DESC  
  
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH