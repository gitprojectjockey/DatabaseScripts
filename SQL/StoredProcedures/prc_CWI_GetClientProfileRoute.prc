/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileRoute]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileRoute')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileRoute]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileRoute]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileRoute 
* Purpose : This PROC would be called to retrieve the profile route offered details for a specific client/division
* Invoked from : Profile_JobOverview.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileRoute 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileRoute]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		
		SELECT P.[ID] as ProfileID,[RouteID],R.RouteName
		FROM [dbo].[CWI_ClientProfileRoute] AS P
		INNER JOIN [dbo].[CWI_CPL_Route] AS R ON R.ID=P.RouteID
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
