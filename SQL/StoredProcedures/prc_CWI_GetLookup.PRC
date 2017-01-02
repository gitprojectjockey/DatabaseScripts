

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLookup]    Script Date: 4/25/2013 2:44:14 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetLookup')
DROP PROCEDURE [dbo].[prc_CWI_GetLookup]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLookup]    Script Date: 4/25/2013 2:44:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_GetLookup 
* Purpose : This PROC would be called TO get all the lookup values based on LookupTypeId 
			For ex: For LookupTypeId 3, proc will return all Classifications (Newspaper, Magazine etc)
* Invoked from : Multiple Pages
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetLookup @inLookupTypeId = 3 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetLookup]    
    @inLookupTypeId int 
AS
BEGIN

	BEGIN TRY
		
		SELECT Id,[LookupName] FROM [dbo].[Lookup]
		WHERE [LookupTypeId]=@inLookupTypeId
		AND [IsActive]=1	
		ORDER BY SortOrder,LookupName	

		RETURN
		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO

