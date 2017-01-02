SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_UpdateMessageTag]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_UpdateMessageTag]
GO

CREATE PROC [dbo].[prc_ClientPortal_UpdateMessageTag]
    @ID int
   ,@SearchTag varchar(100)
   ,@IsSystemTag bit
   ,@CreatedBy int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  UPDATE
   [dbo].[CWI_MessageTag] 
  SET
	[SearchTag] =  @SearchTag,
	[CreatedBy] = @CreatedBy,
	[CreatedOn] = getdate()
   WHERE 
	ID = @ID
   AND
    IsSystemTag = @IsSystemTag

END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO