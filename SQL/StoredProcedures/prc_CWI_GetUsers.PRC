

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUsers]    Script Date: 4/25/2013 2:42:35 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetUsers')
DROP PROCEDURE [dbo].[prc_CWI_GetUsers]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUsers]    Script Date: 4/25/2013 2:42:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*******************************************************************  
* PROCEDURE: prc_CWI_GetUsers 
* Purpose : This PROC would be called TO get all the Client Wise Users
* Invoked from : Client_TeamRelationship.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetUsers
**********************************************************************/ 
CREATE PROCEDURE prc_CWI_GetUsers
	
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		SELECT ID as UserID,Names as UserName, IsActive  from [CWI_User] 
		WHERE [Login] <> 'system' AND IsActive=1
		order by Names
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH 
END



GO

