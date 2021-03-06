/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileHiringLocationDetails]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfileHiringLocationDetails')
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileHiringLocationDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileHiringLocationDetails]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileHiringLocationDetails 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile hiring location owner operator solo/team details
* Invoked from : Profile_HiringLocations.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileHiringLocationDetails 14174,
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileHiringLocationDetails]	
	@inClientId int,
	@inHiringPositionID int,
	@IsFuelCardProvided bit=NULL,
	@inFuelSurcharge int=NULL,
	@inTractorMaxAge int=NULL, 
	@IsMedicalInsurance bit=NULL, 
	@inMileagePay int=NULL, 
	@IsPaidPermits bit=NULL, 
	@IsPaidSatelliteCommunication bit=NULL, 
	@inPerDiem int=NULL, 
	@inPercentagePay int=NULL, 
	@inStartingPay int=NULL, 
	@IsTruckInsurance bit=NULL,
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN
BEGIN TRY		
		DECLARE @inProfilePositionID INT
		
		SET @inProfilePositionID = (SELECT [ID] FROM [dbo].[CWI_ClientProfileHiringPosition]  WHERE ClientID=@inClientId AND [HiringPositionID]=@inHiringPositionID)		
		
		IF NOT EXISTS (SELECT [ProfilePositionID] FROM [dbo].[CWI_ClientProfileHiringPositionDetail] WHERE [ProfilePositionID]=@inProfilePositionID)
		BEGIN
			INSERT CWI_ClientProfileHiringPositionDetail(ProfilePositionID, IsFuelCardProvided, FuelSurcharge, 
			TractorMaxAge, IsMedicalInsurance, MileagePay, IsPaidPermits, IsPaidSatelliteCommunication, 
			PerDiem, PercentagePay, StartingPay, IsTruckInsurance, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
			VALUES (@inProfilePositionID, @IsFuelCardProvided, @inFuelSurcharge, @inTractorMaxAge, 
			@IsMedicalInsurance, @inMileagePay, @IsPaidPermits, @IsPaidSatelliteCommunication, @inPerDiem, 
			@inPercentagePay, @inStartingPay, @IsTruckInsurance, @inUserId, GETDATE(), @inUserId, GETDATE())
		END
		ELSE
		BEGIN
			UPDATE	CWI_ClientProfileHiringPositionDetail
			SET	IsFuelCardProvided = @IsFuelCardProvided,
				FuelSurcharge = @inFuelSurcharge,
				TractorMaxAge = @inTractorMaxAge,
				IsMedicalInsurance = @IsMedicalInsurance,
				MileagePay = @inMileagePay,
				IsPaidPermits = @IsPaidPermits,
				IsPaidSatelliteCommunication = @IsPaidSatelliteCommunication,
				PerDiem = @inPerDiem,
				PercentagePay = @inPercentagePay,
				StartingPay = @inStartingPay,
				IsTruckInsurance = @IsTruckInsurance,				
				ModifiedBy = @inUserId,
				ModifiedOn = GETDATE()
			WHERE [ProfilePositionID] = @inProfilePositionID
		END
			
		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)		
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	
GO
