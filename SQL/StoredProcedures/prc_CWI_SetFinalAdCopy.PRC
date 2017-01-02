/****** Object:  StoredProcedure [dbo].[prc_CWI_SetFinalAdCopy]    Script Date: 6/9/2014 8:10:14 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetFinalAdCopy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetFinalAdCopy]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetFinalAdCopy]    Script Date: 6/9/2014 8:10:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetFinalAdCopy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetFinalAdCopy
* Purpose : This PROC would be called to update final ad copy 
* Invoked from : CreativeAdCopy.aspx
* CREATED: MohanKumar 22JUN14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_SetFinalAdCopy] @PlanId = 0 OUT,
	@DivisionID = 123,
	@PlanName= ''''Plan1'''',
	@PlanDesc = ''''Plan Desc'''',
	@PlanFrom = ''''07/01/2013'''',
	@PlanTo = ''''07/31/2013'''',
	@PlanBudget = 4000.00,
	@Author =2

**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetFinalAdCopy]
	@mediabuyId bigint,
	@filePath varchar(max)= NULL,
	@fileName varchar(max)= NULL,
	@author int
AS
	DECLARE @dt datetime=getdate(), @authorName varchar(max)
			,@action varchar(1000) ='''',
			@ActionLookupId int,
			@jobId bigint,
			@isNewAdCopy bit=0

	declare @message NVARCHAR(2000) =''''

	DECLARE @isCancelled bit, @DNR bit, @isRemoved bit, 
			@existingFileName varchar(max) = NULL,
			@vendorName varchar(max)

	SELECT top 1 @isCancelled = IsCancelled, @DNR = DNR, 
		@isRemoved = IsRemoved, @existingFileName = FinalAdCopyFileName,
		@vendorName = V.VendorName,
		@jobId = JMB.JobId,
		@isNewAdCopy = CASE WHEN JMB.FinalAdCopyModifiedBy IS NULL THEN 1 ELSE 0 END
	FROM CWI_JobMediaBuy JMB INNER JOIN CWI_Vendor V ON JMB.VendorId = V.Id 
	WHERE JMB.ID = @mediabuyId 

	IF @isCancelled = 1 OR @IsRemoved = 1 OR @DNR=1
	BEGIN
		SET @message = ''Final Ad Copy can not be assigned to cancelled, removed or DNR media buy.'';
		THROW 50000,@message , 1; 
		return;
	END

	IF ISNULL(@fileName,'''')<> '''' AND ISNULL(@existingFileName ,'''') <> '''' /* if file name already exists, throw error while assigning again */
	Begin
		SET @message =''Can not assign. Final Ad Copy already assigned. Please refersh the page'';
		THROW 50000,@message , 1; 
		return;

	End

	BEGIN TRANSACTION
	BEGIN TRY

		Declare @inJobStatus int	
		Set @inJobStatus = (Select JobStatusLookupId from CWI_Job where id=@jobId)

		if @inJobStatus = 8012  ---lookup id 8012 is assigned job status
		begin
			update CWI_Job set JobStatusLookupId=8001 where ID=@jobId	---setting job status as In Progress from Assigned
		end


		IF ISNULL(@fileName,'''')='''' /* if file name is empty, unassign */
		BEGIN
			IF ISNULL(@existingFileName ,'''') <> '''' /* if final ad copy already assigned, then unassign */
			Begin
				SET @action = ''unassigned''
				SET @ActionLookupId = 10021
				UPDATE CWI_JobMediaBuy SET FinalAdCopyPath = NULL, FinalAdCopyFileName = NULL, 
				FinalAdCopyModifiedBy =@author, FinalAdCopyModifiedOn = @dt where id=@mediabuyId;
			End
		END
		ELSE/* if file name is not empty, assign */
		BEGIN
			IF ISNULL(@existingFileName ,'''') = '''' /* if final ad copy NOT already assigned, then assign */
			Begin
				SET @action = ''assigned''
				SET @ActionLookupId = 10020
				IF @isNewAdCopy = 1 /*If Final ad copy is assigned first time, update created by and on */ 
				Begin
					UPDATE CWI_JobMediaBuy SET FinalAdCopyPath = @filePath, FinalAdCopyFileName = @fileName,
					FinalAdCopyCreatedBy =@author, FinalAdCopyCreatedOn = @dt, 
					FinalAdCopyModifiedBy =@author, FinalAdCopyModifiedOn = @dt 
					where id= @mediabuyId
				End
				ELSE
				Begin
					UPDATE CWI_JobMediaBuy SET FinalAdCopyPath = @filePath, FinalAdCopyFileName = @fileName, 
					FinalAdCopyModifiedBy =@author, FinalAdCopyModifiedOn = @dt 
					where id= @mediabuyId
				End
			End
		
		END

		IF @action <> ''''
		Begin
			SELECT @authorName = Names FROM CWI_User WHERE Id = @author

				--Inserting into Action table to track History
			DECLARE @InsertAction varchar(8000)
			DECLARE @InsertActionLink varchar(8000)
			DECLARE @dtModifiedBy varchar(50)


			SET @dtModifiedBy = FORMAT(@dt, ''MM/dd/yyyy hh:mm tt'')

			SET @InsertAction = ''Final Ad Copy '' + @action +  '' for Media Buy '' + @VendorName + '' by '' + @AuthorName + '' on '' + @dtModifiedBy
			

			EXEC prc_CWI_SetAction @ObjectLookupId = 205 /* Job */, @ObjectId = @jobId,
				@ActionLookupId = @ActionLookupId,
				@Action = @InsertAction,
				@ActionWithLink = @InsertAction,
				@CreatedBy = @author	

			------------for media buy history---------
			EXEC prc_CWI_SetAction @ObjectLookupId = 211, @ObjectId = @mediabuyId,
				@ActionLookupId = @ActionLookupId,
				@Action = @InsertAction,
				@ActionWithLink = @InsertAction,
				@CreatedBy = @author
		End
	END TRY
	BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION ;


' 
END
GO
