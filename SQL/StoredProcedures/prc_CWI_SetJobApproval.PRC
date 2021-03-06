/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobApproval]    Script Date: 4/29/2014 3:58:04 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobApproval]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobApproval]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobApproval]    Script Date: 4/29/2014 3:58:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobApproval]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************************************
* PROCEDURE: prc_CWI_SetJobapproval
* Purpose : This PROC would be called TO insert/update the job approval details
* Invoked from : jobs.aspx
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  28APR14	Mohankumar		Comment and history added

*************************************************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetJobapproval]
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetJobApproval]
	@JobId bigint,
	@ApprovalStatusLookupId int,
	@ContactDetails XML,
	@Author	int,
	@vcComment varchar(MAX)
AS
	DECLARE @JobapprovalId bigint
	BEGIN TRANSACTION Trans1
	BEGIN TRY
		--INSERT INTO Job Apporval table
		INSERT CWI_Jobapproval
		(
			JobId, 
			ApprovalSentOn,
			ApprovalStatusLookupid,
			CreatedBy, 
			CreatedOn, 
			ModifiedBy, 
			ModifiedOn
		)
		VALUES 
		(
			@JobId,
			getdate(),
			@ApprovalStatusLookupid,
			@Author, 
			getdate(), 
			@Author, 
			getdate()
		)
		SET @JobapprovalId = SCOPE_IDENTITY()
		
		--INSERT INTO JobApprovalContact table
		-- temporary table to store the data from XML
		DECLARE @tbl TABLE
		(
			ContactId int,
			ContactEmail varchar(max)
				
		)
		INSERT INTO @tbl
		(
			ContactId,
			ContactEmail
		)
		select 
			COLX.value(''(./ContactID)[1]'',''int'') contId,
			COLX.value(''(./Email)[1]'',''varchar(max)'') contemail
		from @ContactDetails.nodes(''DocumentElement/JobContact'') AS TABX(COLX)
				
		INSERT CWI_Jobapprovalcontact
		(JobApprovalId, ContactId, ContactEmail, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT
			@JobapprovalId,
			t.ContactId,
			t.ContactEmail,
			@Author,
			getdate(),
			@Author, getdate()
		FROM
		@tbl t
		LEFT OUTER JOIN CWI_Jobapprovalcontact TA
			ON TA.JobApprovalId = @JobapprovalId 
			AND  ISNULL(t.ContactId,'''') = ISNULL(TA.ContactId,'''') 
			AND ISNULL(t.ContactEmail,'''') = ISNULL(TA.ContactEmail,'''')
		WHERE TA.Id IS NULL

		IF ISNULL(@vcComment,'''') <> ''''
		BEGIN
			EXEC prc_CWI_SetComment @author, 205, @jobId, NULL, @vcCOmment, 1
		END
		
		--Inserting into Action table to track History
		DECLARE @InsertAction varchar(8000)
		DECLARE @InsertActionLink varchar(8000)
		DECLARE @AuthorName varchar(1000)
		DECLARE @dtModifiedBy varchar(50)

		SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
		SELECT @AuthorName = Names FROM CWI_User WHERE Id = @Author

		SET @InsertAction = ''Ad approval is sent by '' + @AuthorName + '' on '' + @dtModifiedBy
		SET @InsertActionLink=''Ad approval for job '' + Convert(varchar,@JobId) + 
			'' is sent <a href="../jobs.aspx?jobid='' + Convert(varchar,@JobId) + ''></a>'' + '' by '' + @AuthorName + '' on '' + @dtModifiedBy
		
		EXEC prc_CWI_SetAction @ObjectLookupId = 205/*job*/, @ObjectId = @JobId,
			@ActionLookupId = 10016,
			@Action = @InsertAction,
			@ActionWithLink = @InsertActionLink,
			@CreatedBy = @Author

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
