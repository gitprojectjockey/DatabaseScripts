/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJob]    Script Date: 11/7/2014 4:53:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJob]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJob]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJob]    Script Date: 11/7/2014 4:53:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/****************************************************************************************
* PROCEDURE: prc_CWI_SetJob
* Purpose : This Proc will be called to insert/update the Job Summary details
* Invoked from : Jobs.aspx
* CREATED: Bala 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION
  05MAY14	Mohankumar		Assignee added for new job  
  07Nov14	Vijesh			Insert assignee on edit job
**********************************************************************  

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetJob 
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetJob]
	--Job Summary fields
	@JobSummaryId	bigint = 0 out,
	@MarketingPlanId	int,
	@ClassificationId int,
	@JobName	varchar(255),
	@JobSummary varchar(max)=null,
	@InvoiceDate date=null,
	@JobDueBy datetime=null,
	@JobAssignedTo int,
	@IsQuote bit,
	@IsCreativeAdCopy bit,
	@IsClientView bit,
	@AdDescription varchar(max)=null,
	@JobStatusLookupId int,
	@PONumber varchar(250)=null,
	@Author	int,
	@Action varchar(100),
	@Details XML,
	@CostDetails XML,
	@Assignee  XML = NULL,
	@EstimatedJobStartDate datetime = null,
	@EstimatedCompletion datetime = null,
	@EstimatedPeriodLookupId int=null,
	@EstimatedPeriod numeric(7,2)=null,
	@TemplateId int=null
AS
	DECLARE @AuthorName varchar(1000)
	DECLARE @dt varchar(50)
	DECLARE @JobCount int
	DECLARE @DivisionID int
	SET @dt  =FORMAT( getdate(), ''MM/dd/yyyy hh:mm tt'');
	SELECT @AuthorName = Names FROM CWI_User WHERE Id = @Author
	SELECT @JobCount = JobCount, @DivisionID = DivisionID FROM CWI_MarketingPlan WHERE ID=@MarketingPlanId
	BEGIN TRANSACTION
	BEGIN TRY
		

		If @JobSummaryId = 0
		BEGIN
			INSERT INTO CWI_Job
			(
				MarketingPlanId,
				ClassificationId,
				DivisionId,
				JobName,
				JobSummary, 
				InvoiceDate, 
				JobDueBy,
				JobAssignedTo, 
				IsQuote, 
				IsCreativeAdCopy,
				IsClientView,
				AdDescription,
				JobStatusLookupId,
				PONumber,
				EstimatedJobStartDate,
				EstimatedCompletion,
				EstimatedPeriodLookupID,
				EstimatedPeriod,
				CreatedBy, 
				CreatedOn, 
				ModifiedBy, 
				ModifiedOn,
				TemplateId
			)
			VALUES 
			(
				@MarketingPlanId,
				@ClassificationId, 
				@DivisionID,
				@JobName, 
				@JobSummary, 
				@InvoiceDate, 
				@JobDueBy,
				@JobAssignedTo, 
				@IsQuote,
				@IsCreativeAdCopy,
				@IsClientView,  
				@AdDescription,
				@JobStatusLookupId,
				@PONumber,
				@EstimatedJobStartDate,
				@EstimatedCompletion,
				@EstimatedPeriodLookupId,
				@EstimatedPeriod,
				@Author, 
				getdate(), 
				@Author, 
				getdate(),
				@TemplateId

			)
			SET @JobSummaryId =  SCOPE_IDENTITY()

			DECLARE @InsertAction varchar(8000)
			DECLARE @InsertActionLink varchar(8000)
			SET @InsertAction = ''Job# ''+ Convert(varchar,@JobSummaryId) + '' created by '' + @AuthorName + '' on '' + Convert(varchar, @dt)
			SET @InsertActionLink=''Job# ''  + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@JobSummaryId) + ''" target="_blank">'' + Convert(varchar,@JobSummaryId) + ''</a>'' + '' created by '' + @AuthorName + '' on '' + convert(varchar, @dt)
			EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @JobSummaryId,
				@ActionLookupId = 10006,
				@Action = @InsertAction,
				@ActionWithLink= @InsertActionLink,
				@CreatedBy = @Author
			/*Update the marketing plan history*/
			EXEC prc_CWI_SetAction @ObjectLookupId = 204, @ObjectId = @MarketingPlanId,
				@ActionLookupId = 10006,
				@Action = @InsertAction,
				@ActionWithLink = @InsertActionLink,
				@CreatedBy = @Author

			UPDATE CWI_MarketingPlan SET JobCount = @JobCount+1 WHERE ID=@MarketingPlanId
			
			

				
			IF @Details IS NOT NULL
			begin 
				EXEC [prc_CWI_SetJobSummaryTemplateData] @JobId = @JobSummaryId,	@inUserId = @Author, 	@templatevalues = @Details
			end

	
           IF( @CostDetails IS NOT NULL )
           BEGIN

               EXEC [prc_CWI_SetJobCostCenter] @JobId = @JobSummaryId,	@Author = @Author, 	@CostDetails = @CostDetails

           END

		   IF( @Assignee IS NOT NULL )
           BEGIN

               EXEC prc_CWI_SetJobAssignee  @JobId = @JobSummaryId,	@Author = @Author, 	@Assignee  = @Assignee

           END
				
			--Inserting into Action table to track History
			--Job 135 created by Kevin on 10/16/2013 09:07 AM
			--Job# <a href="../jobs.aspx?jobid=135">135</a> created by Kevin on 10/16/2013 09:07 AM

			
		END
	ELSE
	BEGIN
		DECLARE @delimiter CHAR(1) = CHAR(225);
		
	DECLARE @tblJob TABLE
(
       comment varchar(max)
)


		UPDATE	CWI_Job	SET	
				JobName = @JobName,
				JobSummary = @JobSummary,
				InvoiceDate =  @InvoiceDate,
				JobDueBy = @JobDueBy,
				JobAssignedTo = @JobAssignedTo,
				IsQuote = @IsQuote,
				IsCreativeAdCopy =@IsCreativeAdCopy ,
				IsClientView=@IsClientView,
				AdDescription=@AdDescription,
				--JobStatusLookupId=@JobStatusLookupId,
				PONumber=@PONumber,
				EstimatedJobStartDate=@EstimatedJobStartDate,
				EstimatedCompletion=@EstimatedCompletion,
				EstimatedPeriodLookupId=@EstimatedPeriodLookupId,
				EstimatedPeriod=@EstimatedPeriod,
				ModifiedBy = @Author,
				ModifiedOn = getdate(),
				TemplateId=@TemplateId
				OUTPUT
				   CASE WHEN INSERTED.JobName<>DELETED.JobName THEN ''Job Name modified from ''+DELETED.JobName+ '' to '' +INSERTED.JobName+@delimiter  ELSE '''' end +
				   CASE WHEN INSERTEd.JobSummary<>DELETED.JobSummary THEN ''Job Summary modified from ''+Convert(varchar,CASE when DELETED.JobSummary='''' THEN ''Empty''else DELETED.JobSummary END)+ ''  to '' +Convert(varchar,INSERTED.JobSummary)+@delimiter ELSE '''' END + 
				   CASE WHEN INSERTEd.InvoiceDate<>DELETED.InvoiceDate THEN ''Invoice Date modified from ''+Convert(varchar,DELETED.InvoiceDate,101)+ '' to '' +Convert(varchar,INSERTED.InvoiceDate,101)+@delimiter ELSE '''' end +
				   CASE WHEN INSERTEd.JobDueBy<>DELETED.JobDueBy THEN ''Job Due By modified from ''+Convert(varchar,DELETED.JobDueBy,101)+ '' to '' +Convert(varchar,INSERTED.JobDueBy,101)+@delimiter ELSE '''' end+
				  -- CASE WHEN INSERTEd.JobAssignedTo<>DELETED.JobAssignedTo THEN ''Job AssignedTo modified from ''+Convert(varchar,DELETED.JobAssignedTo)+ '' to '' +Convert(varchar,INSERTED.JobAssignedTo)+@delimiter ELSE '''' end +
				   CASE WHEN INSERTEd.IsQuote<>DELETED.IsQuote THEN ''Job ''+Convert(varchar,CASE WHEN DELETED.IsQuote=1 then '' is Set as Quote '' else ''Quote removed'' END)+ '' modified to '' +Convert(varchar,CASE WHEN inserted.IsQuote=1 then ''Set as Quote'' 				   else ''Quote removed'' END)+@delimiter ELSE '''' end +
				   CASE WHEN INSERTEd.IsCreativeAdCopy<>DELETED.IsCreativeAdCopy THEN +Convert(varchar,CASE WHEN DELETED.IsCreativeAdCopy=1 then ''Creative ad copy selected'' else ''Creative ad copy unselected'' END)+ '' modified to '' +Convert(varchar,CASE WHEN 
				   inserted.IsCreativeAdCopy=1 then ''Creative ad copy selected'' else ''Creative ad copy unselected'' END)+@delimiter ELSE '''' end +
				   CASE WHEN INSERTEd.IsClientView<>DELETED.IsClientView THEN +Convert(varchar,CASE WHEN DELETED.IsClientView=1 then ''The client can view this Job in ClientWise '' else ''The client can not view this Job in ClientWise'' END)+ '' to '' +Convert(varchar,CASE

 WHEN inserted.IsClientView=1 then ''True'' else ''False'' END)+@delimiter ELSE '''' end +
				   CASE WHEN INSERTEd.AdDescription<>DELETED.AdDescription THEN ''Ad Description modified from ''+CASE WHEN DELETED.AdDescription='''' THEN ''Empty'' ELSE DELETED.AdDescription END+ '' to '' +INSERTED.AdDescription+@delimiter ELSE '''' end +
				   CASE WHEN INSERTEd.JobStatusLookupId<>DELETED.JobStatusLookupId THEN ''Job Status modified from ''+Convert(varchar,DELETED.JobStatusLookupId)+ '' to '' +Convert(varchar,INSERTED.JobStatusLookupId)+@delimiter ELSE '''' end +
				   CASE WHEN INSERTEd.PONumber<>DELETED.PONumber THEN ''PO Number modified from ''+Convert(varchar,+CASE WHEN DELETED.PONumber='''' THEN ''Empty'' ELSE DELETED.PONumber END)+ '' to '' ++Convert(varchar,INSERTED.PONumber) ELSE '''' end 
				   INTO @tblJob 
				FROM CWI_Job J 
			WHERE 	ID = @JobSummaryId;


		



			DECLARE @updHistory varchar(max),@ActionVal varchar(max);
				SELECT @updHistory = comment from @tblJob

				DECLARE @tblAction TABLE
(
       ObjLookupId INt,
	   ObjectId INT,
	   ActionLookupId INT,
	   ActionVal Varchar(max)
	   
)
	INSERT INTO @tblAction SELECT  205,@JobSummaryId,10007,Items FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@updHistory,@delimiter) WHERE LTRIM(RTRIM(items)) <> '''';

			--Set @ActionVal=(SELECT * FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@updHistory,@delimiter) WHERE LTRIM(RTRIM(items)) <> '''');
		
		
		INSERT INTO CWI_Action Select TA.ObjLookupId,TA.ObjectId,TA.ActionLookupId,TA.ActionVal + '' by '' + @AuthorName + '' on '' + Convert(varchar,@dt),TA.ActionVal,@Author,GETDATE() from @tblAction TA ;
		--END
			IF @Details IS NOT NULL
				begin 
					EXEC [prc_CWI_SetJobSummaryTemplateData] @JobId = @JobSummaryId,	@inUserId = @Author, 	@templatevalues = @Details
				end

				IF( @CostDetails IS NOT NULL )
           BEGIN

               EXEC [prc_CWI_SetJobCostCenter] @JobId = @JobSummaryId,	@Author = @Author, 	@CostDetails = @CostDetails

           END
		   /*updating correspondence invoice Date*/
			 UPDATE CWI_Correspondence 
			SET
				InvoiceDate=T.InvoiceDate
			FROM 
				(Select J.InvoiceDate from CWI_JOB J
			INNER JOIN
				CWI_JobMediaBuy JMB ON JMB.JobId=J.ID
			INNER JOIN 
				CWI_Correspondence C ON C.JobMediaBuyId=JMB.ID WHERE J.ID=@JobSummaryId) AS T


			/*Update the marketing plan history*/
			select @MarketingPlanId = MarketingPlanId from CWI_Job where id=@JobSummaryId
			DECLARE @UpdateAction varchar(8000)
			DECLARE @UpdateActionLink varchar(8000)
			SET @UpdateAction = ''Job# ''+ Convert(varchar,@JobSummaryId) + '' updated by '' + @AuthorName + '' on '' + Convert(varchar, @dt)
			SET @UpdateActionLink=''Job# '' + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@JobSummaryId) + ''" target="_blank">'' + Convert(varchar,@JobSummaryId) + ''</a>'' + '' updated by '' + @AuthorName + '' on '' + convert(varchar, @dt)
			
			EXEC prc_CWI_SetAction @ObjectLookupId = 204, @ObjectId = @MarketingPlanId,
				@ActionLookupId = 10007,
				@Action = @UpdateAction,
				@ActionWithLink = @UpdateActionLink,
				@CreatedBy = @Author

		IF( @Assignee IS NOT NULL )
           BEGIN

               EXEC prc_CWI_SetJobAssignee  @JobId = @JobSummaryId,	@Author = @Author, 	@Assignee  = @Assignee

           END

	END
			END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW

		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;

		RETURN






' 
END
GO
