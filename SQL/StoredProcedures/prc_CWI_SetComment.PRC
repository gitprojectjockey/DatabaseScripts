/****** Object:  StoredProcedure [dbo].[prc_CWI_SetComment]    Script Date: 8/19/2014 3:06:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetComment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetComment]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetComment]    Script Date: 8/19/2014 3:06:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetComment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetComment 
* Purpose : This PROC would be called TO INSERT OR UPDATE the comments associated with a module/category
* Invoked from : Comment.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  13AUG14	Mohankumar		User name are saved            

**********************************************************************  
Execution example :
**********************************************************************  
DECLARE @inUserId int,
    @inObjectLookupId int,
	@inObjectId int,
	@inCommentId int,
	@vcComment varchar(MAX),
	@inRowCount int
exec prc_CWI_SetComment 7,201,1, 1, ''TEST'',@inRowCount output, ''test'', ''test@test.com''
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetComment]
    @inUserId int,
    @inObjectLookupId int=NULL,
	@inObjectId bigint=NULL,
	@inCommentId bigint=NULL,
	@vcComment varchar(MAX),
	@inRowCount int OUTPUT,
	@vcUserName varchar(100)=NULL,
	@vcUserEmail varchar(100)=NULL
AS
BEGIN	
	BEGIN TRY
		IF ISNULL(@vcUserName,'''')= '''' /* if user name not passed, get user name from DB */
		Begin
			SELECT @vcUserName=Names, @vcUserEmail = Email FROM CWI_User WHERE Id = @inUserId
		End
		IF @inCommentId IS NULL
		BEGIN
			INSERT INTO [dbo].[CWI_Comment] 
			([ObjectLookupId],[ObjectId],[Comment],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy],
			CreatedByName,
			CreatedByEmail,
			ModifiedByName,
			ModifiedbyEmail)
			VALUES
			(@inObjectLookupId,@inObjectId,@vcComment,GETDATE(),@inUserId,GETDATE(),@inUserId,
			@vcUserName,
			@vcUserEmail,
			@vcUserName,
			@vcUserEmail
			)

			
		END
		ELSE
		BEGIN
			INSERT INTO [dbo].[CWI_History_Comment] ([CommentId],[Comment],[ModifiedOn],[ModifiedBy],ModifiedByName,
			ModifiedbyEmail)
			SELECT [Id],[Comment],[ModifiedOn],[ModifiedBy], ModifiedByName, ModifiedbyEmail FROM [dbo].[CWI_Comment]
			WHERE [Id]=@inCommentId

			UPDATE [dbo].[CWI_Comment] 
			SET [Comment]=@vcComment, [ModifiedBy]=@inUserId, [ModifiedOn]=GETDATE(),
				ModifiedByName= @vcUserName, ModifiedByEmail = @vcUserEmail
			WHERE [Id]=@inCommentId
		END
		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
		IF @inObjectLookupId = 215 /* Virtual Card */
		begin
			UPDATE CWI_VCMediaBuy SET VCLastComment = @vcComment
			WHERE MediaBuyId = @inObjectId
		end
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	




' 
END
GO


