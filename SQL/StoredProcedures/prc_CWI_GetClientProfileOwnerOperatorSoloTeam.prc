/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileOwnerOperatorSoloTeam]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileOwnerOperatorSoloTeam')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileOwnerOperatorSoloTeam]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileOwnerOperatorSoloTeam]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileOwnerOperatorSoloTeam] 
* Purpose : This PROC would be called to retrieve the owner operator solo/team details
* Invoked from : Profile_JobOverview.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileOwnerOperatorSoloTeam 14175
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileOwnerOperatorSoloTeam]       
@inClientId int,
@inHiringPositionID int
AS
BEGIN

	BEGIN TRY
	
	DECLARE @inProfilePositionID INT
		
	SET @inProfilePositionID = (SELECT [ID] FROM [dbo].[CWI_ClientProfileHiringPosition]  WHERE ClientID=@inClientId AND [HiringPositionID]=@inHiringPositionID)		
		
		SELECT	ID as OwnerOperatorID,			
			ISNULL(IsFuelCardProvided,'') AS IsFuelCardProvided,
			ISNULL(FuelSurcharge,0) AS FuelSurcharge,
			ISNULL(TractorMaxAge,0) AS TractorMaxAge,
			ISNULL(IsMedicalInsurance,'') AS IsMedicalInsurance,
			ISNULL(MileagePay,0) AS MileagePay,
			ISNULL(IsPaidPermits,'') AS IsPaidPermits,
			ISNULL(IsPaidSatelliteCommunication,'') AS IsPaidSatelliteCommunication,
			ISNULL(PerDiem,0) AS PerDiem,
			ISNULL(PercentagePay,0) AS PercentagePay,
			ISNULL(StartingPay,0) AS StartingPay,
			ISNULL(IsTruckInsurance,'') AS IsTruckInsurance	
		FROM	CWI_ClientProfileHiringPositionDetail
		WHERE 	ProfilePositionID = @inProfilePositionID

			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
