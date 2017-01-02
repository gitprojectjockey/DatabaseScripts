SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_CreateUserMessage]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_CreateUserMessage]
GO

CREATE PROC [dbo].[prc_ClientPortal_CreateUserMessage]
	@ParentMessageID int = NULL,
	@MessageTypeLookupID  int,
	@MessageHeader varchar (100),
	@MessageDetail varchar (max),
	@SourceUserID  int,
	@SourceIsClient bit,
	@JobID bigint  = NULL,
	@MarketingPlanID int =  NULL,
	@TaskID int = NULL,
	@ClientID int,
	@CreatedMessageID int OUT,
        @ErrorMessage varchar(500) OUT
AS
SET NOCOUNT ON;

BEGIN TRY

  INSERT INTO [dbo].[CWI_Message]
	(ParentMessageID,
	 MessageTypeLookupID,
	 MessageHeader,
	 MessageDetail,
	 SourceUserID,
	 SourceIsClient,
	 JobID,
	 MarketingPlanID,
	 TaskID,
	 CreatedOn,
	 ClientID)
   VALUES 
	(@ParentMessageID,
	@MessageTypeLookupID,
	@MessageHeader,
	@MessageDetail,
	@SourceUserID,
	@SourceIsClient,
	@JobID,
	@MarketingPlanID,
	@TaskID,
	GetDate(),
	@ClientID)

	SELECT @CreatedMessageID = SCOPE_IDENTITY()
	

END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
END CATCH


GO