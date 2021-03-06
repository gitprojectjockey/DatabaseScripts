/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileTypeFreightHauled]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileTypeFreightHauled')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileTypeFreightHauled]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileTypeFreightHauled]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileTypeFreightHauled 
* Purpose : This PROC would be called to retrieve the type freight hauled details for a specific client/division
* Invoked from : Profile_JobOverview.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileTypeFreightHauled 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileTypeFreightHauled]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		
		SELECT P.[ID] as ProfileID,[FreightHauledID],[TypeOfFreightHauled] AS FreightHauledName
		FROM [dbo].[CWI_ClientProfileTypeFreightHauled] AS P
		INNER JOIN [dbo].[CWI_CPL_TypeFreightHauled] AS T ON T.ID=P.FreightHauledID
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
