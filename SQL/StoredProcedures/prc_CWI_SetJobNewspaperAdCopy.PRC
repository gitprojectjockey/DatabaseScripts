/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobNewspaperAdCopy]    Script Date: 7/22/2014 9:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobNewspaperAdCopy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobNewspaperAdCopy]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobNewspaperAdCopy]    Script Date: 7/22/2014 9:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobNewspaperAdCopy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobNewspaperAdCopy 
* Purpose : This PROC would be called TO INSERT OR UPDATE the newspaper adcopy details
* Invoked from : AdCopy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
22/5/2014    Vijesh			Modified for handling multiuser scenario,action table insert    
23/6/2014	 Vijesh			Modified for adding supporting document id if it''s not exists while modifying the ad copy
**********************************************************************  
Execution example :,
**********************************************************************  
declare @inRowCount int,@vcMessage varchar(max)
exec prc_CWI_SetJobNewspaperAdCopy 
1725,'''',''\\dcvwin2k12d02\FileServerDev\AdCopies\\1725'',''1725.docx'',2,7,''\\dcvwin2k12d02\FileServerDev\SupportDocument\'',@inRowCount,@vcMessage
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobNewspaperAdCopy]	
	@inJobNewspaperId bigint,	
	@vcAdCopyContent varchar(MAX),
	@vcAdCopyPath varchar(500),
	@vcAdCopyFileName varchar(500),	
	@inAdCopyVersion decimal(18,2),
	@inUserId int,
	@vcSupportDocPath varchar(Max)
	--@inRowCount int OUTPUT,
	--@vcMessage varchar(max) OUTPUT   
AS
BEGIN	
	BEGIN TRANSACTION TRAN1
	BEGIN TRY
		
		Declare @vcMessage varchar(max),@inRowCount int=0
		DECLARE @tblResult table(OutputMessage varchar(max),DocumentId int)

		SET @vcMessage = ''''

		Declare @inJobStatus int,@InsertAction varchar(8000), @InsertActionLink varchar(8000),@AuthorName varchar(1000), @dtModifiedBy varchar(50), @inActionLookupId Int
		
		Set @inJobStatus = (Select JobStatusLookupId from CWI_Job where id=@inJobNewspaperId)

		if @inJobStatus = 8012
		begin
			update CWI_Job set JobStatusLookupId=8001 where ID=@inJobNewspaperId	---setting job status as In Progress from Assigned
		end


		If (@inJobStatus NOT IN (8001,8011,8012,8002))----8001 is In Progress and 8011 is Open Job,8002 awaiting invoice authorization, 8012 assigned
		Begin
			Set @vcMessage = ''Ad Copy cannot be saved. Please refresh the page and try again.''
		End
		else if (select isnull(InvoiceId,0) from CWI_Job where id=@inJobNewspaperId)<>0
		begin
			Set @vcMessage = ''Ad Copy cannot be saved as the job is invoiced''
		end
		Else
		Begin
			DECLARE @vcSupportDocFilePath varchar(max),@inDocCategoryId INT=0,@inSupportDocID INT=0

			SET @inDocCategoryId = (SELECT ID FROM CWI_DocCategory  WHERE DocTypeLookupID=5)--5 is lookup id for ad copy Doc 
				
			IF NOT EXISTS(SELECT JobId FROM CWI_JobNewspaper WHERE JobId=@inJobNewspaperId) 
			BEGIN
				INSERT INTO [dbo].[CWI_JobNewspaper]
				(JobId,AdCopyContent,AdCopyPath,AdCopyFileName,AdCopyVersion,AdCopyCreatedOn,AdCopyCreatedBy,
				AdCopyModifiedOn,AdCopyModifiedBy,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
				VALUES
				(@inJobNewspaperId,@vcAdCopyContent,@vcAdCopyPath,@vcAdCopyFileName,@inAdCopyVersion,
				GETDATE(),@inUserId,GETDATE(),@inUserId,@inUserId,GETDATE(),@inUserId,GETDATE())				

				----below part added for ad copy updation in supporting doc----------	@"SupportDocument\" + NewDocId.ToString() + @"\" + fileVersion				
				EXEC prc_CWI_AddDocumentDetail ''Ad Copy'','''',@inDocCategoryId,@inJobNewspaperId,205,@inAdCopyVersion,@inUserId,0,'''', @inSupportDocID OUT----- 205 is object lookup id for job	
			
				SET @vcSupportDocFilePath=@vcSupportDocPath+''\\''+CONVERT(VARCHAR,@inSupportDocID)+''\\Ver_''+CONVERT(VARCHAR,@inAdCopyVersion)+''\\''+@vcAdCopyFileName
			
				EXEC prc_CWI_SetDocumentFile @inSupportDocID,@vcSupportDocFilePath
				--------------------end-------------------	
				--Inserting into Action table to track History			

				SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
				SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

				SET @InsertAction = ''Job# ''+ CAST(@inJobNewspaperId as varchar(max)) +'' Ad Copy created by '' + @AuthorName + '' on '' + @dtModifiedBy
				SET @InsertActionLink = ''Job# ''+ CAST(@inJobNewspaperId as varchar(max)) +  ''<a href="../jobs.aspx?jobid=''+ CAST(@inJobNewspaperId as varchar(max))+''></a> '' +'' Ad Copy created by ''+ @AuthorName + '' on '' + @dtModifiedBy
				SET @inActionLookupId = 10023		
			END
			ELSE
			BEGIN			
					INSERT INTO [dbo].[CWI_History_AdCopy]
					([JobNewspaperId],[JobId],[AdCopyContent],[AdCopyPath],[AdCopyFileName],[AdCopyVersion],
					[AdCopyModifiedOn],[AdCopyModifiedBy])
					SELECT [ID],[JobId],[AdCopyContent],[AdCopyPath],[AdCopyFileName],[AdCopyVersion],
					[AdCopyModifiedOn],[AdCopyModifiedBy]
					FROM [dbo].[CWI_JobNewspaper]
					WHERE JobId=@inJobNewspaperId 

					UPDATE	[dbo].[CWI_JobNewspaper]
					SET	AdCopyContent = @vcAdCopyContent,
					AdCopyPath = @vcAdCopyPath,
					AdCopyFileName = @vcAdCopyFileName,
					[AdCopyVersion] = @inAdCopyVersion,			
					AdCopyModifiedBy = @inUserId,
					AdCopyModifiedOn = GETDATE()					
					WHERE JobId=@inJobNewspaperId
					SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
			
					----below part added for ad copy updation in supporting doc----------					
					DECLARE @RowCount int
					SELECT @inSupportDocID =  ID FROM CWI_SupportingDocument WHERE ObjectLookupID=205
											AND ObjectID=@inJobNewspaperId AND DocCategoryId=@inDocCategoryId AND IsDelete=0
											
					if @inSupportDocID = 0
					begin
						----below part added for ad copy updation in supporting doc----------	@"SupportDocument\" + NewDocId.ToString() + @"\" + fileVersion				
						EXEC prc_CWI_AddDocumentDetail ''Ad Copy'','''',@inDocCategoryId,@inJobNewspaperId,205,@inAdCopyVersion,@inUserId,0,'''', @inSupportDocID OUT----- 205 is object lookup id for job	
			
						SET @vcSupportDocFilePath=@vcSupportDocPath+''\\''+CONVERT(VARCHAR,@inSupportDocID)+''\\Ver_''+CONVERT(VARCHAR,@inAdCopyVersion)+''\\''+@vcAdCopyFileName
			
						EXEC prc_CWI_SetDocumentFile @inSupportDocID,@vcSupportDocFilePath
						--------------------end-------------------	
					end		
					else
					begin
						SET @vcSupportDocFilePath=@vcSupportDocPath+''\\''+CONVERT(VARCHAR,@inSupportDocID)+''\\Ver_''+CONVERT(VARCHAR,@inAdCopyVersion)+''\\''+@vcAdCopyFileName
					end

					IF @inSupportDocId <> 0
					BEGIN
						EXEC prc_CWI_SetDocumentDetail @inSupportDocId,''Ad Copy'',@inDocCategoryId,'''',@inJobNewspaperId,205,@inAdCopyVersion,@inUserId,0,@vcSupportDocFilePath,@RowCount
					END			
					-----NOTE: 17 is Doc Category Id and 205 is object lookup id for job	
					--------------------end-------------------	

					--Inserting into Action table to track History				

					SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
					SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

					SET @InsertAction = ''Job# ''+ CAST(@inJobNewspaperId as varchar(max)) +'' Ad Copy modified by '' + @AuthorName + '' on '' + @dtModifiedBy
					SET @InsertActionLink = ''Job# ''+ CAST(@inJobNewspaperId as varchar(max)) +  ''<a href="../jobs.aspx?jobid=''+ CAST(@inJobNewspaperId as varchar(max))+''></a> '' +'' Ad Copy modified by ''+ @AuthorName + '' on '' + @dtModifiedBy
					SET @inActionLookupId=10024									
									
			END		
			
			SET @inRowCount = @inSupportDocId
			----BELOW PART ADDED FOR INSERTING INTO LIFE CYCLE TABLE--------				
			EXEC prc_CWI_SetClassificationLifeCycleStatus @inJobNewspaperId,4002,4205,null,1,@inUserId
			--Inserting into Action table to track History	
			EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobNewspaperId,
					@ActionLookupId = @inActionLookupId,
					@Action = @InsertAction,
					@ActionWithLink = @InsertAction,
					@CreatedBy = @inUserId	

			------------------------END-----------------------		
		End		

		Insert into @tblResult
			Select @vcMessage,@inRowCount

		Select * from @tblResult
			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION TRAN1;
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION TRAN1;

END
	

	








' 
END
GO
