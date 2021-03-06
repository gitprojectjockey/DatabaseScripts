/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobFinalAdToSend]    Script Date: 6/4/2014 9:12:29 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobFinalAdToSend]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobFinalAdToSend]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobFinalAdToSend]    Script Date: 6/4/2014 9:12:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobFinalAdToSend]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobFinalAdToSend 
* Purpose : This PROC would be called TO insert the records in correspondence table to send the final ad copy to media buys
* Invoked from : Jobs.aspx
* CREATED: Mohankumar	02JUN14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
   						
**********************************************************************  
Execution example :,
**********************************************************************  
EXEC prc_CWI_SetJobFinalAdToSend 1345,3
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobFinalAdToSend]	
	@inJobId bigint,	
	@inUserId int
AS
BEGIN	

		
	DECLARE @InsertAction varchar(8000)
	DECLARE @InsertActionLink varchar(8000)
	DECLARE @AuthorName varchar(1000)
	DECLARE @dtModifiedBy varchar(50)

	DECLARE @inVendorStatus bit,@isGenerate bit,@inMMRPO int,@inVendorCount int

	DECLARE 
			@IsQuote bit = 0,
			@inMediaBuyStatus int = 20103	

	DECLARE @dt datetime= GETDATE()
	SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
	SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

	DECLARE @tblJobActionAttribute tt_CWI_JobActionAttribute
	INSERT INTO @tblJobActionAttribute
	EXEC prc_CWI_GetJobActionAttributes @inJobId

		
	DECLARE @actionMessage varchar(max) = ''''

	BEGIN TRANSACTION
	BEGIN TRY	

		------If all validations are success then update action & correspondence tables----

		UPDATE 	
			[dbo].[CWI_JobMediaBuy]	
		SET 
			FinalAdCopyModifiedBy=@inUserId,
			FinalAdCopyModifiedOn=@dt,
			FinalAdCopySentBy	=@inUserId,
			FinalAdCopySentOn=@dt	
		WHERE [JobId]=@inJobId 
		AND IsRemoved = 0 AND IsCancelled = 0 AND DNR = 0

		DECLARE @action varchar(100)=''Final Ad Copy''

		SET @InsertAction =@action + '' sent by ''+ @AuthorName + '' on '' + @dtModifiedBy 
		SET @InsertActionLink=@action +'' for job '' + Convert(varchar,@inJobId) + '' <a href="../jobs.aspx?jobid='' +
			 Convert(varchar,@inJobId) + ''></a>'' + '' sent by '' + @AuthorName + '' on '' + @dtModifiedBy
			
		EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
			@ActionLookupId = 10022/*Final Ad copy sent */,
			@Action = @InsertAction,
			@ActionWithLink = @InsertActionLink,
			@CreatedBy = @inUserId
					
				
		DECLARE @CorrespondenceTypeLookupId int  = 708 /* Camera Ready Ad Copy */

		EXECUTE prc_CWI_SetCorrespondence 	
			@JobId = @inJobId,
			@MMRPO = NULL,
			@CorrespondenceTypeLookupId = @CorrespondenceTypeLookupId,
			@Source  = ''Clientwise Internal'',
			@Author = @inUserId		


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
