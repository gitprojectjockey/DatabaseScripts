/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfilePayExperience]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfilePayExperience')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfilePayExperience]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfilePayExperience]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfilePayExperience 
* Purpose : This PROC would be called to retrieve the profile starting pay experience details for a specific client/division
* Invoked from : Profile_PayInformation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfilePayExperience 14175
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfilePayExperience]       
@inClientId int=NULL
AS
BEGIN

	BEGIN TRY
		IF EXISTS(SELECT [ClientID] FROM [dbo].[CWI_ClientProfilePayExperience] WHERE [ClientID]=@inClientId)
		BEGIN
			SELECT T.ID AS ExperienceID,T.[Experience],ISNULL([StartingPay],0.00) AS StartingPay
			FROM [dbo].[CWI_CPL_PayExperience] AS T
			LEFT OUTER JOIN [dbo].[CWI_ClientProfilePayExperience] AS P ON T.ID=P.PayExperienceID
			AND P.ClientID=@inClientId
			WHERE T.IsActive=1 
		END
		ELSE
		BEGIN
			SELECT ID AS ExperienceID,[Experience],0 AS StartingPay
			FROM [dbo].[CWI_CPL_PayExperience]
			WHERE IsActive=1
		END	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
