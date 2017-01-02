SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetUserMessagesByTag]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetUserMessagesByTag]
GO

CREATE PROC prc_ClientPortal_GetUserMessagesByTag
    @UserID int
   ,@SearchTag varchar(50)
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

SELECT M.ID
      ,NULL AS ParentMessageID
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
  WHERE EXISTS (SELECT 1 FROM CWI_MessageTag MT 
                WHERE MT.MessageID = M.ID
                AND MT.SearchTag Like @SearchTag + '%')
  AND ((M.SourceUserID = @UserID AND M.SourceIsClient = 1) OR
        EXISTS ( Select 1 FROM CWI_MessageRecipient MR
		         WHERE MR.MessageID = M.ID
				 AND MR.RecipientUserID = @UserID
				 AND MR.RecipientIsClient = 1))
  ORDER BY M.ID				 
 
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH