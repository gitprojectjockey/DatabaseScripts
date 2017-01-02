

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCompanyConfigAddress]    Script Date: 6/28/2013 7:06:55 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCompanyConfigAddress')
DROP PROCEDURE [dbo].[prc_CWI_GetCompanyConfigAddress]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCompanyConfigAddress]    Script Date: 6/28/2013 7:06:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_GetCompanyConfigAddress 
* Purpose : This PROC would be called TO retrieve address details of ACS Advertising
* Invoked from : Client_TearSheet.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_GetCompanyConfigAddress 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCompanyConfigAddress]   
AS
BEGIN
	BEGIN TRY
		SELECT AddressLine1,ISNULL(AddressLine2,'') AS AddressLine2,CountryID,StateID,
		City,Zip,ISNULL(WorkPhone,'') AS WorkPhone,ISNULL(WorkFax,'') AS WorkFax,ISNULL(WorkExtn,'') as WorkExtn
		FROM [dbo].[CompanyConfig]
		WHERE Id=1
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO

