/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLSiteTypes]    Script Date: 8/5/2014 5:25:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCPLSiteTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCPLSiteTypes]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLSiteTypes]    Script Date: 8/5/2014 5:25:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCPLSiteTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCPLSiteTypes
* Purpose : This PROC would be called TO fetch site types
* Invoked from : Profile_DigitalMedia.aspx  
* CREATED: Vijesh Mahi
* CREATED ON : 04-Aug-2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetCPLSiteTypes 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLSiteTypes]    
   
AS
BEGIN
	
	BEGIN TRY
		
			Select Id,SiteType
			From [dbo].[CWI_CPL_SiteTypes]
			where IsActive=1

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	



' 
END
GO
