/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientEntityUser]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientEntityUser' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientEntityUser]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientEntityUser]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientEntityUser 
* Purpose : This PROC would be called TO get all entity and user relationship from  [dbo].[CWI_ClientTeamRelationship]
			Here LookupTypeId 14 is for ClientTeamRelationship
* Invoked from : Multiple Pages
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClientEntityUser 14189
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientEntityUser]    
    @inClientId int	
AS
BEGIN

	BEGIN TRY
		DECLARE @dt datetime
		SET @dt = CAST( getdate() as date)
		SELECT 
			DISTINCT NULL AS  ParentId,Convert(varchar,L.Id) AS Id,L.LookupName AS Name 
		FROM CWI_ClientTeamRelationship AS T 
			RIGHT OUTER JOIN dbo.Lookup AS L ON L.Id=T.EntityLookupId 
			AND ( 
			(@dt between T.RelationshipActivateDate AND ISNULL(T.RelationshipInActivateDate,GETDATE()))
			OR 
			( T.RelationshipActivateDate>= @dt AND T.RelationshipInActivateDate IS NULL)

			)
		WHERE 
			[LookupTypeId]=14	AND [IsActive]=1 
			
			
		UNION ALL
		SELECT 
			Convert(varchar,EntityLookupId) AS ParentId,
			Convert(varchar,EntityLookupId)+'-'+Convert(varchar,UserId) AS Id ,u.Names AS Name 
		FROM CWI_ClientTeamRelationship AS T 
			INNER JOIN CWI_User AS U ON U.Id=T.UserId 
		WHERE 
			T.ClientId=@inClientId AND ( 
			(@dt between T.RelationshipActivateDate AND ISNULL(T.RelationshipInActivateDate,GETDATE()))
			OR 
			( T.RelationshipActivateDate>= @dt AND T.RelationshipInActivateDate IS NULL)

			)

		ORDER BY LookupName
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	

	
GO
