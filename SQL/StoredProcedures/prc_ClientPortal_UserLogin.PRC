SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_UserLogin]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_UserLogin]
GO

CREATE PROC prc_ClientPortal_UserLogin
    @Email varchar(100)
   ,@Password  varchar(50)
   ,@UserMessage varchar(500) OUTPUT
   ,@ErrorMessage varchar(500) OUTPUT
AS

DECLARE 
  @MaxLoginAttempts int
 ,@PassPhrase varchar(50)
 ,@PasswordExpireEnabled bit
 ,@PasswordExpirePeriod int
 ,@UserInactiveEnabled bit
 ,@UserInactivePeriod int
 ,@EncryptedPassword varbinary(8000)
 ,@DecryptedPassword varchar(50)
 ,@LoginAttempts int
 ,@UserID int
 ,@Locked bit
 ,@Expired bit
 ,@PasswordDate datetime
 ,@LastLoginDate datetime
 ,@TimeElapsed int

SET NOCOUNT ON;

BEGIN TRANSACTION
BEGIN TRY

	IF NOT EXISTS ( SELECT  1
                        FROM CWI_ClientContactPortal CWP
                        INNER JOIN CWI_ClientContact CC
                        ON CWP.Email = CC.Email
                        INNER JOIN CWI_Client C
                        ON C.ID = CC.ClientID
                        WHERE CC.IsDeleted = 0
                        AND CC.IsCWPortalUser = 1
                        AND CWP.IsEnabled = 1
                        AND CWP.Email = @Email)
	
		SET @UserMessage = 'User does not exist.'
	ELSE
	BEGIN
	    
	    /* Get Security Configuration for all users */
	    SELECT @MaxLoginAttempts = MaxLoginAttempts
		  ,@PassPhrase = PasswordPassPhrase
		  ,@PasswordExpireEnabled = PasswordExpireEnabled
		  ,@PasswordExpirePeriod = PasswordExpirePeriod
		  ,@UserInactiveEnabled = UserInactiveEnabled
		  ,@UserInactivePeriod = UserInactivePeriod
            FROM [dbo].[CWI_PasswordRule]
		
	    /* Get user information */
	    SELECT @UserID = [ID]
	          ,@EncryptedPassword = [Password]
		  ,@LoginAttempts = [LoginAttempts]
		  ,@Locked = [IsLocked]
		  ,@TimeElapsed = DATEDIFF(minute, IsNull(ModifiedOn,GetDate()), GetDate())
		  ,@PasswordDate = [PasswordChangeDate]
		  ,@LastLoginDate = ISNULL([LastLoginDate],[CreatedOn])
	    FROM [dbo].[CWI_ClientContactPortal]
	    WHERE [Email] = @Email
	            
	    IF @Locked = 1 
            BEGIN
                /* Wait for 5 minutes before the next login attempt */
                IF @TimeElapsed <= 5
                   SET @Locked = 1
                ELSE
                   SET @Locked = 0
            END
                
            /* Are we still in a locked state ? */
            IF @Locked = 1
               SET @UserMessage = 'User account has been locked. Please wait for 5 minutes and try again.'
            ELSE
            BEGIN
               /* Validate Password first */
               SELECT @DecryptedPassword = Convert(varchar,DECRYPTBYPASSPHRASE(@PassPhrase,@EncryptedPassword))
        
               IF @Password = @DecryptedPassword
               BEGIN 
            	
            	  SET @Expired = 0
            	
                  /* Check for password expiry */
                  IF @PasswordExpireEnabled = 1
                  BEGIN
                     IF DateDiff(day,@PasswordDate, GetDate()) > @PasswordExpirePeriod
	      	        SET @Expired = 1
	          END
                                   
                  /* Check for User inactivty */
                  IF @UserInactiveEnabled = 1
                  BEGIN
       	             IF DateDiff(day,@LastLoginDate, GetDate()) > @UserInactivePeriod
       	                SET @Expired = 1
                  END
              
                  IF @Expired = 1
                  BEGIN
                      /* User Account or password has expired. Force the user to change password  */
                      UPDATE [dbo].[CWI_ClientContactPortal]
  	              SET LoginAttempts = 0
  	                 ,IsPasswordReset = 1
  	                 ,IsLocked = 0
  	                 ,IsExpired = 1
  	  	         ,LastLoginDate = IsNull(CurrentLoginDate,GetDate())
  	  	         ,CurrentLoginDate = GetDate()
  	  	         ,IsLastLoginSuccess = 1
  	  	         ,ClientModifiedBy = @UserID
  	  	         ,ClientModifiedOn = GetDate()
	              WHERE ID = @UserID
                  END
                  ELSE
                  BEGIN
                      /* Normal Login */
                      UPDATE [dbo].[CWI_ClientContactPortal]
  	              SET LoginAttempts = 0
  	                 ,IsPasswordReset = 0
  	                 ,IsLocked = 0
  	                 ,IsExpired = 0
  	  	         ,LastLoginDate = IsNull(CurrentLoginDate,GetDate())
  	  	         ,CurrentLoginDate = GetDate()
  	  	         ,IsLastLoginSuccess = 1
  	  	         ,ClientModifiedBy = @UserID
  	  	         ,ClientModifiedOn = GetDate()
	              WHERE ID = @UserID
                 END
                      
                 /* Send UserID back */
                 SELECT ID AS UserID
  	         FROM [dbo].[CWI_ClientContactPortal]
  	         WHERE ID = @UserID
               END
               ELSE
               BEGIN
               	 /* User sent a bad password. Check if we need to lock the user if max login attempt exceeded */
               	  IF @LoginAttempts + 1 >= @MaxLoginAttempts
               	  BEGIN
               	     SET @LoginAttempts = @MaxLoginAttempts
               	     SET @Locked = 1
               	  END
		  ELSE
		  BEGIN
		     SET @LoginAttempts = @LoginAttempts + 1
               	     SET @Locked = 0               	     
               	  END
               	     
               	  UPDATE [dbo].[CWI_ClientContactPortal]
  	              SET LoginAttempts = @LoginAttempts
  	                 ,IsPasswordReset = 0
  	                 ,IsLocked = @Locked
  	                 ,IsLastLoginSuccess = 0
  	                 ,ClientModifiedBy = @UserID
  	  	         ,ClientModifiedOn = GetDate()
	          WHERE ID = @UserID
  	          
                  SET @UserMessage = 'Password provided is invalid.'
               END
	    END   	
       END
   COMMIT TRANSACTION
END TRY
BEGIN CATCH
	SELECT @ErrorMessage = ERROR_MESSAGE()
	ROLLBACK TRANSACTION
END CATCH
GO
