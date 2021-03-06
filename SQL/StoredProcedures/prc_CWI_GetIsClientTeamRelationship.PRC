/****** Object:  StoredProcedure [dbo].[prc_CWI_GetIsClientTeamRelationship]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetIsClientTeamRelationship' )
 DROP PROCEDURE [dbo].[prc_CWI_GetIsClientTeamRelationship]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetIsClientTeamRelationship]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetIsClientTeamRelationship 
* Purpose : This PROC would be called TO get IsUsingClientTeamRelationship field for Team Relationship page
* Invoked from : Multiple Pages
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetIsClientTeamRelationship 14220
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetIsClientTeamRelationship]    
    @inClientId int	
AS
BEGIN

	BEGIN TRY
		DECLARE @dt DATETIME
		SELECT @dt = getdate() 

		SELECT ISNULL(IsUsingClientTeamRelationship,'') AS IsUsingClientTeamRelationship,
			ClientRelationsCount = 
			(
				SELECT count(*) FROM CWI_ClientTeamRelationship CTR
				WHERE ClientId = C.ParentID
				AND
			( 
			(@dt between CTR.RelationshipActivateDate AND ISNULL(CTR.RelationshipInActivateDate,GETDATE()))
			OR 
			( CTR.RelationshipActivateDate>= @dt AND CTR.RelationshipInActivateDate IS NULL)

			)
			)
		 
		FROM CWI_Client C WHERE ID=@inClientId
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
		
GO
