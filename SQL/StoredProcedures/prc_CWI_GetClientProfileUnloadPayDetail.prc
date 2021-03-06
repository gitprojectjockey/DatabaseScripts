/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileUnloadPayDetail]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileUnloadPayDetail')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileUnloadPayDetail]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileUnloadPayDetail]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileUnloadPayDetail] 
* Purpose : This PROC would be called to retrieve the owner operator solo/team details
* Invoked from : Profile_PayInformation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileUnloadPayDetail 14175
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileUnloadPayDetail]       
@inClientId int,
@inPayInformationID int
AS
BEGIN

	BEGIN TRY
	
	--DECLARE @inUnloadPayID INT
		
	--SET @inUnloadPayID = (SELECT [ID] FROM [dbo].[CWI_ClientProfileDriverPayDetail] WHERE [PayInformationID]=@inPayInformationID)		
		
	SELECT	ID as DriverPayDetailID,			
		ISNULL([AverageWeeklyPay],0) AS [AverageWeeklyPay],
		ISNULL([AverageMonthlyPay],0) AS [AverageMonthlyPay],
		ISNULL([AverageAnnualPay],0) AS [AverageAnnualPay],
		ISNULL([PayLoadPercentage],0) AS [PayLoadPercentage]
	FROM	[dbo].[CWI_ClientProfileDriverPayDetail]
	WHERE 	[PayInformationID]=@inPayInformationID

			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
