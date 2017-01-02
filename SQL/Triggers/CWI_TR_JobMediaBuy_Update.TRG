/****** Object:  Trigger [CWI_TR_JobMediaBuy_Update]    Script Date: 8/19/2014 2:52:23 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_JobMediaBuy_Update]'))
DROP TRIGGER [dbo].[CWI_TR_JobMediaBuy_Update]
GO

/****** Object:  Trigger [dbo].[CWI_TR_JobMediaBuy_Update]    Script Date: 8/19/2014 2:52:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_JobMediaBuy_Update]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[CWI_TR_JobMediaBuy_Update] ON [dbo].[CWI_JobMediaBuy]
 AFTER UPDATE
 NOT FOR REPLICATION AS
 SET NOCOUNT On 

DECLARE @AuditTime DATETIME, @jobId bigint
SET @AuditTime = GETDATE()

 BEGIN TRY

	IF UPDATE(MMRPO) OR UPDATE(ExpectedCost) OR UPDATE(ExpectedInvoice) OR UPDATE(ActualCost) 
	OR UPDATE(ActualInvoice) OR UPDATE(IsActualCostFreeze) OR UPDATE(IsActualInvoiceFreeze) 
	OR UPDATE(IsComplimentary) OR UPDATE(IsComplimentaryInvoice) OR UPDATE(IsRemoved) OR UPDATE(DNR) 
	OR UPDATE(StatusId)
	Begin
		INSERT [dbo].[CWI_History_JobMediaBuy]
		   ([JobMediaBuyId],[JobId],[VendorId],[MMRPO],[OldStatusId],[NewStatusId],
		   	[OldExpectedCost],[NewExpectedCost],[OldExpectedInvoice],[NewExpectedInvoice],
			[OldActualCost],[NewActualCost],[OldActualInvoice],[NewActualInvoice],
			[OldIsActualCostFreeze],[NewIsActualCostFreeze],[OldIsActualInvoiceFreeze],[NewIsActualInvoiceFreeze],
			[OldIsComplimentary],[NewIsComplimentary],[OldIsComplimentaryInvoice],[NewIsComplimentaryInvoice],
			[OldIsRemoved],[NewIsRemoved],[OldDNR],[NewDNR],[ModifiedBy],[ModifiedOn], 
			ModifiedByEmail, ModifiedByName, ModifiedApplication
		   )
		   SELECT 
				Inserted.[Id],inserted.JobId,inserted.VendorId,inserted.MMRPO,deleted.StatusId,inserted.StatusId,
				deleted.ExpectedCost,inserted.ExpectedCost,deleted.ExpectedInvoice,inserted.ExpectedInvoice,
				deleted.ActualCost,inserted.ActualCost,deleted.ActualInvoice,inserted.ActualInvoice,
				deleted.IsActualCostFreeze,inserted.IsActualCostFreeze,deleted.IsActualInvoiceFreeze,inserted.IsActualInvoiceFreeze,
				deleted.IsComplimentary,inserted.IsComplimentary,deleted.IsComplimentaryInvoice,inserted.IsComplimentaryInvoice,
				deleted.IsRemoved,inserted.IsRemoved,deleted.DNR,inserted.DNR,inserted.ModifiedBy,inserted.ModifiedOn	,
				inserted.ModifiedByName, inserted.ModifiedByEmail, inserted.ModifiedApplication
			FROM Inserted
            JOIN Deleted
               ON Inserted.[Id] = Deleted.[Id]
               AND
			   ( ISNULL(Inserted.MMRPO,0) <> ISNULL(Deleted.MMRPO,0)
			   OR ISNULL(Inserted.ExpectedCost,0) <> ISNULL(Deleted.ExpectedCost,0)
			   OR ISNULL(Inserted.ExpectedInvoice,0) <> ISNULL(Deleted.ExpectedInvoice,0)
			   OR ISNULL(Inserted.ActualCost,0) <> ISNULL(Deleted.ActualCost,0)
			   OR ISNULL(Inserted.ActualInvoice,0) <> ISNULL(Deleted.ActualInvoice,0)
			   OR ISNULL(Inserted.IsActualCostFreeze,0) <> ISNULL(Deleted.IsActualCostFreeze,0)
			   OR ISNULL(Inserted.IsActualInvoiceFreeze,0) <> ISNULL(Deleted.IsActualInvoiceFreeze,0)
			   OR ISNULL(Inserted.IsComplimentary,0) <> ISNULL(Deleted.IsComplimentary,0)
			   OR ISNULL(Inserted.IsComplimentaryInvoice,0) <> ISNULL(Deleted.IsComplimentaryInvoice,0)
			   OR ISNULL(Inserted.IsRemoved,0) <> ISNULL(Deleted.IsRemoved,0)
			   OR ISNULL(Inserted.DNR,0) <> ISNULL(Deleted.DNR,0)
			   OR ISNULL(Inserted.StatusId,0) <> ISNULL(Deleted.StatusId,0)
			  )

		IF UPDATE(ActualCost)  OR UPDATE(IsComplimentary) OR UPDATE(StatusId) 
		begin
			/* Update Job as awaiting invoice approval*/
			SELECT top 1  @jobId = JobId FROM inserted
			exec [prc_CWI_SetJobAwaitingInvoiceApproval] @jobId = @jobId, @MediabuyId = NULL
		end
	End

	/* Update used and committed plan budget in marketing plan*/	
	if exists(select top 1 1 from Inserted join Deleted on Inserted.[Id] = Deleted.[Id] and
			isnull(Inserted.ActualCost,0) <> isnull(Deleted.ActualCost,0)
			or isnull(Inserted.IsComplimentary,0) <> isnull(Deleted.IsComplimentary,0)
			or isnull(Inserted.IsRemoved,0) <> isnull(Deleted.IsRemoved,0)
			or isnull(Inserted.DNR,0) <> isnull(Deleted.DNR,0)
			or isnull(Inserted.StatusId,0) <> isnull(Deleted.StatusId,0)
			or isnull(Inserted.ActualInvoice,0) <> isnull(Deleted.ActualInvoice,0)
			or isnull(Inserted.IsComplimentaryInvoice,0) <> isnull(Deleted.IsComplimentaryInvoice,0))
	begin
		SELECT top 1  @jobId = JobId FROM inserted
			EXEC prc_CWI_SetBudgetFromMediaBuy 	@jobId
	end

	
		
 END TRY

 BEGIN CATCH 
	--declare @error varchar(400);
	--set @error=ERROR_MESSAGE();
	--Raiserror(@error, 16, 1 ) with log
   RAISERROR(''Error in CWI_TR_JobMediaBuy_Update trigger'', 16, 1 ) WITH LOG
 END CATCH
' 
GO


