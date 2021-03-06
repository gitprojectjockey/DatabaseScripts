/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientCWPortalAccess]    Script Date: 9/10/2014 8:31:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientCWPortalAccess]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientCWPortalAccess]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientCWPortalAccess]    Script Date: 9/10/2014 8:31:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientCWPortalAccess]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_SetClientCWPortalAccess]
* Purpose : This PROC would be called TO INSERT OR UPDATE the client portal access details
* Invoked from : Client_Contact.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  02SEP14	Mohankumar		New table CWI_ClientContactPortal is used to save the portal credentials

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientCWPortalAccess 5, 0,1, 0, ''test'', 3
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientCWPortalAccess]	
	@inClientContactId int,
	@IsLocked bit,
	@IsEnabled bit,
	@IsExpired bit,
	@vcPassword varchar(50)=NULL,
	@inUserId int,
	@templateId int = NULL	 out

AS
BEGIN	
	
	DECLARE @email VARCHAR(100), @id int = NULL, @dt datetime = getdate(),
		@encrptPassword varbinary(100), @userEmail varchar(500)

	SELECT @Email = Email from CWI_ClientContact WHERE Id = @inClientContactId

	SELECT TOP 1 @id = id  FROM CWI_ClientContactPortal
	WHERE Email  =@email

	SELECT 	@userEmail = Email FROM CWI_User WHERE Id = @inUserId
	BEGIN TRANSACTION
	BEGIN TRY
		IF @id IS NULL
		BEGIN
			SET  @encrptPassword = dbo.fnc_CWI_EncryptPortalPassword(@vcPassword)
			INSERT CWI_ClientContactPortal
			(
				Email, 
				[Password], 
				IsLocked, 
				IsExpired, 
				IsEnabled, 
				IsPasswordReset, 
				CreatedBy, 
				CreatedOn,
				 ModifiedBy,
				 ModifiedOn
			)
			VALUES 
			(
				@Email, 
				@encrptPassword, 
				COALESCE(@IsLocked, (0)), 
				COALESCE(@IsExpired, (0)),
				 COALESCE(@IsEnabled, (1)), 
				 1, 
				   @inUserId, @dt, @inUserId, @dt
			)

			SET @templateId = 26 -- ClientwisePortalNewUser

			DECLARE @newId int
			SET @newId = SCOPE_IDENTITY()
			
			INSERT INTO  CWI_History_PortalUserPassword
			(PortalUserID,Password,CreatedBy)
			VALUES
			(@newId, @encrptPassword,@userEmail)
		END 
		ELSE
		BEGIN
			IF @vcPassword IS NOT NULL
			Begin
				SET  @encrptPassword = dbo.fnc_CWI_EncryptPortalPassword(@vcPassword)

				SET @templateId = 27 -- ClientwisePortalPasswordReset

				INSERT INTO  CWI_History_PortalUserPassword
				(PortalUserID,Password,CreatedBy)
				VALUES
				(@id, @encrptPassword,@userEmail)
			End
			UPDATE	CWI_ClientContactPortal
			SET	Email = @Email,
				IsLocked = COALESCE(@IsLocked, (0)),
				IsExpired = COALESCE(@IsExpired, (0)),
				IsEnabled = COALESCE(@IsEnabled, (1)),
				IsPasswordReset = CASE WHEN @vcPassword IS NULL THEN IsPasswordReset ELSE 1 END,
				PasswordChangeDate = CASE WHEN @vcPassword IS NULL THEN PasswordChangeDate ELSE @dt END,
				[Password] = CASE WHEN @vcPassword IS NULL THEN [Password] ELSE @encrptPassword END,
				CreatedBy = @inUserId,
				CreatedOn = @dt,
				ModifiedBy = @inUserId,
				ModifiedOn = @dt
			WHERE 	Id = @Id


		END
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
	IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ;
END
	

	






' 
END
GO


