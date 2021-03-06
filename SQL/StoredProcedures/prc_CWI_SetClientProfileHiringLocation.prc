/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileHiringLocation]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfileHiringLocation')
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileHiringLocation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileHiringLocation]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileHiringLocation 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile hiring location details
* Invoked from : Profile_HiringLocations.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileHiringLocation 14174,'57676','189','4,5',7
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileHiringLocation]	
	@inClientId int,
	@vcHiringZipCode varchar(10)=NULL,
	@vcRadiusInMiles int=NULL,	
	@vcSubLocationID varchar(max)=NULL, 
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN
BEGIN TRY		
			IF ((@vcHiringZipCode IS NOT NULL) OR (@vcRadiusInMiles IS NOT NULL))
			BEGIN
				IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfile] WHERE ClientID=@inClientId)
				BEGIN									
					INSERT INTO [dbo].[CWI_ClientProfile] 
					([ClientID],[HiringZipCode],[RadiusInMiles],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
					VALUES
					(@inClientId,@vcHiringZipCode,@vcRadiusInMiles,GETDATE(),@inUserId,GETDATE(),@inUserId)
					SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
				END
				ELSE
				BEGIN
					UPDATE [dbo].[CWI_ClientProfile]
					SET [HiringZipCode]=@vcHiringZipCode,[RadiusInMiles]=@vcRadiusInMiles,[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
					WHERE [ClientID]=@inClientId
					SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
				END																
			END

			IF EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfileHiringLocation] WHERE ClientID=@inClientId)
			BEGIN	
				DELETE FROM [dbo].[CWI_ClientProfileHiringLocation] WHERE [ClientID]=@inClientId	
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)				
			END

			IF @vcSubLocationID IS NOT NULL
			BEGIN												
					
				INSERT INTO [dbo].[CWI_ClientProfileHiringLocation]
				([ClientID],[SubLocationID],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])					
				SELECT @inClientId,Items,
				GETDATE(),@inUserId,GETDATE(),@inUserId FROM  dbo.fnc_SplitCSVIntoTableUsingCTE(@vcSubLocationID,',')	
				
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
				
			END				
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	
GO
