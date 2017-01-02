/****** Object:  Trigger [CWI_TR_Task_Insert]    Script Date: 11/8/2013 10:10:21 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_Task_Insert]'))
DROP TRIGGER [dbo].[CWI_TR_Task_Insert]
GO

/****** Object:  Trigger [dbo].[CWI_TR_Task_Insert]    Script Date: 11/8/2013 10:10:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_Task_Insert]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[CWI_TR_Task_Insert] ON [dbo].[CWI_Task]
 AFTER	 INSERT
AS 
BEGIN
	IF @@ROWCOUNT = 0 RETURN;
	INSERT INTO CWI_History_Task
	(TaskId,
	OldSubject,
	NewSubject,
	OldStatusLookupId,
	NewStatusLookupId,
	OldPriorityLookupId,
	NewPriorityLookupId,
	OldDueDate,
	NewDueDate,
	OldIsNotificationRequired,
	NewIsNotificationRequired,
	ModifiedBy,
	ModifiedOn
	)
	SELECT 
	i.Id,
	[Subject],
	NULL,
	StatusLookupId,
	NULL,
	PriorityLookupId,
	NULL,
	DueDate,
	NULL,
	IsNotificationRequired,
	NULL,
	ModifiedBy,
	ModifiedOn 
	FROM inserted i
	WHERE i.[Id] is not null
END
' 
GO


