/****** Object:  StoredProcedure [dbo].[prc_CWI_GetStateListByCountryID]    Script Date: 7/2/2013 5:29:27 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetStateListByCountryID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetStateListByCountryID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetStateListByCountryID]    Script Date: 7/2/2013 5:29:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetStateListByCountryID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCountryList
* Purpose : This PROC would be called TO fetch List of States from State table based on CountryID passed
* Invoked from : Client_General.ascx  Client General Tab)
* CREATED: Ajay Thacker
* CREATED ON : 4Mar2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetStateListByCountryID]    
    @inCountryID int = 0
AS
BEGIN
	
	BEGIN TRY
		IF @inCountryID <> 0 
		BEGIN
			Select ID as StateID,
					StateCode,
					StateName,
					TimeZone
			From dbo.[State]
			where CountryID = @inCountryID
		END
		ELSE
		BEGIN
			Select ID as StateID,
					StateCode,
					StateName,
					TimeZone
			From dbo.[State]
			
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
