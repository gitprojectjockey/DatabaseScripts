SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_CreateMessageTag]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_CreateMessageTag]
GO

CREATE PROC [dbo].[prc_ClientPortal_CreateMessageTag]
    @MessageID int
   ,@SearchTag varchar(100)
   ,@IsSystemTag bit
   ,@CreatedBy int
   ,@ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  INSERT INTO [dbo].[CWI_MessageTag]
	([MessageID],
	[SearchTag],
	[IsSystemTag],
	[CreatedBy],
	[CreatedOn])
   VALUES 
	(@MessageID,
	 @SearchTag,
	 @IsSystemTag,
	 @CreatedBy,
	 getdate())

END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH

GO