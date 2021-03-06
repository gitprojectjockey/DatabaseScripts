/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteJobService]    Script Date: 6/17/2014 7:00:46 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteJobService]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteJobService]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteJobService]    Script Date: 6/17/2014 7:00:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteJobService]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteJobService 
* Purpose : This PROC would be called to delete the job service  fee
* Invoked from : JobService.aspx
* CREATED: MohanKumar Sundaram 16MAY14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_DeleteJobService 16 , 1122
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_DeleteJobService]       
@inJobServiceId bigint,
@inUserId int  
AS
BEGIN
    DECLARE @dt datetime = getdate()
	DECLARE @dtString varchar(100) =  FORMAT( @dt, ''MM/dd/yyyy hh:mm tt'')
	
	
	DECLARE @InsertAction varchar(8000), @ServiceDescription varchar(max)
	
	DECLARE @AuthorName varchar(1000), @IsCancelled bit, @InvoiceId bigint

	SELECT TOP 1 @IsCancelled = IsCancelled, @InvoiceId = J.InvoiceId FROM [dbo].CWI_JobService JS 
	INNER JOIN CWI_Job J 
		ON J.Id = JS.JobId 
	WHERE JS.[Id]=@inJobServiceId

	IF @InvoiceId IS NOT NULL
	BEGIN
		declare @message NVARCHAR(2000) = ''Can''''t remove. Job invoiced'';
		THROW 50000,@message , 1; 
	END

	IF @IsCancelled = 1
	BEGIN
		SET @message  = ''Can''''t remove. Job cancelled'';
		THROW 50000,@message , 1; 
	END

	BEGIN TRANSACTION
	BEGIN TRY
		
		UPDATE [dbo].[CWI_JobService]
		SET IsDeleted=1,ModifiedOn=GETDATE(),ModifiedBy=@inUserId
		WHERE Id=@inJobServiceId AND IsDeleted=0
		AND  StatusLookupId = 20171 /* Pending Invoice */

		IF @@ROWCOUNT>0
		BEGIN
			--Inserting into Action table to track History
			SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

			SELECT @ServiceDescription = ServiceDescription FROM CWI_JobService WHERE Id = @inJobServiceId

			SET @InsertAction = '' Service for the job ''  + @ServiceDescription +'' removed by '' + @AuthorName + '' on '' + @dtString
			
		
			EXEC prc_CWI_SetAction @ObjectLookupId = 213/*JobServiceFee*/, 
				@ObjectId = @inJobServiceId,
				@ActionLookupId = 10018/*Job Service Fee Updated*/,
				@Action = @InsertAction,
				@ActionWithLink = @InsertAction,
				@CreatedBy = @inUserId	
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
