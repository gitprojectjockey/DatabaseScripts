/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyJob]    Script Date: 11/7/2014 11:04:30 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyJob]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCopyJob]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyJob]    Script Date: 11/7/2014 11:04:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetCopyJob  
* Purpose : This PROC would be called to submit all the details of a job to the new job 
* Invoked from : CopyJob.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetCopyJob] @ObjectId=1, @ObjectLookupID =201,@AuthorID=8
exec prc_CWI_SetCopyJob 0,
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetCopyJob] 	
	@inJobId bigint = 0 ,	
	@inUserId int,	
	@inPickupJobNo bigint,
	@vcVendorIds varchar(MAX),	
	@ObjectLookupID INT,		
	@vcTaskIds varchar(max),
	@inTaskStatusLookupId int,
	@inTaskPriorityLookupId int,
	@vcServiceIds varchar(MAX)
AS
BEGIN
BEGIN TRY		
		
	SET NOCOUNT ON;
	DECLARE @inMediaBuyOutput INT,@inAdCopyOutput INT 
	BEGIN TRANSACTION TRAN1
	BEGIN TRY
		--------------------JOB---------------------
		--EXEC @inJobId = prc_CWI_SetJob @inJobId,@MarketingPlanId,@ClassificationId,@JobName,@JobSummary,@InvoiceDate,
		--@JobDueBy,@JobAssignedTo,@IsQuote,@AdDescription,@JobStatusLookupId,@PONumber,@inUserId,@Action,@Details

		UPDATE [dbo].[CWI_Job] 
		SET IsPickup=1,[PickupJobNumber]=@inPickupJobNo
		WHERE ID=@inJobId
		-------------------MEDIA BUY----------------	
		--IF @vcVendorIds IS NOT NULL
		--BEGIN
		--	EXEC @inMediaBuyOutput = prc_CWI_SetJobMediaBuy @inJobId,@vcVendorIds,NULL,@inMediaBuyStatus,
		--	@inUserId,@inMediaBuyOutput
		--END
		--------------UPDATE ACTUAL COST & INVOICE--------
		DECLARE @decExpectedCost DECIMAL(18,2), @decExpectedInvoice DECIMAL(18,2)
		WHILE LEN(@vcVendorIds) > 0
		BEGIN
					
			SELECT @decExpectedCost=ActualCost,@decExpectedInvoice=ActualInvoice
			FROM CWI_JobMediaBuy 
			WHERE VendorId IN (LEFT (@vcVendorIds,CHARINDEX('','',@vcVendorIds+'','')-1)) 
			AND JobId=@inPickupJobNo
			
			UPDATE CWI_JobMediaBuy SET ExpectedCost=@decExpectedCost,ExpectedInvoice=@decExpectedInvoice
			WHERE ID = 
			(SELECT ID FROM CWI_JobMediaBuy 
			WHERE JobId=@inJobId 
			AND VendorId IN (LEFT (@vcVendorIds,CHARINDEX('','',@vcVendorIds+'','')-1)))
					
			SET @vcVendorIds = STUFF(@vcVendorIds,1,CHARINDEX('','', @vcVendorIds+'',''),'''')
		END
		------------------AD COPY-------------------	
		--EXEC @inAdCopyOutput = prc_CWI_SetJobNewspaperAdCopy @inJobId,@vcAdCopyContent,@vcAdCopyPath,
		--@vcAdCopyFileName,@inAdCopyVersion,@inUserId,@inAdCopyOutput
		------------------SUPPORTING DOCS-----------		
		--WHILE LEN(@vcDocIds) > 0
		--BEGIN				  
		--	INSERT INTO [dbo].[CWI_SupportingDocument]
		--	SELECT [Title],[DocCategoryId],@ObjectLookupID,@inJobId,Summary,1,GETDATE(),
		--	@inUserId,GETDATE(),@inUserId,IsShared,NULL,0			
		--	FROM [CWI_SupportingDocument] WHERE Id IN (LEFT (@vcDocIds,CHARINDEX('','',@vcDocIds+'','')-1))
		
		--	SET @vcDocIds = STUFF(@vcDocIds,1,CHARINDEX('','', @vcDocIds+'',''),'''')			
		--END


		-----------------JOB SERVICE---------------------
		insert into CWI_JobService
		(	
				JobId, 
				ServiceId, 
				ServiceDescription, 
				ServiceFee, 
				IsComplimentary, 
				GLAccountLookupId,
				StatusLookupId, 
				CreatedBy, 
				CreatedOn, 
				ModifiedBy, 
				ModifiedOn)
		SELECT 
			
				@inJobId, 
				ServiceId, 
				ServiceDescription, 
				ServiceFee, 
				IsComplimentary, 
				GLAccountLookupId,
				StatusLookupId, 
				@inUserId, 
				getdate(), 
				@inUserId, 
				getdate()
		 FROM CWI_JobService JS 
		INNER JOIN dbo.fnc_SplitCommaSeparatedValuesIntoTable(@vcServiceIds,'','') T 
			on js.Id=Convert(bigint,T.Items)
		------------------End----------------------


		--------------------TASK--------------------
		DECLARE @CopyJobTaskIds TABLE (OldTaskId INT,NewTaskId INT)
		
		WHILE LEN(@vcTaskIds) > 0
		BEGIN				  
			DECLARE @TaskIdTemp varchar(200);
			SET @TaskIdTemp=@vcTaskIds;
			INSERT INTO dbo.CWI_Task 
			SELECT @ObjectLookupID,@inJobId,Subject,StatusLookupId,
			PriorityLookupId,NULL,0,@inUserId,GETDATE(),@inUserId,GETDATE(),null,null,null,null,[TemplateID]	
			FROM CWI_Task WHERE Id IN (LEFT (@vcTaskIds,CHARINDEX('','',@vcTaskIds+'','')-1))

			--Insert into task templatedata table
			DECLARE @IdTask int=0;
			SET @IdTask=SCOPE_IDENTITY();
			INSERT INTO dbo.CWI_TaskTemplateData(TaskId,TemplateFieldId,FieldValue,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
			SELECT @IdTask,TemplateFieldId,FieldValue,@inUserId,GETDATE(),@inUserId,GETDATE()	
			FROM CWI_TaskTemplateData WHERE TaskId=LEFT (@TaskIdTemp,CHARINDEX('','',@TaskIdTemp+'','')-1)
			
			
			--Insert Task Attachments details
			 INSERT INTO CWI_TaskAttachment(TaskID,[FileName],FilePath,Attachtomail,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
			 SELECT @IdTask,[FileName],FilePath,Attachtomail,@inUserId,GETDATE(),@inUserId,GETDATE()
			 FROM CWI_TaskAttachment WHERE TaskId=LEFT(@TaskIdTemp,CHARINDEX('','',@TaskIdTemp+'','')-1) AND IsRemoved=0

			 IF @@ROWCOUNT>0
			 BEGIN
				--Insert the old and new taskids into the table variable
				INSERT INTO @CopyJobTaskIds(OldTaskId,NewTaskId) VALUES (LEFT(@TaskIdTemp,CHARINDEX('','',@TaskIdTemp+'','')-1),@IdTask)
			 END

			 --Insert Task Summary and Notes details
			 INSERT INTO CWI_TaskNote(IsSummary,TaskId,Note,CreatedBy,CreatedOn)
			 SELECT IsSummary,@IdTask,Note,@inUserId,GETDATE()
			 FROM CWI_TaskNote WHERE TaskId=LEFT (@TaskIdTemp,CHARINDEX('','',@TaskIdTemp+'','')-1)

			 SET @vcTaskIds = STUFF(@vcTaskIds,1,CHARINDEX('','', @vcTaskIds+'',''),'''')
		END
		----------------------------END---------------------------
		
		


		--------------ACTION TABLE - HISTORY---------------
		DECLARE @InsertAction varchar(8000)
		DECLARE @InsertActionLink varchar(8000)
		DECLARE @AuthorName varchar(1000)
		DECLARE @dtModifiedOn varchar(50)
		DECLARE @vcJobName varchar(MAX)
		DECLARE @vcParentJob varchar(MAX)
			
		SET @vcJobName = (SELECT CONVERT(VARCHAR,ID)+'' - ''+JobName FROM CWI_Job  WHERE ID=@inJobId)
		SET @vcParentJob = (SELECT CONVERT(VARCHAR,ID)+'' - ''+JobName FROM CWI_Job  WHERE ID=@inPickupJobNo)
		SET @dtModifiedOn = (SELECT FORMAT(CreatedOn, ''MM/dd/yyyy hh:mm tt'') FROM CWI_Job WHERE ID=@inJobId)
		SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId
		
		SET @InsertAction = ''Job#''+@vcJobName + '' has been copied from Job#''+@vcParentJob +'' by ''+ @AuthorName + '' on '' + @dtModifiedOn 
		SET @InsertActionLink = @vcJobName + Convert(varchar,@inJobId) + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@inJobId) + ''></a>'' +'' has been copied from ''+ @vcParentJob ++ Convert(varchar,@inPickupJobNo) + '' <a href="../jobs.aspx?jobid='' + Convert




(varchar,@inPickupJobNo) + ''></a>'' + '' created by '' + @AuthorName + '' on '' + @dtModifiedOn
			
		EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
			@ActionLookupId = 10015,
			@Action = @InsertAction,
			@ActionWithLink = @InsertActionLink,
			@CreatedBy = @inUserId

		-------------------------END-------------------------


	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION TRAN1;
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION TRAN1;

END TRY
BEGIN CATCH	 		
	EXEC prc_CWI_AppRaiseError;
	THROW;
END CATCH

END




' 
END
GO
