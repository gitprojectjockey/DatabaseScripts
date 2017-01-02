SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_GetMessageTags]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_GetMessageTags]
GO

CREATE PROC prc_ClientPortal_GetMessageTags
    @MessageID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

   SELECT MT.ID, MT.SearchTag, MT.IsSystemTag
   FROM CWI_MessageTag MT
   WHERE MT.MessageID = @MessageID
   ORDER BY MT.SearchTag
  
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH