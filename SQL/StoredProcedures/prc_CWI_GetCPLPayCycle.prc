/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLPayCycle]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCPLPayCycle')
DROP PROCEDURE [dbo].[prc_CWI_GetCPLPayCycle]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLPayCycle]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCPLPayCycle  
* Purpose : This PROC would be called to bind the pay cycle/period dropdownlist
* Invoked from : Profile_PayInformation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_GetCPLPayCycle] 
**********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLPayCycle]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT [ID],[PayCycle] FROM [dbo].[CWI_CPL_PayCycle]
	WHERE IsActive=1
	
END

GO
