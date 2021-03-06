/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTeamClientEntities]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetTeamClientEntities' )
 DROP PROCEDURE [dbo].[prc_CWI_GetTeamClientEntities]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTeamClientEntities]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_GetTeamClientEntities  
* Purpose : This PROC would be called TO get all the team realtion entities of user
* Invoked from : TeamClientRelationship.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTeamClientEntities @UserId=13
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetTeamClientEntities]
	@UserId int
AS
DECLARE @dt DATE
SELECT @dt =  CAST(getdate() as date)

select distinct L.ID, LookupName from [CWI_ClientTeamRelationship] CTR
INNER JOIN vw_CWI_ClientTeamRelation L
ON L.ID = CTR.EntityLookupId
WHERE
	CTR.UserId = @UserId
	AND
	( 
	(@dt between CTR.RelationshipActivateDate AND ISNULL(CTR.RelationshipInActivateDate,GETDATE()))
	OR 
	( CTR.RelationshipActivateDate>= @dt AND CTR.RelationshipInActivateDate IS NULL)

	)
GO
