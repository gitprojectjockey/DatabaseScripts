IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTeamClientReleationshipsByUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTeamClientReleationshipsByUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTeamClientReleationshipsByUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetTeamClientReleationshipsByUser
* Purpose : This PROC would be called TO get all the relationships of the user
* Invoked from : TeamClientRelationship.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTeamClientReleationshipsByUser @UserId = 3
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetTeamClientReleationshipsByUser]
	@UserId int
AS


DECLARE @dt DATETIME
SELECT @dt = getdate() 

DECLARE @tbl TABLE
(
	Id int,
	Code varchar(2000),
	Name varchar(2000),
	ParentId int,
	EntityId	int,
	ReturnId varchar(20),
	ReturnParentId varchar(2000)
)


INSERT INTO @tbl
(Id, Code, Name,ParentId,EntityId,ReturnId, ReturnParentId)
select  
	ClientId, ClientCode,
	ClientCode + '' - '' +  ClientName,
	ParentID, EntityLookupId, cast(EntityLookupId as varchar(20)) + ''_'' + cast(ClientId as varchar(20)), 
	cast(EntityLookupId as varchar(20)) + ''_'' + cast(ParentID as varchar(20)) 
from [CWI_ClientTeamRelationship] CTR
	INNER JOIN CWI_Client C ON CTR.ClientId = C.ID
	WHERE 	CTR.UserId = @UserId
		AND
	( 
	(@dt between CTR.RelationshipActivateDate AND ISNULL(CTR.RelationshipInActivateDate,GETDATE()))
	OR 
	( CTR.RelationshipActivateDate>= @dt AND CTR.RelationshipInActivateDate IS NULL)

	)
INSERT INTO @tbl
(Id, Code, Name,ParentId,EntityId,ReturnId, ReturnParentId)
select distinct C.Id, C.ClientCode,
	C.ClientCode + '' - '' +  C.ClientName +'' - NOT Assigned''  ClientName,
	C.ParentID, t1.EntityId, cast(t1.EntityId as varchar(20)) + ''_'' + cast(C.Id as varchar(20)), cast(t1.EntityId as varchar(20)) + ''_'' + cast(C.ParentID as varchar(20))  
from @tbl t1
INNER JOIN CWI_Client C ON C.Id = t1.ParentId
LEFT OUTER JOIN @tbl t2 ON t1.ParentId = t2.Id  AND t1.EntityId = t2.EntityId
WHERE t2.ID IS NULL

INSERT INTO @tbl
(Id, Code, Name,ParentId,EntityId, ReturnId)
select 
	distinct L.ID, '''', L.LookupName,NULL,NULL, ''M'' + cast(L.ID as varchar(20))  
from @tbl t
INNER JOIN Lookup L ON t.EntityId = L.Id
WHERE t.ParentId IS NULL

--select * from @tbl

select 
	ReturnId Id,
	Name ,
	CASE WHEN ParentId IS NULL AND EntityId is NOT NULL THEN ''M'' + cast(EntityId  as varchar(20)) ELSE  cast(ReturnParentID as varchar(20)) END ParentId
from @tbl

' 
END
GO


