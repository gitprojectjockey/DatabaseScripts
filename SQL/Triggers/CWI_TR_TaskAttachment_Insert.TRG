/****** Object:  Trigger [CWI_TR_TaskAttachment_Insert]    Script Date: 11/8/2013 10:11:59 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_TaskAttachment_Insert]'))
DROP TRIGGER [dbo].[CWI_TR_TaskAttachment_Insert]
GO

/****** Object:  Trigger [dbo].[CWI_TR_TaskAttachment_Insert]    Script Date: 11/8/2013 10:11:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_TaskAttachment_Insert]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[CWI_TR_TaskAttachment_Insert] ON [dbo].[CWI_TaskAttachment]
 AFTER Insert
 NOT FOR REPLICATION AS
 SET NoCount On 

DECLARE @AuditTime DATETIME
SET @AuditTime = GetDate()

 Begin Try 
   INSERT [CWI_History_TaskAttachment]
   ( 
	TaskAttachmentId,
	OldFileName,
	NewFileName,
	OldFilePath,
	NewFilePath,
	OldAttachtomail,
	NewAttachtomail,
	OldIsRemoved,
	NewIsRemoved,
	AuditAction,
	ModifiedBy,
	ModifiedOn
	
   )
   SELECT 
		Inserted.[Id],
		FileName,
		NULL,
		FilePath,
		NULL,
		Attachtomail,
		NULL,
		IsRemoved,
		NULL,
		''Inserted Record'',
		ModifiedBy,
		ModifiedOn
	    
    FROM Inserted
    WHERE Inserted.[Id] is not null

 End Try 
 Begin Catch 
 declare @error varchar(400);
 set @error=ERROR_MESSAGE();
   Raiserror(@error, 16, 1 ) with log
  
 End Catch'
