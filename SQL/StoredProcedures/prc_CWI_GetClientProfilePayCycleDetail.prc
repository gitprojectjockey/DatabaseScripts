/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfilePayCycleDetail]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfilePayCycleDetail')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfilePayCycleDetail]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfilePayCycleDetail]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfilePayCycleDetail] 
* Purpose : This PROC would be called to retrieve the owner operator solo/team details
* Invoked from : Profile_PayInformation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfilePayCycleDetail 14175
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfilePayCycleDetail]       
@inClientId int,
@inPayInformationID int
AS
BEGIN

	BEGIN TRY
	
		DECLARE @inUnloadPayID INT
		
		SET @inUnloadPayID = (SELECT [ID] FROM [dbo].[CWI_ClientProfileDriverPayDetail] WHERE [PayInformationID]=@inPayInformationID)		
		
		SELECT	P.ID as PayCycleDetailID,[PayCycleID],C.PayCycle			
		FROM	[dbo].[CWI_ClientProfilePayCycleDetails] AS P
		INNER JOIN [dbo].[CWI_CPL_PayCycle] AS C ON C.ID=P.PayCycleID
		WHERE 	[UnloadPayID]=@inUnloadPayID
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
