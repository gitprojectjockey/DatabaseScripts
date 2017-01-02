SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
           FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[prc_ClientPortal_ChangeUserPassword]') AND type in (N'P'))
   DROP PROCEDURE [dbo].[prc_ClientPortal_ChangeUserPassword]
GO

CREATE PROC prc_ClientPortal_ChangeUserPassword
    @UserID int
   ,@Password  varchar(50)
   ,@ErrorMessage varchar(500) OUT
AS

DECLARE 
  @PassPhrase varchar(50)
 ,@PasswordHistoryEnabled bit
 ,@PasswordHistoryCount int
 ,@HistoryCount int
  
SET NOCOUNT ON;

BEGIN TRANSACTION
BEGIN TRY
	SELECT @PassPhrase = PasswordPassPhrase
	      ,@PasswordHistoryEnabled = PasswordHistoryEnabled
	      ,@PasswordHistoryCount = PasswordHistoryCount
	FROM [dbo].[CWI_PasswordRule]
	
	UPDATE [CWI_ClientContactPortal]
	SET LoginAttempts = 0
	   ,Password = ENCRYPTBYPASSPHRASE(@PassPhrase,@Password)
	   ,IsLocked = 0
	   ,IsPasswordReset = 0
	   ,IsExpired = 0
	   ,PasswordChangeDate = GetDate()
	   ,ClientModifiedBy = @UserID
	   ,ClientModifiedOn = GetDate()
	WHERE ID = @UserID
	
	IF @PasswordHistoryEnabled = 1
	BEGIN
	    INSERT INTO [CWI_History_PortalUserPassword]
	       ( PortalUserID
		,Password
		,CreatedBy
		,CreatedOn
	       )
		Values
		( @UserID
		 ,ENCRYPTBYPASSPHRASE(@PassPhrase,@Password)
		 ,@UserID
		 ,GetDate()
	         )
	 
	    /* Keep configured number of history passwords */        
	    SELECT @HistoryCount = COUNT(ID) 
	    FROM  [CWI_History_PortalUserPassword]
            WHERE PortalUserID = @UserID   
            
            IF(@HistoryCount >  @PasswordHistoryCount)
               DELETE FROM CWI_History_PortalUserPassword 
               WHERE ID in 
			   ( 
			      SELECT TOP(1) ID FROM CWI_History_PortalUserPassword 
				  WHERE PortalUserID = @UserID
			      ORDER BY ID ASC
			    )
               
         END
	 COMMIT TRANSACTION
END TRY
BEGIN CATCH
  SELECT @ErrorMessage = ERROR_MESSAGE()
  ROLLBACK TRANSACTION
END CATCH

GO
