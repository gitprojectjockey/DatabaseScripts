/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileCompanyDetails]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfileCompanyDetails')
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileCompanyDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileCompanyDetails]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileCompanyDetails 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile company details
* Invoked from : Profile_CompanyDetails.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileCompanyDetails NULL,1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileCompanyDetails]
	@inClientId int,
	@vcDOTMCNumber varchar(50)=NULL,
	@vcWebsiteURL varchar(100)=NULL,
	@vcCompanyOwnership varchar(100)=NULL,
	@inYearCompanyStarted int=NULL,
	@inNoOfEmployees int=NULL,
	@inNoOfCompanyTrucks int=NULL,
	@inNoOfTrucksInFleet int=NULL,
	@inNoOfOwnerOperators int=NULL,
	@inNoOfTerminals int=NULL,
	@vcOperatingArea varchar(max)=NULL, 
	@vcIndustry varchar(255)=NULL,
	@inCompanyRevenue decimal(18,2)=NULL,
	@inEquipmentAge decimal(18,2)=NULL,
	@vcSpeedRestriction varchar(255)=NULL,
	@vcEquipmentBrands varchar(max)=NULL, 
	@vcTypeFreightHauled varchar(max)=NULL,
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY		
			IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfile] WHERE ClientID=@inClientId)
			BEGIN
				INSERT INTO [dbo].[CWI_ClientProfile]
				([ClientID],[DOTMCNumber],[WebsiteURL],[CompanyOwnership],[YearCompanyStarted],
				[NoOfEmployees],[NoOfCompanyTrucks],[NoOfTrucksInFleet],[NoOfOwnerOperators],[NoOfTerminals],
				[OperatingArea],[Industry],[CompanyRevenue],[EquipmentAge],[SpeedRestriction],[EquipmentBrands],
				[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				VALUES
				(@inClientId,@vcDOTMCNumber,@vcWebsiteURL,@vcCompanyOwnership,@inYearCompanyStarted,@inNoOfEmployees,
				@inNoOfCompanyTrucks,@inNoOfTrucksInFleet,@inNoOfOwnerOperators,@inNoOfTerminals,@vcOperatingArea,
				@vcIndustry,@inCompanyRevenue,@inEquipmentAge,@vcSpeedRestriction,@vcEquipmentBrands,
				GETDATE(),@inUserId,GETDATE(),@inUserId)
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
			END
			ELSE
			BEGIN
				UPDATE [dbo].[CWI_ClientProfile]
				SET [DOTMCNumber]=@vcDOTMCNumber,[WebsiteURL]=@vcWebsiteURL,
					[CompanyOwnership]=@vcCompanyOwnership,[YearCompanyStarted]=@inYearCompanyStarted,
					[NoOfEmployees]=@inNoOfEmployees,[NoOfCompanyTrucks]=@inNoOfCompanyTrucks,[NoOfTrucksInFleet]=@inNoOfTrucksInFleet,
					[NoOfOwnerOperators]=@inNoOfOwnerOperators,[NoOfTerminals]=@inNoOfTerminals,
					[OperatingArea]=@vcOperatingArea,[Industry]=@vcIndustry,[CompanyRevenue]=@inCompanyRevenue,
					[EquipmentAge]=@inEquipmentAge,[SpeedRestriction]=@vcSpeedRestriction,[EquipmentBrands]=@vcEquipmentBrands,
					[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
				WHERE [ClientID]=@inClientId
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
			END

			IF @vcTypeFreightHauled IS NOT NULL
			BEGIN
				IF EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfileTypeFreightHauled] WHERE ClientID=@inClientId)
				BEGIN	
					DELETE FROM [dbo].[CWI_ClientProfileTypeFreightHauled] WHERE [ClientID]=@inClientId	
				END							
				INSERT INTO [dbo].[CWI_ClientProfileTypeFreightHauled]
				([ClientID],[FreightHauledID],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])					
				SELECT @inClientId,Items,
				GETDATE(),@inUserId,GETDATE(),@inUserId  FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcTypeFreightHauled,',')	
				
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)			
			END	
			ELSE
			BEGIN
				IF EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfileTypeFreightHauled] WHERE ClientID=@inClientId)
				BEGIN	
					DELETE FROM [dbo].[CWI_ClientProfileTypeFreightHauled] WHERE [ClientID]=@inClientId	
					SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
				END				
			END
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
GO
