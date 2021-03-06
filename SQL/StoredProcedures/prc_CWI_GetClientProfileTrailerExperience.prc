/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileTrailerExperience]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileTrailerExperience')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileTrailerExperience]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileTrailerExperience]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileTrailerExperience] 
* Purpose : This PROC would be called to retrieve the profile trailer experience details for a specific client/division
* Invoked from : Profile_TrailerExperience.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileTrailerExperience 14175
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileTrailerExperience]       
@inClientId int=NULL
AS
BEGIN

	BEGIN TRY
		IF EXISTS(SELECT [ClientID] FROM [dbo].[CWI_ClientProfileTrailerExperience] WHERE [ClientID]=@inClientId)
		BEGIN
			SELECT T.ID AS TrailerExperienceID,T.TrailerType,ISNULL(Years,'') AS Years,ISNULL(Months,'') AS Months,
			ISNULL([IsNotRequired],'') AS IsNotRequired,ISNULL([IsNotRelevant],'') AS IsNotRelevant,[DurationOther]
			FROM [dbo].[CWI_CPL_TrailerExperience] AS T
			LEFT OUTER JOIN [dbo].[CWI_ClientProfileTrailerExperience] AS P ON T.ID=P.TrailerExperienceID
			AND P.ClientID=@inClientId
			WHERE T.IsActive=1 
		END
		ELSE
		BEGIN
			SELECT ID AS TrailerExperienceID,TrailerType,0 AS Years,0 AS Months,
			0 AS IsNotRequired,0 AS IsNotRelevant,0 AS [DurationOther]
			FROM [dbo].[CWI_CPL_TrailerExperience] 
			WHERE IsActive=1
		END	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
