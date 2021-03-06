
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileBenefitSetting]    Script Date: 4/25/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileBenefitSetting')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileBenefitSetting]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileBenefitSetting]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileBenefit 
* Purpose : This PROC would be called to retrieve the profile benefit settings details for a specific client/division
* Invoked from : Profile_BenefitSetting.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileBenefitSetting 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileBenefitSetting]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		
		SELECT [ID] as [ProfileID],ISNULL([RecruitingEmailAddress],'') AS RecruitingEmailAddress,
		ISNULL([PhoneNumber],'') AS PhoneNumber,ISNULL([Extension],'') AS Extension,
		ISNULL([EmailToSendMail],'') AS EmailToSendMail,ISNULL([CompanyWebsiteURL1],'') AS CompanyWebsiteURL1,
		ISNULL([CompanyWebsiteURL2],'') AS CompanyWebsiteURL2,ISNULL([ApplicationPageURL1],'') AS ApplicationPageURL1,
		ISNULL([ApplicationPageURL2],'') AS ApplicationPageURL2
		FROM [dbo].[CWI_ClientProfile]
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
