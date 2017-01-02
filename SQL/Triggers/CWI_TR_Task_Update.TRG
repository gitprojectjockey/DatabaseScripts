/****** Object:  Trigger [CWI_TR_Task_Update]    Script Date: 11/8/2013 10:11:09 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_Task_Update]'))
DROP TRIGGER [dbo].[CWI_TR_Task_Update]
GO

/****** Object:  Trigger [dbo].[CWI_TR_Task_Update]    Script Date: 11/8/2013 10:11:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_Task_Update]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[CWI_TR_Task_Update] ON [dbo].[CWI_Task]
 AFTER	UPDATE
AS 

	
	BEGIN TRY
	IF UPDATE(Subject) OR UPDATE(StatusLookupId) OR UPDATE(PriorityLookupId) OR UPDATE(DueDate) OR UPDATE(IsNotificationRequired)
		INSERT INTO CWI_History_Task(TaskId,OldSubject,NewSubject,OldStatusLookupId,NewStatusLookupId,OldPriorityLookupId,
		NewPriorityLookupId,OldDueDate,NewDueDate,OldIsNotificationRequired,NewIsNotificationRequired,ModifiedBy,ModifiedOn)
		SELECT d.Id,d.[Subject],i.[Subject],d.StatusLookupId,i.StatusLookupId,
		d.PriorityLookupId,i.PriorityLookupId,d.DueDate,i.DueDate,d.IsNotificationRequired,i.IsNotificationRequired,
		i.ModifiedBy,i.ModifiedOn		
		FROM Inserted i
             JOIN Deleted d
               ON i.[Id] = d.[Id]
               AND
			   ( isnull(i.Subject,'''') <> isnull(d.Subject,'''')
			   OR isnull(i.StatusLookupId,'''') <> isnull(d.StatusLookupId,'''')
			   OR isnull(i.PriorityLookupId,'''') <> isnull(d.PriorityLookupId,'''')
			   OR isnull(i.DueDate,'''') <> isnull(d.DueDate,'''')
			   OR isnull(i.IsNotificationRequired,'''') <> isnull(d.IsNotificationRequired,'''')
			  )
	END TRY

 Begin Catch 
   Raiserror(''error in [dbo].[CWI_TR_Task_Update] trigger'', 16, 1 ) with log
 End Catch 
	' 
GO


