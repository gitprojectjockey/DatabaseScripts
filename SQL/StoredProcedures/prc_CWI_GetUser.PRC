

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUser]    Script Date: 6/27/2013 6:36:11 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetUser')
DROP PROCEDURE [dbo].[prc_CWI_GetUser]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUser]    Script Date: 6/27/2013 6:36:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetUser  
* Purpose : This PROC would be called TO get the user info
* Invoked from : ClientWise.master
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetUser @Login	= 'msundaram',@Domain = 'OSS'
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetUser]
	@Login	varchar(100),
	@Domain	varchar(100),
	@IsSetLastLoggedIn bit = 0
AS
BEGIN
	SELECT 
		Id UserId,
		[Login] LoginName,
		Domain LoginDomain,
		Names UserName,
		Email EmailAddress,
		IsActive,
		cast('' as varchar(max)) Groups,
		LastLoggedIn
	FROM CWI_User 
	WHERE 
		[Login] = @login 
		and domain = @domain
	IF @IsSetLastLoggedIn = 1
	BEGIN
		UPDATE CWI_User SET LastLoggedIn = GETDATE()
		WHERE 
			[Login] = @login 
			and domain = @domain
	END
END	



GO

