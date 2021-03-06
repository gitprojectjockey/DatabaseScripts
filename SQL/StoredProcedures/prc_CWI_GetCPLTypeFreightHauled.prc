/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLTypeFreightHauled]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCPLTypeFreightHauled')
DROP PROCEDURE [dbo].[prc_CWI_GetCPLTypeFreightHauled]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLTypeFreightHauled]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_CPL_GetTypeFreightHauled  
* Purpose : This PROC would be called to bind the type of freight hauled dropdownlist
* Invoked from : Profile_CompanyDetails.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_GetCPLTypeFreightHauled] 
**********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLTypeFreightHauled]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT [ID],[TypeOfFreightHauled] FROM [dbo].[CWI_CPL_TypeFreightHauled]
	WHERE IsActive=1
END

GO
