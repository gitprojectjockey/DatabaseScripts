/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileDriverPay]    Script Date: 4/25/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileDriverPay')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileDriverPay]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileDriverPay]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileDriverPay 
* Purpose : This PROC would be called to retrieve the driver pay details for a specific client/division
* Invoked from : Profile_PayInformation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileDriverPay 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileDriverPay]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		
		SELECT P.[ID] as ProfileID,[DriverPayID],D.DriverPay
		FROM [dbo].[CWI_ClientProfilePayInformation] AS P 
		INNER JOIN [dbo].[CWI_CPL_DriverPay] AS D ON D.ID=P.DriverPayID
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
