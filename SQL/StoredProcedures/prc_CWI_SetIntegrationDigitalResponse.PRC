/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationDigitalResponse]    Script Date: 8/26/2014 10:18:30 AM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetIntegrationDigitalResponse' )
 DROP PROCEDURE [dbo].[prc_CWI_SetIntegrationDigitalResponse]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationDigitalResponse]    Script Date: 8/26/2014 10:18:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************************************************************************************  
* PROCEDURE: prc_CWI_SetIntegrationDigitalResponse 
* Purpose : This PROC would be called to insert/update a row into [CWI_Integration_DigitalResponse] table
* Invoked from : <TBD>
* CREATED: Lino Garcia
* MODIFICATION HISTORY  
* DATE            AUTHOR          DESCRIPTION              
  08/18/2014
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_SetIntegrationDigitalResponse 'ACS','2014-06-01 - 2014-06-30','ACS - Agency Performance Report',
	'Motor Carrier Service',106828,234,0.002190437,1.603419,375.2,187,2.006417,1
********************************************************************************************************************************************/ 
  
ALTER PROCEDURE [dbo].[prc_CWI_SetIntegrationDigitalResponse]
	@Agency VARCHAR(50),
	@DateRange VARCHAR(50),
	@ReportName VARCHAR(150),
	@AccountName VARCHAR(255),
	@Impr INT = NULL,
	@Clicks INT = NULL,
	@CTR DECIMAL(18,10) = NULL,
	@AverageCPC DECIMAL(18,10) = NULL,
	@Cost DECIMAL(18,10) = NULL,
	@TotalLeads INT = NULL,
	@CPL DECIMAL(18,10) = NULL,
	@UserID INT = NULL
AS
BEGIN

	BEGIN TRY
		DECLARE @Counter INT
		SELECT @Counter = 0
		SELECT @Counter = COUNT(1) 
		FROM [dbo].[CWI_Integration_DigitalResponse]
		WHERE Agency = @Agency
		AND DateRange = @DateRange
		AND ReportName = @ReportName
		AND AccountName = @AccountName

		IF (@Counter = 0)
		BEGIN
			INSERT INTO [dbo].[CWI_Integration_DigitalResponse]
				([Agency]
				,[DateRange]
				,[ReportName]
				,[AccountName]
				,[Impr]
				,[Clicks]
				,[CTR]
				,[AverageCPC]
				,[Cost]
				,[TotalLeads]
				,[CPL]
				,[CreatedBy]
				,[CreatedOn])
			VALUES
				(@Agency
				,@DateRange
				,@ReportName
				,@AccountName
				,@Impr
				,@Clicks
				,@CTR
				,@AverageCPC
				,@Cost
				,@TotalLeads
				,@CPL
				,@UserID
				,GETDATE())
		END
		ELSE
		BEGIN
			UPDATE [dbo].[CWI_Integration_DigitalResponse]
				SET
					[Impr] = @Impr,
					[Clicks] = @Clicks,
					[CTR] = @CTR,
					[AverageCPC] = @AverageCPC,
					[Cost] = @Cost,
					[TotalLeads] = @TotalLeads,
					[CPL] = @CPL,
					[ModifiedBy] = @UserID,
					[ModifiedOn] = GETDATE()
				WHERE
					[Agency] = @Agency
					AND [DateRange] = @DateRange
					AND [ReportName] = @ReportName
					AND [AccountName] = @AccountName
		END
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
