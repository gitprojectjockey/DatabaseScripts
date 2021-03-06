/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientSettings]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientSettings' )
 DROP PROCEDURE [dbo].[prc_CWI_SetClientSettings]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientSettings]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientSettings 
* Purpose : This PROC would be called TO INSERT client's team relationship details
* Invoked from : Client_TeamRelationship.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
declare @inRowCount int=0;
exec prc_CWI_SetClientSettings 13957,13976,8, 1, @inRowCount output
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientSettings]
	@inParentClientId int,
	@inClientId int,
	@inCreatedBy int,	
	@bitIsUseClientSettings bit,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY	
	Declare @Count int=0;



			UPDATE [dbo].[CWI_Client] SET [IsUsingClientTeamRelationship]=@bitIsUseClientSettings
			WHERE ID=@inClientId	

			IF @bitIsUseClientSettings=1
			BEGIN
				INSERT INTO [dbo].[CWI_History_ClientTeamRelationship]
				([TeamRelationshipId],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
				[RelationshipInactivateDate],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				SELECT [Id],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
				[RelationshipInActivateDate],[CreatedOn],[CreatedBy],GETDATE(),[ModifiedBy]
				FROM [dbo].[CWI_ClientTeamRelationship] WHERE [ClientId]=@inClientId

				DELETE FROM [dbo].[CWI_ClientTeamRelationship] WHERE [ClientId]=@inClientId

				INSERT INTO [dbo].[CWI_ClientTeamRelationship]
				SELECT @inClientId,[EntityLookupId],[UserId],[RelationshipCreatedDate],
				[RelationshipActivateDate],[RelationshipInActivateDate],GETDATE(),@inCreatedBy,GETDATE(),@inCreatedBy
				FROM [dbo].[CWI_ClientTeamRelationship] 
				WHERE [ClientId]=@inParentClientId
			END		

			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
			--END

	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
GO
