/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileLocation]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileLocation')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileLocation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileLocation]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileLocation 
* Purpose : This PROC would be called to retrieve the profile hiring location details for a specific client/division
* Invoked from : Profile_HiringLocations.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileLocation 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileLocation]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		
		SELECT H.[ID] as ProfileID,[SubLocationID] AS StateID,S.LocationID AS CountryID,S.SubLocation AS LocationName
		FROM [dbo].[CWI_ClientProfileHiringLocation] AS H
		INNER JOIN [dbo].[CWI_CPL_SubLocation] AS S ON S.ID=H.SubLocationID
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
