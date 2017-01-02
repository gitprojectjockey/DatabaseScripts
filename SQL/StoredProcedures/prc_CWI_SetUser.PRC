

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUser]    Script Date: 4/25/2013 2:43:10 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetUser')
DROP PROCEDURE [dbo].[prc_CWI_SetUser]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUser]    Script Date: 4/25/2013 2:43:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_SetUser  
* Purpose : This PROC would be called TO insert the user
* Invoked from : ClientWise.master
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetUser @Login	= 'msundaram',@Domain = 'OSS', @Names ='MohanKumar Sundaram'	,
			@Email	= 'MohanKumar.Sundaram@xerox.com', @IsActive=1, @CreatedBy = 'OSS\msundaram'
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetUser]
	@Login	varchar(100),
	@Domain	varchar(100),
	@Names	varchar(200),
	@Email	varchar(100),
	@IsActive	bit,
	@CreatedBy	varchar(100)
	
AS
	DECLARE @OldEmail varchar(100)
	DECLARE @UserId int
	DECLARE @IsNewUser bit
	SET @IsNewUser = 0
	SET @UserId = 0
	SELECT @UserId = Id, @OldEmail = ISNULL(Email,'')   FROM CWI_User WHERE Login = @login and domain = @domain
	
	IF @UserId = 0
	BEGIN
		SET @IsNewUser = 1
		INSERT INTO [dbo].[CWI_User]
			   ([Login]
			   ,[Domain]
			   ,[Names]
			   ,[Email]
			   ,[IsActive]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn]
			   ,LastLoggedIn)
		 VALUES
			   (@Login	,
				@Domain,
				@Names	,
				@Email	,
				@IsActive	,
				@CreatedBy,
				getdate(),
				@CreatedBy,
				getdate(),
				getdate())

		SET @UserId = SCOPE_IDENTITY()
	END
	ELSE IF @OldEmail = '' AND ISNULL(@Email,'') <> ''
	BEGIN
		UPDATE [CWI_User] SET EMail = @Email, LastLoggedIn = getdate()
		WHERE Id = @UserId
	END
	ELSE
	BEGIN
		UPDATE [CWI_User] SET  LastLoggedIn = getdate()
		WHERE Id = @UserId
	END

	SELECT 
		Id UserId,
		[Login] LoginName,
		Domain LoginDomain,
		Names UserName,
		Email EmailAddress,
		IsActive,
		cast('' as varchar(max)) Groups,
		CASE @IsNewUser WHEN 1 THEN NULL ELSE LastLoggedIn END LastLoggedIn
	FROM CWI_User 
	WHERE 
		Id = @UserId



GO
