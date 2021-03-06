/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientContactPortalProfile]    Script Date: 10/1/2014 4:04:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientContactPortalProfile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientContactPortalProfile]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientContactPortalProfile]    Script Date: 10/1/2014 4:04:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientContactPortalProfile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_CWI_SetClientContactPortalProfile]
	@clientPortalId int,
	@email varchar(100), 
	@Name varchar(100), 
	@PhoneWork varchar(50),
	@author int

AS

	DECLARE @dt datetime = getdate(),
		@existingEmail varchar(100)
	declare @message NVARCHAR(2000) 

	SELECT @existingEmail  =Email FROM CWI_ClientContactPortal
	WHERE Id  = @clientPortalId

	IF @email<> @existingEmail /* If email is changed, then check for duplication */
	Begin
		IF EXISTS(
		SELECT 
			top 1 1
		FROM [CWI_ClientContactPortal]
		where Email = @email
			 and Id <> @clientPortalId)
		begin
			SET @message = ''Email already exists for other portal user'';
			THROW 50000,@message , 1; 
		end
	End

	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE [CWI_ClientContactPortal] SET email = @email,
		ModifiedBy = @author,
		ModifiedOn = @dt
		WHERE
			Id  = @clientPortalId
			AND email <> @email

		UPDATE [CWI_ClientContact] SET email = @email,
		Name = @Name,
		PhoneWork = @PhoneWork,
		ModifiedBy = @author,
		ModifiedOn = @dt
		WHERE
			Email = @existingEmail
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION ;' 
END
GO
