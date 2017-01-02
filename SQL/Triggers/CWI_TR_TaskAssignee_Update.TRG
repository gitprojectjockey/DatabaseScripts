/****** Object:  Trigger [CWI_TR_TaskAssignee_Update]    Script Date: 11/8/2013 10:11:59 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_TaskAssignee_Update]'))
DROP TRIGGER [dbo].[CWI_TR_TaskAssignee_Update]
GO

/****** Object:  Trigger [dbo].[CWI_TR_TaskAssignee_Update]    Script Date: 11/8/2013 10:11:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_TaskAssignee_Update]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[CWI_TR_TaskAssignee_Update] ON [dbo].[CWI_TaskAssignee]
 AFTER Update
 NOT FOR REPLICATION AS
 SET NoCount On 

DECLARE @AuditTime DATETIME
SET @AuditTime = GetDate()

 Begin Try 
	IF UPDATE(UserId) OR UPDATE(GroupId) OR UPDATE(IsRemoved)

		INSERT [CWI_History_TaskAssignee]
		   ( 
			TaskAssigneeId,
			OldUserId,
			NewUserId,
			OldGroupId,
			NewGroupId,
			OldIsRemoved,
			NewIsRemoved,
			IsCopied,
			ModifiedBy,
			ModifiedOn,
			NewModifiedBy
		   )
		   SELECT 
				Inserted.[Id],
				Deleted.UserId,
				inserted.UserId,
				Deleted.GroupId,
				inserted.GroupId,
				Deleted.IsRemoved,
				inserted.IsRemoved,
				Deleted.IsCopied,
				Deleted.ModifiedBy,
				--Deleted.ModifiedOn,
				getdate(),
				inserted.ModifiedBy  
			FROM Inserted
             JOIN Deleted
               ON Inserted.[Id] = Deleted.[Id]
               AND
			   ( isnull(Inserted.UserId,'''') <> isnull(Deleted.UserId,'''')
			   OR isnull(Inserted.GroupId,'''') <> isnull(Deleted.GroupId,'''')
			   OR isnull(Inserted.IsRemoved,'''') <> isnull(Deleted.IsRemoved,'''')
			  )
		
 End Try 
 Begin Catch 
   Raiserror(''error in [dbo].[CWI_TR_TaskAssignee_Update] trigger'', 16, 1 ) with log
 End Catch' 
GO


