/****** Object:  Trigger [CWI_TR_JobService_Update]    Script Date: 7/18/2014 8:29:20 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_JobService_Update]'))
DROP TRIGGER [dbo].[CWI_TR_JobService_Update]
GO

/****** Object:  Trigger [dbo].[CWI_TR_JobService_Update]    Script Date: 7/18/2014 8:29:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_JobService_Update]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[CWI_TR_JobService_Update] ON [dbo].[CWI_JobService]
 AFTER UPDATE
 NOT FOR REPLICATION AS
 SET NOCOUNT On 

DECLARE @jobId bigint

 BEGIN TRY		
	
	/* Update used and committed plan budget in marketing plan*/	
	if exists(select top 1 1 from Inserted join Deleted on Inserted.[Id] = Deleted.[Id] and
			isnull(Inserted.ServiceFee,0) <> isnull(Deleted.ServiceFee,0)
			or isnull(Inserted.IsComplimentary,0) <> isnull(Deleted.IsComplimentary,0)
			or isnull(Inserted.IsDeleted,0) <> isnull(Deleted.IsDeleted,0)
			or isnull(Inserted.StatusLookupId,0) <> isnull(Deleted.StatusLookupId,0))
	begin
		SELECT top 1  @jobId = JobId FROM inserted
			EXEC prc_CWI_SetBudgetFromMediaBuy 	@jobId
	end
	
		
 END TRY

 BEGIN CATCH 	
   RAISERROR(''Error in CWI_TR_JobService_Update trigger'', 16, 1 ) WITH LOG
 END CATCH
' 
GO

