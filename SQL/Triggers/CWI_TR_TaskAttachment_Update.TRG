/****** Object:  Trigger [CWI_TR_TaskAttachment_Update]    Script Date: 11/8/2013 10:11:59 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_TaskAttachment_Update]'))
DROP TRIGGER [dbo].[CWI_TR_TaskAttachment_Update]
GO

/****** Object:  Trigger [dbo].[CWI_TR_TaskAttachment_Update]    Script Date: 11/8/2013 10:11:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_TaskAttachment_Update]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[CWI_TR_TaskAttachment_Update] ON [dbo].[CWI_TaskAttachment]
 AFTER Update
 NOT FOR REPLICATION AS
 SET NoCount On 

DECLARE @AuditTime DATETIME
SET @AuditTime = GetDate()

 Begin Try 
	IF UPDATE(FileName) OR UPDATE(IsRemoved)

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
				Deleted.FileName,
				inserted.FileName,
				Deleted.FilePath,
				inserted.FilePath,
				deleted.Attachtomail,
				inserted.Attachtomail,
				deleted.IsRemoved,
				inserted.IsRemoved,
				''Updated Record'',
				Deleted.ModifiedBy,
				--Deleted.ModifiedOn
				getdate()
				
			FROM Inserted
             JOIN Deleted
               ON Inserted.[Id] = Deleted.[Id]
               AND
			   (isnull(Inserted.FileName,'''') <> isnull(Deleted.FileName,'''')
			   OR isnull(Inserted.Attachtomail,'''')<>isnull(Deleted.Attachtomail,'''')
			   --OR isnull(Inserted.GroupId,'''') <> isnull(Deleted.GroupId,'''')
			   OR isnull(Inserted.IsRemoved,'''') <> isnull(Deleted.IsRemoved,'''')
			  )
		
 End Try 
 Begin Catch 
   Raiserror(''error in [dbo].[CWI_TR_TaskAttachment_Update] trigger'', 16, 1 ) with log
 End Catch'
