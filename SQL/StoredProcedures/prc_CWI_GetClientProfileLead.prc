
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileLead]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileLead')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileLead]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileLead]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileLead 
* Purpose : This PROC would be called to retrieve the lead details for a specific client/division
* Invoked from : Profile_Lead.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileLead 14174
**********************************************************************/ 
  
CREATE PROC [dbo].[prc_CWI_GetClientProfileLead]
	@inClientID int
AS
	BEGIN TRY
		SELECT	ID as ProfileID,	
		ISNULL(MinAge,0) AS MinAge,
		ISNULL(MinExperience,0) AS MinExperience,
		ISNULL(IsOTRExperience,'') AS IsOTRExperience,
		ISNULL(OTRYears,0) AS OTRYears,
		ISNULL(OTRMonths,0) AS OTRMonths,
		ISNULL(IsLocalExperience,'') AS IsLocalExperience,
		ISNULL(IsFelonies,'') AS IsFelonies,
		ISNULL(IsFelonyBackground,'') AS IsFelonyBackground,
		ISNULL(FelonyYears,0) AS FelonyYears,
		ISNULL(FelonyMonths,0) AS FelonyMonths,
		ISNULL(IsDUI,'') AS IsDUI,
		ISNULL(IsFormerDUI,'') AS IsFormerDUI,
		ISNULL(DUIYears,0) AS DUIYears,
		ISNULL(DUIMonths,0) AS DUIMonths,
		ISNULL(IsDWIViolations,'') AS IsDWIViolations,
		ISNULL(LicenseClassTypeId,0) AS LicenseClassTypeId,
		ISNULL(IsSuspendedLicense,'') AS IsSuspendedLicense,
		ISNULL(RecklessDriving,'') AS RecklessDriving,
		ISNULL(MovingViolations,'') AS MovingViolations,
		ISNULL(NoofMovingViolationsLastYear,0) AS NoofMovingViolationsLastYear,
		ISNULL(NoofMovingViolationsLast5Years,0) AS NoofMovingViolationsLast5Years,
		ISNULL(NoofAccidentsLastYear,0) AS NoofAccidentsLastYear,
		ISNULL(NoofAccidentsLast3Years,0) AS NoofAccidentsLast3Years,
		ISNULL(MaxNoofAccidentsLastYear,0) AS MaxNoofAccidentsLastYear,
		ISNULL(MaxNoofAccidentsLast5Years,0) AS MaxNoofAccidentsLast5Years,
		ISNULL(PreventableAccidents,'') AS PreventableAccidents,
		ISNULL(IsEndorsementsRequired,'') AS IsEndorsementsRequired,
		ISNULL(IsTakeTruckHome,'') AS IsTakeTruckHome,
		ISNULL(NoOfTicketsInLast5Years,0) AS NoOfTicketsInLast5Years,
		ISNULL(IsDrugFailureAccepted,'') AS IsDrugFailureAccepted,
		ISNULL(AdditionalRequirements,'') AS AdditionalRequirements,
		ISNULL(RecruiterName,'') AS RecruiterName,
		ISNULL(EmailToSendApps,'') AS EmailToSendApps,
		ISNULL(IsMatchedLeadsAccept,'') AS IsMatchedLeadsAccept,
		ISNULL(MatchedLeadsEmail,'') AS MatchedLeadsEmail,
		ISNULL(MatchedLeadsEmailFormat,0) AS MatchedLeadsEmailFormat,
		ISNULL(IsMatchedLeadAutoRespond,'') AS IsMatchedLeadAutoRespond,
		ISNULL(IsDirectLeadsAccept,'') AS IsDirectLeadsAccept,
		ISNULL(DirectLeadEmail,'') AS DirectLeadEmail,
		ISNULL(DirectLeadEmailFormat,0) AS DirectLeadEmailFormat,
		ISNULL(IsDirectLeadAutoRespond,'') AS IsDirectLeadAutoRespond,
		CreatedOn,
		CreatedBy,
		ModifiedOn,
		ModifiedBy
	FROM	[dbo].[CWI_ClientProfile]
	WHERE 	ClientID = @inClientID
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH


GO
