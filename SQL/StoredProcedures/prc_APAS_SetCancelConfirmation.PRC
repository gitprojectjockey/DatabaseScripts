/****** Object:  StoredProcedure [dbo].[prc_APAS_SetCancelConfirmation]    Script Date: 9/2/2014 1:46:39 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_SetCancelConfirmation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_SetCancelConfirmation]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_SetCancelConfirmation]    Script Date: 9/2/2014 1:46:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_SetCancelConfirmation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_APAS_SetCancelConfirmation  
* Purpose : This PROC would be called TO set cancellation confirmation details
* Invoked from : cancellation.aspx
* CREATED: MohanKumar S
undaram 19thAUG14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
***************************************************************
*******  
exec prc_APAS_SetCancelConfirmation
	123,
	''test@tets.com'',''test'', 0, ''2014-10-01 22:12'', ''Deadline passed''

  
**********************************************************************/ 
 
CREATE PROCEDURE [dbo].[prc_APAS_SetCancelConfirmation]
	@MediaBuyId bigint
    ,@Email varchar(50)
    ,@Author varchar(50) 
    ,@IsAgreed bit 
	,@CorrespondenceRefId bigint
    ,@DeadLine datetime  = NULL
	,@notes varchar(max) = NULL
	 
AS
DECLARE @IsNew bit = 1,
	@dt datetime = getdate()

If exists (Select  top 1 1 from CWI_MediabuyCancelConfirmation Where MediabuyId = @MediaBuyId )
begin
	SET @IsNew = 0
end

BEGIN TRANSACTION
BEGIN TRY
	 if @IsNew = 1
	 Begin
	  INSERT INTO CWI_MediabuyCancelConfirmation
	  (
		MediabuyId,
		CreatedBy,
		CreatedByEmail,
		CreatedOn,
		ModifiedBy,
		ModifiedByEmail,
		ModifiedOn,
		IsAccepted,
		DeadLineOn,
		CorresDeliveryId
	  )
	  VALUES
	  (
		@MediaBuyId,
		@Author,
		@Email,
		@dt,
		@Author,
		@Email,
		@dt,
		@IsAgreed,
		@DeadLine,
		@CorrespondenceRefId
	  )
	End
	 else
	Begin
		UPDATE  CWI_MediabuyCancelConfirmation 
		SET 
			ModifiedBy=@Author,
			ModifiedOn=@dt,
			ModifiedByEmail=@Email,
			IsAccepted=@IsAgreed,
			DeadLineOn = @DeadLine ,
			CorresDeliveryId = @CorrespondenceRefId
		WHERE MediaBuyId=@MediaBuyId
	 End

	DECLARE @comment varchar(max)=''''
		
	SET @comment = ''Cancellation was '' + (CASE WHEN @IsAgreed = 1 THEN ''confirmed'' ELSE ''denied'' END) 
		+ ( CASE WHEN LTRIM(RTRIM(ISNULL(@notes,'''')))='''' THEN '''' ELSE '' with the notes: '' + @notes END)
			
		

	EXEC prc_CWI_SetComment @inUserId = 1, /*system*/
		@inObjectLookupId =211, /*MediaBuy*/
		@inObjectId= @MediaBuyId,
		@inCommentId = NULL,
		@vcComment= @comment,
		@inRowCount = NULL,
		@vcUserName = @Author,
		@vcUserEmail = @Email
	
	
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


