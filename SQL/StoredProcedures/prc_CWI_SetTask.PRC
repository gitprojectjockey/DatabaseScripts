/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTask]    Script Date: 10/13/2014 7:24:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTask]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetTask]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTask]    Script Date: 10/13/2014 7:24:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetTask
* Purpose : This PROC would be called TO insert/update the task details
* Invoked from : Child/Tasks.aspx
* CREATED: Mohankumar Sundaram  23 OCT 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
declare @p1 int
set @p1=1
declare @p12 xml
set @p12=convert(xml,N''<DocumentElement><Assignee><UserId>0</UserId><GroupId>2</GroupId><UserName/><GroupName/><IsCopied>false</IsCopied><IsRemoved>false</IsRemoved><CreatedBy>3</CreatedBy><CreatedOn>2013-10-29T14:42:09.9603931</CreatedOn><ModifiedBy>3</M





odifiedBy><ModifiedOn>2013-10-29T14:42:09.9603931</ModifiedOn></Assignee><Assignee><UserId>7</UserId><GroupId>0</GroupId><UserName/><GroupName/><IsCopied>false</IsCopied><IsRemoved>false</IsRemoved><CreatedBy>3</CreatedBy><CreatedOn>2013-10-29T14:42:09.96





52756</CreatedOn><ModifiedBy>3</ModifiedBy><ModifiedOn>2013-10-29T14:42:09.9652756</ModifiedOn></Assignee><Assignee><UserId>3</UserId><GroupId>0</GroupId><UserName/><GroupName/><IsCopied>false</IsCopied><IsRemoved>false</IsRemoved><CreatedBy>3</CreatedBy>





<CreatedOn>2013-10-29T14:42:09.9662521</CreatedOn><ModifiedBy>3</ModifiedBy><ModifiedOn>2013-10-29T14:42:09.9662521</ModifiedOn></Assignee><Assignee><UserId>16</UserId><GroupId>0</GroupId><UserName/><GroupName/><IsCopied>false</IsCopied><IsRemoved>false</





IsRemoved><CreatedBy>3</CreatedBy><CreatedOn>2013-10-29T14:42:09.9662521</CreatedOn><ModifiedBy>3</ModifiedBy><ModifiedOn>2013-10-29T14:42:09.9662521</ModifiedOn></Assignee><Assignee><UserId>0</UserId><GroupId>3</GroupId><UserName/><GroupName/><IsCopied>t





rue</IsCopied><IsRemoved>false</IsRemoved><CreatedBy>3</CreatedBy><CreatedOn>2013-10-29T14:42:09.9730876</CreatedOn><ModifiedBy>3</ModifiedBy><ModifiedOn>2013-10-29T14:42:09.9730876</ModifiedOn></Assignee><Assignee><UserId>0</UserId><GroupId>4</GroupId><U





serName/><GroupName/><IsCopied>true</IsCopied><IsRemoved>false</IsRemoved><CreatedBy>3</CreatedBy><CreatedOn>2013-10-29T14:42:09.9730876</CreatedOn><ModifiedBy>3</ModifiedBy><ModifiedOn>2013-10-29T14:42:09.9730876</ModifiedOn></Assignee></DocumentElement>





'')
exec dbo.prc_CWI_SetTask @TaskId=@p1 output,@ObjectLookupId=204,@ObjectId=18,@Subject=''Test'',@Summary=''testing'',@Note=''testing'',@StatusLookupId=20121,@PriorityLookupId=20152,@DueDate=''2013-10-21 00:00:00'',@IsNotificationRequired=1,@Author=3,@Assignee=@p12






select @p1
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetTask]
	@TaskId	bigint = 0 out,
	@ObjectLookupId int,
	@ObjectId bigint,
	@Subject varchar(255),
	@Summary varchar(max),
	@Note varchar(max),
	@StatusLookupId int,
	@PriorityLookupId int,
	@DueDate datetime = NULL,
	@IsNotificationRequired bit = NULL,
	@Author int,
	@Assignee XML,
	@Attachment XML,
	@FileServerPath varchar(300),
	@TaskTemplateData XML = NULL,
	@EstimatedPeriodLookupID int = null,
	@EstimatedPeriod numeric(9,2) = null,
	@EstimatedTaskStartDate datetime = null,
	@EstimatedCompletion datetime=null,
	@TemplateId int=null
AS

