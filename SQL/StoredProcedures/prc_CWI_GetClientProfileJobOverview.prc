

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileJobOverview]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfileJobOverview')
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileJobOverview]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileJobOverview]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileJobOverview 
* Purpose : This PROC would be called to retrieve the profile job overview for a specific client/division
* Invoked from : Profile_JobOverview.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileJobOverview 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileJobOverview]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		
		SELECT [ID] as ProfileID,[JobOverview]
		FROM [dbo].[CWI_ClientProfile]
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	
GO
