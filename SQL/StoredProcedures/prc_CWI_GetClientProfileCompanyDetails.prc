
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileCompanyDetails]    Script Date: 4/25/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileCompanyDetails')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileCompanyDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileCompanyDetails]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileCompanyDetails 
* Purpose : This PROC would be called to retrieve the profile company details for a specific client/division
* Invoked from : Profile_CompanyDetails.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileCompanyDetails 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileCompanyDetails]       
@inClientId int
AS
BEGIN

	BEGIN TRY

		SELECT [ID] as ProfileID, [DOTMCNumber],[WebsiteURL],[CompanyOwnership],ISNULL([YearCompanyStarted],'') AS [YearCompanyStarted],
		ISNULL([NoOfEmployees],'') AS [NoOfEmployees],ISNULL([NoOfCompanyTrucks],'') AS [NoOfCompanyTrucks],
		ISNULL([NoOfTrucksInFleet],'') AS [NoOfTrucksInFleet],ISNULL([NoOfOwnerOperators],'') AS [NoOfOwnerOperators],
		ISNULL([NoOfTerminals],'') AS [NoOfTerminals],[OperatingArea],[Industry],
		ISNULL([CompanyRevenue],'0.00') AS [CompanyRevenue],ISNULL([EquipmentAge],'0.00') AS [EquipmentAge],
		[SpeedRestriction],[EquipmentBrands]
		FROM [dbo].[CWI_ClientProfile]
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO
