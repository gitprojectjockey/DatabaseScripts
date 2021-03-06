/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLRoute]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCPLRoute')
DROP PROCEDURE [dbo].[prc_CWI_GetCPLRoute]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLRoute]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_CPL_GetRoutesOffered  
* Purpose : This PROC would be called to bind the type/routes offered dropdownlist
* Invoked from : Profile_JobOverview.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_GetCPLRoute] 
**********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLRoute]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT [ID],[RouteName] FROM [dbo].[CWI_CPL_Route]
	WHERE IsActive=1
	
END

GO
