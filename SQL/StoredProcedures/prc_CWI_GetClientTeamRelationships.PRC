/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientTeamRelationships]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientTeamRelationships' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientTeamRelationships]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientTeamRelationships]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientTeamRelationships 
* Purpose : This PROC would be called TO get all the team relationship details associated with a client
* Invoked from : Client_TeamRelationships.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientTeamRelationships 14189,2001,16
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientTeamRelationships]   
@inClientId int,
@inEntityLookuId int,
@inUserId int  
AS
BEGIN
	BEGIN TRY
		SELECT TR.[Id] as ClientTeamRelationshipId,[ClientId],[EntityLookupId],[UserId],
		U.Names as UserName,L.LookupName,
		[RelationshipCreatedDate],[RelationshipActivateDate],[RelationshipInActivateDate]
		FROM [dbo].[CWI_ClientTeamRelationship] as TR
		INNER JOIN [dbo].[CWI_User] as U ON TR.UserId=U.Id
		INNER JOIN [dbo].[Lookup] as L ON TR.EntityLookupId=L.Id
		WHERE [ClientId]=@inClientId AND [EntityLookupId]=@inEntityLookuId AND [UserId]=@inUserId
		--AND TR.RelationshipInActivateDate IS NULL
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO
