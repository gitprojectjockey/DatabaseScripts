/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLLicenseClassType]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCPLLicenseClassType')
DROP PROCEDURE [dbo].[prc_CWI_GetCPLLicenseClassType]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLLicenseClassType]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCPLLicenseClassType  
* Purpose : This PROC would be called to bind the type of freight hauled dropdownlist
* Invoked from : Profile_Lead.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_GetCPLLicenseClassType] 
**********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLLicenseClassType]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT [ID],[LicenseClassType] FROM [dbo].[CWI_CPL_LicenseClassType]
	WHERE IsActive=1
END

GO
