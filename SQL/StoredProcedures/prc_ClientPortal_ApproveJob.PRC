SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_ApproveJob]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_ApproveJob]
GO

CREATE PROC [dbo].[prc_ClientPortal_ApproveJob]
    @UserID int
   ,@JobID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  UPDATE CWI_Job
  SET ApprovedDate =  GetDate()
     ,ApprovedByPortalUserID = @UserID
  WHERE ID = @JobID
 
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO