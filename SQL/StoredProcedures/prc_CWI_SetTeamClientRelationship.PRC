/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTeamClientRelationship]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetTeamClientRelationship' )
 DROP PROCEDURE [dbo].[prc_CWI_SetTeamClientRelationship]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTeamClientRelationship]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTeamClientRelationship]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetTeamClientRelationship
* Purpose : This PROC would be called TO set the team client relationship
* Invoked from : TeamClientReleationship.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetTeamClientRelationship 
''<DocumentElement>
  <EntityRelationship>
    <ClientId>2001</ClientId>
    <EntityId>13957</EntityId>
  </EntityRelationship>
  <EntityRelationship>
    <ClientId>2001</ClientId>
    <EntityId>14224</EntityId>
  </EntityRelationship>
</DocumentElement>''
, @RelationshipActivateDate=''2013-01-01'', @UserId=3, @Author=3
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetTeamClientRelationship] 

    @ClientEntity XML,
	@RelationshipActivateDate datetime,
	@UserId	int,
	@Author int
AS

BEGIN
	DECLARE @dt DATETIME
	SELECT @dt = getdate() 

	DECLARE @tblClientRelation TABLE
	(
		[ClientId] [int]  NULL,
		[EntityLookupId] [int]  NULL 
	)
	
	INSERT INTO @tblClientRelation
	(		
			[ClientId]
           ,[EntityLookupId]
	)
	SELECT 
		COLX.value(''(./ClientId)[1]'',''int'')
		,COLX.value(''(./EntityId)[1]'',''int'')
	from @ClientEntity.nodes(''DocumentElement/EntityRelationship'') AS TABX(COLX)

	
	INSERT INTO [CWI_ClientTeamRelationship]
				([ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
				[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				
	SELECT 
			C.ClientId
           ,C.EntityLookupId
           ,@UserId
           ,@dt
           ,@RelationshipActivateDate
		   ,@dt,@UserId,@dt,@UserId
	FROM 
		@tblClientRelation C
		LEFT OUTER JOIN CWI_ClientTeamRelationship CTR
		ON C.ClientId = CTR.ClientId AND CTR.UserId = @UserId AND CTR.EntityLookupId = C.EntityLookupId
		AND
	( 
	(@dt between CTR.RelationshipActivateDate AND ISNULL(CTR.RelationshipInActivateDate,@dt))
	OR 
	( CTR.RelationshipActivateDate>= @dt AND CTR.RelationshipInActivateDate IS NULL)

	)

	WHERE CTR.Id IS NULL

END




' 
END
GO
