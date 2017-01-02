SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_DeleteMessageTag]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_DeleteMessageTag]
GO

CREATE PROC [dbo].[prc_ClientPortal_DeleteMessageTag]
    @ID int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  DELETE FROM
  [dbo].[CWI_MessageTag] 
  WHERE ID = @ID
   
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO
