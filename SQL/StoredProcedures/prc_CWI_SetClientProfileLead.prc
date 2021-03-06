/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileLead]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfileLead')
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileLead]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileLead]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileLead 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile lead information
* Invoked from : Profile_Lead.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileLead 
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileLead]	
	@inClientId int,
	@inMinAge int=NULL,
	@inMinExperience int=NULL,	
	@IsOTRExperience bit=NULL, 
	@inOTRYears int=NULL,
	@inOTRMonths int=NULL,
	@IsLocalExperience bit=NULL,
	@IsFelonies bit=NULL,
	@IsFelonyBackground bit=NULL,
	@inFelonyYears int=NULL,
	@inFelonyMonths int=NULL,
	@IsDUI bit=NULL,
	@isFormerDUI bit=NULL,
	@inDUIYears int=NULL,
	@inDUIMonths int=NULL,
	@IsDWIViolation bit=NULL,
	@inLicenseClassTypeId int=NULL,
	@IsSuspendedLicense bit=NULL,
	@vcRecklessDriving varchar(255)=NULL,
	@vcMovingViolations varchar(255)=NULL,
	@inNoofMovingViolationsLastYear int=NULL,
	@inNoofMovingViolationsLast5Years int=NULL,
	@inNoofAccidentsLastYear int=NULL,
	@inNoofAccidentsLast3Years int=NULL,
	@inMaxNoofAccidentsLastYear int=NULL,
	@inMaxNoofAccidentsLast5Years int=NULL,
	@vcPreventableAccidents varchar(MAX)=NULL,
	@IsEndorsementsRequired bit=NULL,
	@IsTakeTruckHome bit=NULL,
	@inNoOfTicketsInLast5Years int=NULL,
	@IsDrugFailureAccepted bit=NULL,
	@vcAdditionalRequirements varchar(MAX)=NULL,
	@vcRecruiterName varchar(100)=NULL,
	@vcEmailToSendApps varchar(100)=NULL,
	@IsMatchedLeadsAccept bit=NULL,
	@vcMatchedLeadsEmail varchar(100)=NULL,
	@inMatchedLeadsEmailFormat int=NULL,
	@IsMatchedLeadAutoRespond bit=NULL,
	@IsDirectLeadsAccept bit=NULL,
	@vcDirectLeadEmail varchar(100)=NULL,
	@inDirectLeadEmailFormat int=NULL,
	@IsDirectLeadAutoRespond bit=NULL,
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY		
			
			IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfile] WHERE ClientID=@inClientId)
			BEGIN
				INSERT CWI_ClientProfile(ClientID, MinAge, MinExperience, IsOTRExperience, OTRYears, OTRMonths, IsLocalExperience, IsFelonies, 
				IsFelonyBackground, FelonyYears, FelonyMonths, IsDUI, IsFormerDUI, DUIYears, DUIMonths, 
				IsDWIViolations, LicenseClassTypeId, IsSuspendedLicense, RecklessDriving, MovingViolations, 
				NoofMovingViolationsLastYear, NoofMovingViolationsLast5Years, NoofAccidentsLastYear, 
				NoofAccidentsLast3Years, MaxNoofAccidentsLastYear, MaxNoofAccidentsLast5Years, PreventableAccidents, 
				IsEndorsementsRequired, IsTakeTruckHome, NoOfTicketsInLast5Years, IsDrugFailureAccepted, 
				AdditionalRequirements, RecruiterName, EmailToSendApps, IsMatchedLeadsAccept, MatchedLeadsEmail, 
				MatchedLeadsEmailFormat, IsMatchedLeadAutoRespond, IsDirectLeadsAccept, DirectLeadEmail, 
				DirectLeadEmailFormat, IsDirectLeadAutoRespond, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
				VALUES (@inClientID, @inMinAge, @inMinExperience, @IsOTRExperience, @inOTRYears, @inOTRMonths, @IsLocalExperience, 
				@IsFelonies, @IsFelonyBackground, @inFelonyYears, @inFelonyMonths, @IsDUI, @IsFormerDUI, @inDUIYears, 
				@inDUIMonths, @IsDWIViolation, @inLicenseClassTypeId, @IsSuspendedLicense, @vcRecklessDriving, 
				@vcMovingViolations, @inNoofMovingViolationsLastYear, @inNoofMovingViolationsLast5Years, @inNoofAccidentsLastYear, 
				@inNoofAccidentsLast3Years, @inMaxNoofAccidentsLastYear, @inMaxNoofAccidentsLast5Years, @vcPreventableAccidents, 
				@IsEndorsementsRequired, @IsTakeTruckHome, @inNoOfTicketsInLast5Years, @IsDrugFailureAccepted, 
				@vcAdditionalRequirements, @vcRecruiterName, @vcEmailToSendApps, @IsMatchedLeadsAccept, @vcMatchedLeadsEmail, 
				@inMatchedLeadsEmailFormat, @IsMatchedLeadAutoRespond, @IsDirectLeadsAccept, @vcDirectLeadEmail, 
				@inDirectLeadEmailFormat, @IsDirectLeadAutoRespond, GETDATE(),@inUserId,GETDATE(),@inUserId)									
				
			END
			ELSE
			BEGIN
				UPDATE	CWI_ClientProfile
				SET	MinAge = @inMinAge,
				MinExperience = @inMinExperience,
				IsOTRExperience = @IsOTRExperience,
				OTRYears = @inOTRYears,
				OTRMonths = @inOTRMonths,
				IsLocalExperience = @IsLocalExperience,
				IsFelonies = @IsFelonies,
				IsFelonyBackground = @IsFelonyBackground,
				FelonyYears = @inFelonyYears,
				FelonyMonths = @inFelonyMonths,
				IsDUI = @IsDUI,
				IsFormerDUI = @IsFormerDUI,
				DUIYears = @inDUIYears,
				DUIMonths = @inDUIMonths,
				IsDWIViolations = @IsDWIViolation,
				LicenseClassTypeId = @inLicenseClassTypeId,
				IsSuspendedLicense = @IsSuspendedLicense,
				RecklessDriving = @vcRecklessDriving,
				MovingViolations = @vcMovingViolations,
				NoofMovingViolationsLastYear = @inNoofMovingViolationsLastYear,
				NoofMovingViolationsLast5Years = @inNoofMovingViolationsLast5Years,
				NoofAccidentsLastYear = @inNoofAccidentsLastYear,
				NoofAccidentsLast3Years = @inNoofAccidentsLast3Years,
				MaxNoofAccidentsLastYear = @inMaxNoofAccidentsLastYear, 
				MaxNoofAccidentsLast5Years = @inMaxNoofAccidentsLast5Years, 
				PreventableAccidents = @vcPreventableAccidents, 
				IsEndorsementsRequired = @IsEndorsementsRequired, 
				IsTakeTruckHome = @IsTakeTruckHome, 
				NoOfTicketsInLast5Years = @inNoOfTicketsInLast5Years, 
				IsDrugFailureAccepted = @IsDrugFailureAccepted, 
				AdditionalRequirements = @vcAdditionalRequirements, 
				RecruiterName = @vcRecruiterName, 
				EmailToSendApps = @vcEmailToSendApps, 
				IsMatchedLeadsAccept = @IsMatchedLeadsAccept, 
				MatchedLeadsEmail = @vcMatchedLeadsEmail, 
				MatchedLeadsEmailFormat = @inMatchedLeadsEmailFormat, 
				IsMatchedLeadAutoRespond = @IsMatchedLeadAutoRespond, 
				IsDirectLeadsAccept = @IsDirectLeadsAccept, 
				DirectLeadEmail = @vcDirectLeadEmail, 
				DirectLeadEmailFormat = @inDirectLeadEmailFormat, 
				IsDirectLeadAutoRespond = @IsDirectLeadAutoRespond,
				[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
				WHERE [ClientID]=@inClientId
			END																
			
			
					
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)		
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
GO
