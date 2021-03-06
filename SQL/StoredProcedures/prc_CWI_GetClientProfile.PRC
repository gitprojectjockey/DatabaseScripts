/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfile]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientProfile' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientProfile]

GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfile]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfile 
* Purpose : This PROC would be called TO get the client profile details
* Invoked from : Client_Profile.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfile 50
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfile]   
@inClientId int 
AS
BEGIN
	BEGIN TRY
		SELECT [ID] as ClientId, [ClientCode], [ClientName],ISNULL([ClientProfile],'') as [ClientProfile]
		FROM [dbo].[CWI_Client]
		WHERE [ID]=@inClientId 
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO
