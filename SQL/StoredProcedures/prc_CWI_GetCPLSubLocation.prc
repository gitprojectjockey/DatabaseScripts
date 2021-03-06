/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLSubLocation]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCPLSubLocation')
DROP PROCEDURE [dbo].[prc_CWI_GetCPLSubLocation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLSubLocation]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_CPL_GetStateListByCountryID
* Purpose : This PROC would be called TO fetch List of States from State table based on CountryID passed
* Invoked from : Profile_HiringLocations.ascx  
* CREATED: Vijesh Mahi
* CREATED ON : 12-July-2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetCPLSubLocation 3
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLSubLocation]    
    @inLocationID int 
AS
BEGIN
	
	BEGIN TRY
		
			Select ID as SubLocationID,[SubLocation] as SubLocationName
			From [dbo].[CWI_CPL_SubLocation]
			where [LocationID] = @inLocationID
			and IsActive=1

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	


GO
