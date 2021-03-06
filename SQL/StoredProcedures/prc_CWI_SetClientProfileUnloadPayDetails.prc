/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileUnloadPayDetails]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfileUnloadPayDetails')
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileUnloadPayDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileUnloadPayDetails]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileUnloadPayDetails 
* Purpose : This PROC would be called TO INSERT OR UPDATE the pay information details of Unload Pay
* Invoked from : Profile_PayInformation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileUnloadPayDetails 14174,
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileUnloadPayDetails]	
	@inClientId int,
	@inDriverPayID int,
	@decAvgWeeklyPay decimal(18,2)=NULL,
	@decAvgMonthlyPay decimal(18,2)=NULL,
	@decAvgAnnualPay decimal(18,2)=NULL,
	@inPayPercentage int=NULL, 
	@vcPayCycle varchar(MAX)=NULL, 
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN
BEGIN TRY		
		DECLARE @inPayInformationID INT,@inUnloadPayID INT
		
		SET @inPayInformationID = (SELECT [ID] FROM [dbo].[CWI_ClientProfilePayInformation] WHERE ClientID=@inClientId AND [DriverPayID]=@inDriverPayID)		
		
		IF NOT EXISTS (SELECT [PayInformationID] FROM [dbo].[CWI_ClientProfileDriverPayDetail] WHERE [PayInformationID]=@inPayInformationID)
		BEGIN
			INSERT INTO [CWI_ClientProfileDriverPayDetail] 
			([PayInformationID],[AverageWeeklyPay],[AverageMonthlyPay],[AverageAnnualPay],[PayLoadPercentage], CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
			VALUES (@inPayInformationID, @decAvgWeeklyPay, @decAvgMonthlyPay, @decAvgAnnualPay, @inPayPercentage,
			@inUserId, GETDATE(), @inUserId, GETDATE())
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
		END
		ELSE
		BEGIN
			UPDATE	[CWI_ClientProfileDriverPayDetail]
			SET [AverageWeeklyPay]=@decAvgWeeklyPay,[AverageMonthlyPay]=@decAvgMonthlyPay,
				[AverageAnnualPay]=@decAvgAnnualPay,[PayLoadPercentage]=@inPayPercentage,
				ModifiedBy = @inUserId,ModifiedOn = GETDATE()
			WHERE [PayInformationID]=@inPayInformationID
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
		END
		IF @vcPayCycle IS NOT NULL
		BEGIN
			SET @inUnloadPayID	 = (SELECT ID FROM [dbo].[CWI_ClientProfileDriverPayDetail] WHERE PayInformationID=@inPayInformationID)
			IF EXISTS(SELECT [UnloadPayID] FROM [dbo].[CWI_ClientProfilePayCycleDetails] WHERE [UnloadPayID]=@inUnloadPayID)
			BEGIN				
				DELETE FROM [dbo].[CWI_ClientProfilePayCycleDetails] WHERE [UnloadPayID]=@inUnloadPayID
			END				
			INSERT INTO [dbo].[CWI_ClientProfilePayCycleDetails]
			([UnloadPayID],[PayCycleID],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])					
			SELECT @inUnloadPayID,Items,
			GETDATE(),@inUserId,GETDATE(),@inUserId  FROM  dbo.fnc_SplitCSVIntoTableUsingCTE(@vcPayCycle,',')
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)		
		END						
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	
GO
