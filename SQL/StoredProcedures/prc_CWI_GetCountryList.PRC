/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCountryList]    Script Date: 7/2/2013 5:29:27 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCountryList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCountryList]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCountryList]    Script Date: 7/2/2013 5:29:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCountryList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCountryList
* Purpose : This PROC would be called TO fetch List of Countries from Country table 
* Invoked from : Client_General.ascx  Client General Tab)
* CREATED: Ajay Thacker
* CREATED ON : 4Mar2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCountryList]    
    
AS
BEGIN
	
	BEGIN TRY
		Select ID as CountryID,
				CountryCode,
				CountryName
		From Country

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	' 
END
GO
