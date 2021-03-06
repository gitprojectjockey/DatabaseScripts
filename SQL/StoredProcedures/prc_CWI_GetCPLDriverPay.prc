/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLDriverPay]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCPLDriverPay')
DROP PROCEDURE [dbo].[prc_CWI_GetCPLDriverPay]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLDriverPay]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_CPL_GetCompanyDriverPay
* Purpose : This PROC would be called TO fetch driver pay information
* Invoked from : Profile_PayInformation.ascx  
* CREATED: Vijesh Mahi
* CREATED ON : 12-July-2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetCPLDriverPay 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLDriverPay]    
   
AS
BEGIN
	
	BEGIN TRY
		
			Select ID,[DriverPay]
			From [dbo].[CWI_CPL_DriverPay]
			where IsActive=1

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	


GO
