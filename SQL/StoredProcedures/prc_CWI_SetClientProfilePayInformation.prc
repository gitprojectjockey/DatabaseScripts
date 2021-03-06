/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfilePayInformation]    Script Date: 4/3/2014 6:54:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfilePayInformation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfilePayInformation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfilePayInformation]    Script Date: 4/3/2014 6:54:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfilePayInformation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfilePayInformation 
* Purpose : This PROC would be called TO INSERT OR UPDATE the pay information details
* Invoked from : Profile_PayInformation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE          AUTHOR          DESCRIPTION              
30-Jul-2013     Vijesh
**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfilePayInformation 14174,
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfilePayInformation]	
	@inClientId int,
	@vcDriverPayId varchar(MAX)=NULL,
	@inUserId int,
	@PayDetail tt_Profile_PayExperience READONLY,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY	
		IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfile] WHERE ClientID=@inClientId)
		BEGIN
			INSERT INTO [dbo].[CWI_ClientProfile]
			([ClientID],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
			VALUES
			(@inClientId,GETDATE(),@inUserId,GETDATE(),@inUserId)
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
		END

		IF @vcDriverPayId IS NOT NULL
			BEGIN
				IF EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfilePayInformation] WHERE ClientID=@inClientId)
				BEGIN
					DELETE FROM [dbo].[CWI_ClientProfilePayCycleDetails] WHERE [UnloadPayID] IN
					(SELECT DISTINCT ID FROM [dbo].[CWI_ClientProfileDriverPayDetail] WHERE [PayInformationID] IN
					(SELECT DISTINCT ID FROM [dbo].[CWI_ClientProfilePayInformation] WHERE [ClientID]=@inClientId))

					DELETE FROM [dbo].[CWI_ClientProfileDriverPayDetail] WHERE [PayInformationID] IN
					(SELECT DISTINCT ID FROM [dbo].[CWI_ClientProfilePayInformation] WHERE [ClientID]=@inClientId)

					DELETE FROM [dbo].[CWI_ClientProfilePayInformation] WHERE [ClientID]=@inClientId				
				END				
				INSERT INTO [dbo].[CWI_ClientProfilePayInformation]
				([ClientID],[DriverPayID],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])					
				SELECT @inClientId,Items,
				GETDATE(),@inUserId,GETDATE(),@inUserId  FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcDriverPayId,'','')
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
			END
			
		IF (SELECT COUNT(*) FROM @PayDetail) <> 0
		BEGIN
			IF NOT EXISTS(SELECT [ClientID] FROM [dbo].[CWI_ClientProfilePayExperience] WHERE [ClientID]=@inClientId)
			BEGIN				
				INSERT INTO [dbo].[CWI_ClientProfilePayExperience]
				([ClientID],[PayExperienceID],[StartingPay],
				[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				SELECT [ClientID],[PayExperienceID],[StartingPay],
				GETDATE(),[UserID],GETDATE(),[UserID]
				FROM @PayDetail									
			END
			ELSE
			BEGIN
				DELETE FROM [dbo].[CWI_ClientProfilePayExperience] WHERE [ClientID]=@inClientId

				INSERT INTO [dbo].[CWI_ClientProfilePayExperience]
				([ClientID],[PayExperienceID],[StartingPay],
				[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				SELECT [ClientID],[PayExperienceID],[StartingPay],
				GETDATE(),[UserID],GETDATE(),[UserID]
				FROM @PayDetail
			END	
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
		END 			
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
' 
END
GO
