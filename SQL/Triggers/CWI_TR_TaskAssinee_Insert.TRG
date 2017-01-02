/****** Object:  Trigger [CWI_TR_TaskAssinee_Insert]    Script Date: 11/8/2013 10:12:08 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_TaskAssinee_Insert]'))
DROP TRIGGER [dbo].[CWI_TR_TaskAssinee_Insert]
GO

/****** Object:  Trigger [dbo].[CWI_TR_TaskAssinee_Insert]    Script Date: 11/8/2013 10:12:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_TaskAssinee_Insert]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[CWI_TR_TaskAssinee_Insert] ON [dbo].[CWI_TaskAssignee]
 AFTER Insert
 NOT FOR REPLICATION AS
 SET NoCount On 

DECLARE @AuditTime DATETIME
SET @AuditTime = GetDate()

 Begin Try 
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
		UserId,
		NULL,
		GroupId,
		NULL,
		IsRemoved,
		NULL,
		IsCopied,
		ModifiedBy,
		--ModifiedOn,
		getdate(),
	    inserted.ModifiedBy  
    FROM Inserted
    WHERE Inserted.[Id] is not null

 End Try 
 Begin Catch 
   Raiserror(''error in [dbo].[CWI_TR_TaskAssinee_Insert] trigger'', 16, 1 ) with log
 End Catch ' 
GO


