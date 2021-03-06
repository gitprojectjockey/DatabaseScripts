/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileResponseTranslation]    Script Date: 9/23/2014 6:21:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileResponseTranslation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileResponseTranslation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileResponseTranslation]    Script Date: 9/23/2014 6:21:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileResponseTranslation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileResponseTranslation 
* Purpose : This PROC would be called TO INSERT OR UPDATE the profile response translation details
* Invoked from : Profile_ResponseTranslation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE       AUTHOR          DESCRIPTION  
 23-Aug-2014 Vijesh			 Modified for checking the existence of same translation for the same channel

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileResponseTranslation NULL,13957,2,''ACS - XEROX Facebook''
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetClientProfileResponseTranslation]
	@inTranslationId int=NULL,
	@ClientId int,
	@ChannelId int,
	@ClientTranslation varchar(200),	
	@Author int
	--@inRowCount int OUTPUT  
AS
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION TRAN1
			BEGIN TRY
				IF @inTranslationId IS NOT NULL
				BEGIN
					UPDATE	CWI_ClientProfileResponseTranslation
					SET	ClientId = @ClientId,
						ChannelId = @ChannelId,
						ClientTranslation = @ClientTranslation,				
						ModifiedOn = GETDATE(),
						ModifiedBy = @Author
					WHERE Id = @inTranslationId
					--SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
				END
				ELSE
				BEGIN

					begin try
					IF EXISTS(SELECT top 1 1 FROM CWI_ClientProfileResponseTranslation WHERE 
					ClientTranslation = @ClientTranslation and ChannelId=@ChannelId)
					begin
						declare @message NVARCHAR(2000) = ''Client Translation already exists for the selected channel'';
						THROW 50000,@message , 1; 
					end						
					end try
					begin catch
						throw;
					end catch

					INSERT INTO CWI_ClientProfileResponseTranslation
					(ClientId, ChannelId, ClientTranslation, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
					VALUES 
					(@ClientId, @ChannelId, @ClientTranslation, GETDATE(), @Author, GETDATE(), @Author)
					--SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
				END
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT >0 
					ROLLBACK TRANSACTION TRAN1;
				EXEC prc_CWI_AppRaiseError;
				THROW;
			END CATCH
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION TRAN1;
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END


' 
END
GO
