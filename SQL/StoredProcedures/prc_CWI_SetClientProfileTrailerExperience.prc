/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileTrailerExperience]    Script Date: 4/3/2014 6:54:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileTrailerExperience]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileTrailerExperience]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileTrailerExperience]    Script Date: 4/3/2014 6:54:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileTrailerExperience]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileTrailerExperience 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile trailer experience details
* Invoked from : Profile_TrailerExperience.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileTrailerExperience 14174,
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileTrailerExperience]	
	@inClientId int,
	@TrailerDetail tt_Profile_TrailerExperience READONLY,
	@inUserId INT,
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
					
			IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfileTrailerExperience] WHERE ClientID=@inClientId)
			BEGIN				
					INSERT INTO [dbo].[CWI_ClientProfileTrailerExperience]
					([ClientID],[TrailerExperienceID],[Years],[Months],[DurationOther],[IsNotRequired],[IsNotRelevant],
					[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
					SELECT [ClientID],[TrailerExperienceID],[Years],[Months],[DurationOther],[IsNotRequired],[IsNotRelevant],
					GETDATE(),[UserID],GETDATE(),[UserID]
					FROM @TrailerDetail		
					SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)							
			END
			ELSE
			BEGIN
				DELETE FROM [dbo].[CWI_ClientProfileTrailerExperience] WHERE ClientID=@inClientId

				INSERT INTO [dbo].[CWI_ClientProfileTrailerExperience]
				([ClientID],[TrailerExperienceID],[Years],[Months],[DurationOther],[IsNotRequired],[IsNotRelevant],
				[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				SELECT [ClientID],[TrailerExperienceID],[Years],[Months],[DurationOther],[IsNotRequired],[IsNotRelevant],
				GETDATE(),[UserID],GETDATE(),[UserID]
				FROM @TrailerDetail	
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