DECLARE @dt datetime = getdate()
DECLARE @TaskMode varchar(100)
BEGIN TRANSACTION Trans1

	BEGIN TRY
		IF @TaskId = 0 
		BEGIN
			SET @TaskMode=''INSERT''
			INSERT INTO CWI_Task
			(
				ObjectLookupId, 
				ObjectId, 
				[Subject], 
				StatusLookupId, 
				PriorityLookupId, 
				DueDate, 
				IsNotificationRequired, 
				CreatedBy, 
				CreatedOn, 
				ModifiedBy, 
				ModifiedOn,
				EstimatedPeriodLookupID,
				EstimatedPeriod,
				EstimatedTaskStartDate,
				EstimatedCompletion,
				TemplateId
				
			)
			VALUES 
			(
				@ObjectLookupId, 
				@ObjectId,
				@Subject, 
				@StatusLookupId, 
				@PriorityLookupId,
				@DueDate, 
				@IsNotificationRequired, 
				@Author, @dt, @Author, getdate(),
				@EstimatedPeriodLookupID,
				@EstimatedPeriod,
				@EstimatedTaskStartDate,
				@EstimatedCompletion,
				@TemplateId
				)

			SET @TaskId = SCOPE_IDENTITY()

		END
		ELSE 
		BEGIN
			UPDATE	
				CWI_Task
			SET	
				[Subject] = @Subject,
				StatusLookupId = @StatusLookupId,
				PriorityLookupId = @PriorityLookupId,
				DueDate = @DueDate,
				IsNotificationRequired = @IsNotificationRequired,
				ModifiedBy = @Author,
				ModifiedOn = getdate(),
				EstimatedPeriodLookupID=@EstimatedPeriodLookupID,
				EstimatedPeriod=@EstimatedPeriod,
				EstimatedTaskStartDate=@EstimatedTaskStartDate,
				EstimatedCompletion=@EstimatedCompletion,
				TemplateId=@TemplateId
			WHERE 	Id = @TaskId
		END

		SET @Summary = ltrim(rtrim(@Summary))

		IF(@Summary <> '''')
			EXEC prc_CWI_SetTaskNote 1, @taskId,@Summary,@Author

		SET @Note = ltrim(rtrim(@Note))	
		IF(@Note <> '''')
			EXEC prc_CWI_SetTaskNote 0, @taskId,@Note,@Author

		-- temporary table to store the data from XML

			DECLARE @tbl TABLE
			(
				UserId1 int,
				GroupId1 int,
				IsCopied1 bit,
					IsRemoved1 bit
			)

			--Read the data from XML and store in the table variable
				INSERT INTO @tbl
				(
					UserId1 ,
					GroupId1,
					IsCopied1,
					IsRemoved1
				)
				select
					distinct
					case when usrid = 0 then NULL else usrid end,
					case when grpid = 0 then NULL else grpid end  ,
					
					iscopied,
					IsRemoved
				from
				(
				select 
					COLX.value(''(./UserId)[1]'',''varchar(20)'') usrid,
					COLX.value(''(./GroupId)[1]'',''varchar(20)'') grpid,
					COLX.value(''(./IsCopied)[1]'',''bit'') iscopied,
					COLX.value(''(./IsRemoved)[1]'',''bit'') IsRemoved
				from @Assignee.nodes(''DocumentElement/Assignee'') AS TABX(COLX)
				) x		

				INSERT CWI_TaskAssignee
				( TaskId, UserId, GroupId, IsCopied, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
				SELECT
					@taskId,
					UserId1,
					GroupId1,
					IsCopied1,
					@Author,
					dateadd(ss,1,getdate()),@Author, @dt
				FROM
				@tbl t
				LEFT OUTER JOIN CWI_TaskAssignee TA
				ON TA.TaskId = @taskId AND  ISNULL(t.UserId1,'''') = ISNULL(TA.UserId,'''') AND ISNULL(t.GroupId1,'''') = ISNULL(TA.GroupId,'''')
				AND TA.IsCopied = t.IsCopied1
				WHERE TA.Id IS NULL

				UPDATE 
					CWI_TaskAssignee 
				SET 
					IsRemoved = IsRemoved1,
					ModifiedOn=GETDATE(),
					ModifiedBy=@Author
				FROM
					CWI_TaskAssignee TA
					INNER JOIN  @tbl t
						ON TA.TaskId = @TaskId AND  ISNULL(t.UserId1,'''') = ISNULL(TA.UserId,'''') AND ISNULL(t.GroupId1,'''') = ISNULL(TA.GroupId,'''')
						AND TA.IsCopied = t.IsCopied1
				
				--EXEC prc_CWI_SetTaskAttachment @TaskId = @TaskId,	@Author = @Author, 	@Attachments = @attachment, @FilePath = @FileServerPath
				DECLARE @v1 varchar(500);
				DECLARE @TId varchar(100);
				SET @v1 = @FileServerPath;
				IF @TaskMode=''INSERT''
					SET @v1 = @v1+CAST(@TaskId as varchar);
				ELSE
					SET @v1=@FileServerPath;
				EXEC prc_CWI_SetTaskAttachment @TaskId = @TaskId,	@Author = @Author, 	@Attachments = @attachment, @FilePath = @v1

				IF @TaskTemplateData IS NOT NULL
				begin 
					EXEC [prc_CWI_SetTaskTemplateData] @TaskId = @TaskId,	@Author = @Author, 	@templatevalues = @TaskTemplateData
				end
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;


' 
END
GO
