/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTeamClientReleationships]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetTeamClientReleationships' )
 DROP PROCEDURE [dbo].[prc_CWI_GetTeamClientReleationships]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTeamClientReleationships]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetTeamClientReleationships  
* Purpose : This PROC would be called TO get all the relationships of the user and entity
* Invoked from : TeamClientRelationship.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTeamClientReleationships @UserId = 3, @EntityLookupId = 2001
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetTeamClientReleationships]
	@UserId int,
	@EntityLookupId int
AS
DECLARE @dt DATETIME
SELECT @dt = getdate() 


;WITH ClientCTE(ClientId, ClientCode, ClientName, ParentID, lvl,IsSet)
AS
( 
	select ClientId, ClientCode, ClientName, ParentID,0,1 from [CWI_ClientTeamRelationship] CTR
	INNER JOIN CWI_Client C ON CTR.ClientId = C.ID
	WHERE 	EntityLookupId = @EntityLookupId AND CTR.UserId = @UserId
		AND
	( 
	(@dt between CTR.RelationshipActivateDate AND ISNULL(CTR.RelationshipInActivateDate,GETDATE()))
	OR 
	( CTR.RelationshipActivateDate>= @dt AND CTR.RelationshipInActivateDate IS NULL)

	)
	 UNION ALL
	 SELECT P.Id, P.ClientCode, P.ClientName, P.ParentID, M.lvl+1, 0
	 FROM CWI_Client AS P
	  JOIN ClientCTE AS M
	   ON P.ID = M.ParentID
 
)
 
SELECT 
	ClientId, ClientCode + ' - ' + CASE WHEN SUM(ISNULL(IsSet,0)) = 0 THEN ClientName +' - NOT Assigned' ELSE ClientName END ClientName, ParentID
FROM ClientCTE
GROUP BY 
	ClientId,ClientCode, ClientName, ParentID
 







GO
