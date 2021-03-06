/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLookupTypes]    Script Date: 2/19/2014 6:08:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLookupTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetLookupTypes]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLookupTypes]    Script Date: 2/19/2014 6:08:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLookupTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetLookupTypes
* Purpose : This PROC would be called TO get all the lookup types
			
* Invoked from : Multiple Pages
* CREATED: Mohankumar Sundaram
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetLookupTypes
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetLookupTypes]    
    
AS
BEGIN

	BEGIN TRY
		
		SELECT Id,[LookupTypeName] FROM [dbo].[LookupType]
		 
		ORDER BY LookupTypeName	

		RETURN
		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
' 
END
GO
