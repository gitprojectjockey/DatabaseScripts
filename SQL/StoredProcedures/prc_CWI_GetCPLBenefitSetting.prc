/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLBenefitSetting]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCPLBenefitSetting')
DROP PROCEDURE [dbo].[prc_CWI_GetCPLBenefitSetting]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLBenefitSetting]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_CPL_GetBenefitsSettings
* Purpose : This PROC would be called TO benefit settings checkboxlist
* Invoked from : Profile_BenefitSettings.ascx  
* CREATED: Vijesh Mahi
* CREATED ON : 12-July-2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetCPLBenefitSetting
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLBenefitSetting]    
   
AS
BEGIN
	
	BEGIN TRY
		
			Select ID,[Benefit]
			From [dbo].[CWI_CPL_Benefit]
			where IsActive=1

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	


GO
