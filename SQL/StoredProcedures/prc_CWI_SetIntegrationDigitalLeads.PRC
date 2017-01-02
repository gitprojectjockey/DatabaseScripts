/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationDigitalLeads]    Script Date: 8/26/2014 10:19:26 AM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetIntegrationDigitalLeads' )
 DROP PROCEDURE [dbo].[prc_CWI_SetIntegrationDigitalLeads]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationDigitalLeads]    Script Date: 8/26/2014 10:19:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*******************************************************************************************************************************************  
* PROCEDURE: prc_CWI_SetIntegrationDigitalLeads
* Purpose : This PROC would be called to insert/update a row into [CWI_Integration_DigitalLeads] table
* Invoked from : <TBD>
* CREATED: Lino Garcia
* MODIFICATION HISTORY  
* DATE            AUTHOR          DESCRIPTION              
  08/20/2014
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_SetIntegrationDigitalLeads 'ACS','2014-06-01 - 2014-06-30','ACS - Agency Performance Report',
	'Motor Carrier Service',0,0,0,0,0,1
********************************************************************************************************************************************/ 
  
ALTER PROCEDURE [dbo].[prc_CWI_SetIntegrationDigitalLeads]
	@Agency VARCHAR(50),
	@DateRange VARCHAR(50),
	@ReportName VARCHAR(150),
	@AccountName VARCHAR(255),
	@ApplyNowLeads INT = NULL,
	@FormLeads INT = NULL,
	@VRPreQualifiedLeads INT = NULL,
	@VRNotQualifiedLeads INT = NULL,
	@CallCount INT = NULL,
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
			INSERT INTO [dbo].[CWI_Integration_DigitalLeads]
				([Agency]
				,[DateRange]
				,[ReportName]
				,[AccountName]
				,[ApplyNowLeads]
				,[FormLeads]
				,[VRPreQualifiedLeads]
				,[VRNotQualifiedLeads]
				,[CallCount]
				,[CreatedBy]
				,[CreatedOn])
			VALUES
				(@Agency
				,@DateRange
				,@ReportName
				,@AccountName
				,@ApplyNowLeads
				,@FormLeads
				,@VRPreQualifiedLeads
				,@VRNotQualifiedLeads
				,@CallCount
				,@UserID
				,GETDATE())
		END
		ELSE
		BEGIN
			UPDATE [dbo].[CWI_Integration_DigitalLeads]
				SET
					[ApplyNowLeads] = @ApplyNowLeads,
					[FormLeads] = @FormLeads,
					[VRPreQualifiedLeads] = @VRPreQualifiedLeads,
					[VRNotQualifiedLeads] = @VRNotQualifiedLeads,
					[CallCount] = @CallCount, 
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

