/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLHiringPosition]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCPLHiringPosition')
DROP PROCEDURE [dbo].[prc_CWI_GetCPLHiringPosition]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLHiringPosition]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_CPL_GetHiringPositions  
* Purpose : This PROC would be called to bind the hiring positions dropdownlist
* Invoked from : Profile_JobOverview.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_GetCPLHiringPosition] 
**********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLHiringPosition]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT [ID],[HiringPosition] FROM [dbo].[CWI_CPL_HiringPosition]
	WHERE IsActive=1
END

GO
