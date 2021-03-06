/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobService]    Script Date: 7/18/2014 8:12:30 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobService]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobService]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobService]    Script Date: 7/18/2014 8:12:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobService]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobService  
* Purpose : This PROC would be called TO get the service details 
* Invoked from : JobService.aspx
* CREATED: MohanKumar Sundaram 16MAY14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
18/7/2014   Vijesh		Update used and committed plan budget in marketing plan            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetJobServiceFee 4,NULL
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetJobService]
	@Id bigint= NULL,
	@JobId bigint,
	@ServiceId int = NULL,
	@ServiceDescription varchar(max),
	@ServiceFee numeric(18, 3),
	@IsComplimentary bit ,
	@GLAccountLookupId int = NULL,
	@author int,
	@comment varchar(max)= NULL
AS
    DECLARE @dt datetime = getdate()
	declare @message NVARCHAR(2000) 
	
	DECLARE @InsertAction varchar(8000)
	DECLARE @InsertActionLink varchar(8000)
	DECLARE @AuthorName varchar(1000)
	DECLARE @dtString varchar(100) =  FORMAT( @dt, ''MM/dd/yyyy hh:mm tt'')

	DECLARE @tblHistoryComment TABLE
	(
			comment varchar(max),
			OldGLLookupId int,
			NewGLLookupId int
	)

	DECLARE @DivisionId int, @IsCancelled bit, @InvoiceId bigint

	select @DivisionId = DivisionId, @IsCancelled = IsCancelled, @InvoiceId = InvoiceId from CWI_Job where Id = @JobId

	IF @IsCancelled = 1 /* Check if job is cancelled */
	Begin
		SET @message = ''Can''''t submit service fee since Job cancelled.'';
		THROW 50000,@message , 1; 
	End
	IF @InvoiceId IS NOT NULL /* Check if job is invoiced */
	Begin
		SET @message = ''Can''''t submit service fee since Job invoiced.'';
		THROW 50000,@message , 1; 
	End

	IF @Id is NULL AND @ServiceId IS NOT NULL /* New Job Service, check if the same service id exists. if so, update */
	Begin
		SELECT TOP 1 @Id = Id FROM CWI_JobService WHERE JobId = @JobId AND ServiceId = @ServiceId
	End 

	IF @Id is NULL /* New Job Service */
	BEGIN
		IF @ServiceId IS NOT NULL /* If service id is passed, validate for duplicate service id for the job */
		BEGIN
			IF EXISTS(SELECT top 1 1 FROM CWI_JobService WHERE JobId = @JobId AND ServiceId = @ServiceId)
			begin
				SET @message = ''Service '' + @ServiceDescription + '' already exists for the job'';
				THROW 50000,@message , 1; 
			end
		END
		/* Validate for duplicate service description for the job */
		IF EXISTS(SELECT top 1 1 FROM CWI_JobService WHERE JobId = @JobId AND LTRIM(RTRIM(ServiceDescription)) = @ServiceDescription)
		begin
			SET @message = ''Service '' + @ServiceDescription + '' already exists for the job'';
			THROW 50000,@message , 1; 
		end

		/* Validate for credit/iscomplimentary comments */
		IF (@ServiceFee<0 OR @IsComplimentary=1) AND LTRIM(RTRIM(ISNULL(@comment,''''))) = ''''
		begin
			SET @message = ''Comment is required for negative fee or compliment service.'';
			THROW 50000,@message , 1; 
		end

		
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT CWI_JobService
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
			VALUES 
			(	
				@JobId, 
				@ServiceId, 
				@ServiceDescription, 
				@ServiceFee, 
				@IsComplimentary,  
				@GLAccountLookupId, 
				20171, /* Pending Invoice */
				@author, 
				@dt, 
				@author, 
				@dt
			)

			SET @Id = SCOPE_IDENTITY()

			IF @ServiceId IS NOT NULL
			Begin
			    UPDATE CWI_Service SET ServiceLastUsed = @dt WHERE ID=@ServiceId

				UPDATE CWI_ClientService SET LastUsedOn = @dt
				WHERE ServiceID = @ServiceId
					AND ClientID = @DivisionId
			   
				IF @@ROWCOUNT = 0
				begin
					Insert into CWI_ClientService
					(
					ClientID,ServiceID,ServiceFee,CreatedBy,CreatedOn,ModifiedBy, ModifiedOn, LastUsedOn
					)
					Select @DivisionId,
					@ServiceId,
					NULL,
					@author,
					@dt,
					@author,
					@dt,
					@dt
				end
				
			End

			EXEC prc_CWI_SetBudgetFromMediaBuy 	@JobId/* Update used and committed plan budget in marketing plan*/

			--Inserting into Action table to track History
			SELECT @AuthorName = Names FROM CWI_User WHERE Id = @author

			SET @InsertAction = '' Service Fee '' + CAST(@ServiceFee as varchar(max)) + '' for service ''  + @ServiceDescription +'' added by '' + @AuthorName + '' on '' + @dtString
		
			EXEC prc_CWI_SetAction @ObjectLookupId = 213/*JobServiceFee*/, 
				@ObjectId = @Id,
				@ActionLookupId = 10017/*Job Service Fee inserted*/,
				@Action = @InsertAction,
				@ActionWithLink = @InsertAction,
				@CreatedBy = @author	
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ;

	END
	ELSE
	BEGIN
		IF @ServiceId IS NOT NULL /* If service id is passed, validate for duplicate service id for the job */
		BEGIN
			IF EXISTS(SELECT top 1 1 FROM CWI_JobService WHERE JobId = @JobId AND ServiceId = @ServiceId AND Id <> @Id )
			begin
				SET @message = ''Service '' + @ServiceDescription + '' already exists for the job'';
				THROW 50000,@message , 1; 
			end
		END
		/* Validate for duplicate service description for the job */
		IF EXISTS(SELECT top 1 1 FROM CWI_JobService WHERE JobId = @JobId AND LTRIM(RTRIM(ServiceDescription)) = @ServiceDescription AND Id <> @Id )
		begin
			SET @message = ''Service '' + @ServiceDescription + '' already exists for the job'';
			THROW 50000,@message , 1; 
		end
		DECLARE @delimiter CHAR(1) = CHAR(225)



		BEGIN TRANSACTION
		BEGIN TRY
			IF @ServiceId IS NOT NULL
			Begin
			    UPDATE CWI_Service SET ServiceLastUsed = @dt WHERE ID=@ServiceId
			End
			UPDATE	CWI_JobService
			SET	
				ServiceDescription = @ServiceDescription,
				ServiceFee = @ServiceFee,
				IsComplimentary = @IsComplimentary,
				GLAccountLookupId = @GLAccountLookupId,
				ModifiedBy = @author,
				ModifiedOn = @dt,
				IsDeleted = 0
				
			OUTPUT 
			   CASE WHEN INSERTED.ServiceDescription <> deleted.ServiceDescription THEN 
					  ''Service Description modifed from ''  + deleted.ServiceDescription + '' to '' + inserted.ServiceDescription
			   ELSE '''' 
			   END + @delimiter +
			   CASE WHEN INSERTED.ServiceFee <> deleted.ServiceFee THEN 
					  ''Service Fee modifed from ''  + CAST(deleted.ServiceFee AS VARCHAR(max)) + '' to '' + CAST( inserted.ServiceFee as VARCHAR(max))
			   ELSE '''' 
			   END  + @delimiter +
			   CASE WHEN INSERTED.IsComplimentary <> deleted.IsComplimentary THEN 
					( CASE deleted.IsComplimentary WHEN 1 THEN ''Service Fee''''s Compliement is removed'' ELSE ''Service Fee is set as Compliement'' END)
			   ELSE '''' 
			   END  + @delimiter +
			   CASE WHEN INSERTED.GLAccountLookupId <> deleted.GLAccountLookupId THEN 
					''Service Fee GL Account modified from {oldGL} to {newGL}''
			   ELSE '''' 
			   END + @delimiter ,
				deleted.GLAccountLookupId  , inserted.GLAccountLookupId 
				INTO @tblHistoryComment

			WHERE 	Id = @Id 

			DECLARE @historyComment varchar(max) = ''''

			SELECT  top 1 @historyComment = REPLACE( REPLACE(t.comment,''{oldGL}'',LOGL.LookupName),''{newGL}'',LNGL.LookupName)
			FROM @tblHistoryComment t
			INNER JOIN Lookup LOGL
				ON LOGL.Id = t.OldGLLookupId
			INNER JOIN Lookup LNGL
				ON LNGL.Id = t.NewGLLookupId 
			WHERE t.OldGLLookupId <> t.NewGLLookupId


			--LTRIM(RTRIM(REPLACE(comment,@delimiter,'''')))
			IF ISNULL( LTRIM(RTRIM(REPLACE(@historyComment,@delimiter,''''))),'''')  <> ''''
			BEGIN
				--Inserting into Action table to track History
				SELECT @AuthorName = Names FROM CWI_User WHERE Id = @author

				SET @InsertAction = '' Service Fee '' + CAST(@ServiceFee as varchar(max)) + '' for service ''  + 
						@ServiceDescription +'' added by '' + @AuthorName + '' on '' + @dtString
				INSERT CWI_Action(ObjectLookupId,ObjectId, ActionLookupId, Action, ActionWithLink, CreatedBy, CreatedOn)
				SELECT 
					213/*JobServiceFee*/,
					@Id, 10018/*Job Service Fee Updated*/, 
					Items  +'' by '' + @AuthorName + '' on '' + @dtString , 
					Items  +'' by '' + @AuthorName + '' on '' + @dtString, 
					@author,  
					@dt 
				FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@historyComment,@delimiter)
				WHERE LTRIM(RTRIM(Items)) <> ''''
			
			END
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ;

	END
	 








' 
END
GO
