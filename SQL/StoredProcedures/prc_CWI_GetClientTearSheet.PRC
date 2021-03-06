/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientTearSheet]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientTearSheet' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientTearSheet]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientTearSheet]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientTearSheet 
* Purpose : This PROC would be called TO retrieve tear sheet details associated with a client
* Invoked from : Client_TearSheet.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_GetClientTearSheet 58
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientTearSheet]   
@inClientId int
AS
BEGIN
	BEGIN TRY
		SELECT TS.[Id] as TearSheetId,TS.[AddressId],TS.[TearName],TS.[TearContact],
		C.ClientCode,AD.AddressLine1,ISNULL(AD.AddressLine2,'') AS AddressLine2,AD.CountryID,AD.StateID,
		AD.City,AD.Zip,ISNULL(AD.WorkPhone,'') AS WorkPhone,ISNULL(AD.WorkFax,'') AS WorkFax,
		ISNULL(AD.WorkExtn,'') AS WorkExtn
		FROM [dbo].[CWI_ClientTearSheet] AS TS
		INNER JOIN [dbo].[CWI_Client] AS C ON TS.ClientId=C.ID
		INNER JOIN [dbo].[CWI_Address] AS AD ON TS.AddressId=AD.ID
		WHERE TS.ClientId=@inClientId
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
END
	
GO
