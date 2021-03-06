/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientAddress]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientAddress' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientAddress]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientAddress]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientAddress 
* Purpose : This PROC would be called TO retrieve address details for the specific client
* Invoked from : Client_TearSheet.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_GetClientAddress 59
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientAddress]   
@inClientId int
AS
BEGIN
	BEGIN TRY
		SELECT AD.AddressLine1,ISNULL(AD.AddressLine2,'') as AddressLine2,AD.CountryID,AD.StateID,
		AD.City,AD.Zip,
		dbo.fnc_FormatRemovalPhone(AD.WorkPhone,default) as WorkPhone,
		dbo.fnc_FormatRemovalPhone(AD.WorkFax,default) as WorkFax, 
		ISNULL(AD.WorkExtn,'') as WorkExtn
		FROM [dbo].[CWI_Client] AS C 
		INNER JOIN [dbo].[CWI_Address] AS AD ON C.AddressID=AD.ID
		WHERE C.ID=@inClientId
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	GO


