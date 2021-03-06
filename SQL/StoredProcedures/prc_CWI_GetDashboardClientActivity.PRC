/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardClientActivity]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetDashboardClientActivity' )
 DROP PROCEDURE [dbo].[prc_CWI_GetDashboardClientActivity]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDashboardClientActivity]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetDashboardClientActivity 
* Purpose : This PROC would be called to retrieve the client activity details for the logged in user
* Invoked from : Dashboard.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetDashboardClientActivity 7
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetDashboardClientActivity]       
@inUserId int
AS
BEGIN

	BEGIN TRY

		--SELECT C.ClientCode +'-' +C.ClientName as Client,C.ID as ClientID,
		SELECT 'EGL-Eagle Transport' as Client,14218 as ClientID,
		'Mktg Plan Jan-Dec2013' as MarketingPlan,101 as MarketingPlanId,
		 '3' as Job,1001 as JobId,'5'  as Task, 1 as TaskId
		 UNION ALL
		 SELECT 'ANH-ANNETT HOLDINGS' as Client,14174 as ClientID,
		'Marketing Plan for ANH' as MarketingPlan,102 as MarketingPlanId,
		 '4' as Job,1002 as JobId,'4'  as Task, 2 as TaskId
		 
		---FROM [dbo].CWI_Client AS C		
		--INNER JOIN CWI_ClientTeamRelationship TR ON TR.ClientId=C.ID
		--WHERE TR.UserId=@inUserId
		--Marketing Plan for MNB Orgn,,
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO
