/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientTeamRelationship]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientTeamRelationship' )
 DROP PROCEDURE [dbo].[prc_CWI_SetClientTeamRelationship]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientTeamRelationship]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: [prc_CWI_SetClientTeamRelationship]
* Purpose : This PROC would be called TO INSERT OR UPDATE the team relationship details
* Invoked from : Client_TeamRelationship.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientTeamRelationship 
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientTeamRelationship]
	@inTeamRelationshipId int=NULL,
	@inClientId int,
	@inEntityLookupId int,
	@inUserId int,
	@dtRelationshipCreatedDate datetime,
	@dtRelationshipActivateDate	datetime,
	@dtRelationshipInActivateDate datetime=NULL,	
	@inCreatedBy int=NULL,	
	@inModifiedBy int,	
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY	
		DECLARE @TBL_TEAMRELATIONSHIP TABLE (TeamRelationshipId int)	
		DECLARE @TeamRelationshipId INT,  @Count INT=0;
		SET @Count=(select COUNT(*) from CWI_ClientTeamRelationship where ClientId = @inClientId and EntityLookupId=@inEntityLookupId and UserId=@inUserId);
		


		IF( @inTeamRelationshipId IS NULL AND @Count=0)
		BEGIN	
				INSERT INTO [dbo].[CWI_ClientTeamRelationship]
				([ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
				[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				VALUES
				(@inClientId,@inEntityLookupId,@inUserId,@dtRelationshipCreatedDate,@dtRelationshipActivateDate,
				GETDATE(),@inCreatedBy,GETDATE(),@inModifiedBy)	
				------	insert client team relationship details for a division
				IF (SELECT COUNT(*) FROM CWI_Client WHERE ParentID=@inClientId AND IsUsingClientTeamRelationship=1)<> 0 
					BEGIN	
					
						INSERT INTO @TBL_TEAMRELATIONSHIP						
						SELECT DISTINCT ClientId FROM CWI_ClientTeamRelationship WHERE ClientId IN 
						(SELECT ID FROM CWI_Client WHERE ParentID=@inClientId AND IsUsingClientTeamRelationship=1)						
						
						DECLARE @TRClientId INT
						SET @TRClientId = (SELECT TOP 1 TeamRelationshipId FROM @TBL_TEAMRELATIONSHIP 
						ORDER BY TeamRelationshipId)

						WHILE @TRClientId IS NOT NULL
						BEGIN													
							INSERT INTO [dbo].[CWI_ClientTeamRelationship]
							([ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
							[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
							VALUES
							(@TRClientId,@inEntityLookupId,@inUserId,@dtRelationshipCreatedDate,@dtRelationshipActivateDate,
							GETDATE(),@inCreatedBy,GETDATE(),@inModifiedBy)	

							DELETE FROM @TBL_TEAMRELATIONSHIP WHERE TeamRelationshipId=@TRClientId
							SET @TRClientId = (SELECT TOP 1 TeamRelationshipId FROM @TBL_TEAMRELATIONSHIP 
							ORDER BY TeamRelationshipId)

						END
					END
			 -------	
			 ELSE
			 Return;								
		END
		ELSE
		

		BEGIN
			IF( @inTeamRelationshipId is null and @Count>0 )

 SET @inTeamRelationshipId= (select Id from CWI_ClientTeamRelationship where ClientId = @inClientId and EntityLookupId=@inEntityLookupId and UserId=@inUserId);

			UPDATE [dbo].[CWI_Client] SET [IsUsingClientTeamRelationship]=0
			WHERE ID=@inClientId --and ParentID <> NULL

			IF @dtRelationshipInActivateDate IS NULL
			BEGIN
				IF EXISTS (SELECT UserId FROM [dbo].[CWI_ClientTeamRelationship] WHERE UserId=@inUserId AND Id=@inTeamRelationshipId)
				BEGIN
					----insert into history table before updating
					INSERT INTO [dbo].[CWI_History_ClientTeamRelationship]
					([TeamRelationshipId],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
					[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
					SELECT [Id],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
					[CreatedOn],[CreatedBy],GETDATE(),[ModifiedBy]
					FROM [dbo].[CWI_ClientTeamRelationship] WHERE [Id]=@inTeamRelationshipId

					UPDATE [dbo].[CWI_ClientTeamRelationship]
					SET [ClientId]=@inClientId,[EntityLookupId]=@inEntityLookupId,[UserId]=@inUserId,
					[RelationshipActivateDate]=@dtRelationshipActivateDate,
					[RelationshipInActivateDate]=null,
					[ModifiedOn]=GETDATE(),ModifiedBy=@inModifiedBy
					WHERE [Id]=@inTeamRelationshipId	

					IF (SELECT COUNT(*) FROM CWI_Client WHERE ParentID=@inClientId AND IsUsingClientTeamRelationship=1)<> 0 
					BEGIN						
						INSERT INTO @TBL_TEAMRELATIONSHIP						
						SELECT ID FROM CWI_ClientTeamRelationship WHERE ClientId IN 
						(SELECT ID FROM CWI_Client WHERE ParentID=@inClientId AND IsUsingClientTeamRelationship=1)	
						AND [EntityLookupId]=@inEntityLookupId AND 	[UserId]=@inUserId			
						
						SET @TeamRelationshipId = (SELECT TOP 1 TeamRelationshipId FROM @TBL_TEAMRELATIONSHIP 
						ORDER BY TeamRelationshipId)

						WHILE @TeamRelationshipId IS NOT NULL
						BEGIN	
							--insert into history table before updating for division level			
							INSERT INTO [dbo].[CWI_History_ClientTeamRelationship]
							([TeamRelationshipId],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
							[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
							SELECT [Id],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
							[CreatedOn],[CreatedBy],GETDATE(),[ModifiedBy]
							FROM [dbo].[CWI_ClientTeamRelationship] WHERE [Id]=@TeamRelationshipId
											
							UPDATE [dbo].[CWI_ClientTeamRelationship]
							SET [EntityLookupId]=@inEntityLookupId,[UserId]=@inUserId,
							[RelationshipActivateDate]=@dtRelationshipActivateDate,
							[ModifiedOn]=GETDATE(),ModifiedBy=@inModifiedBy
							WHERE [Id]=@TeamRelationshipId

							DELETE FROM @TBL_TEAMRELATIONSHIP WHERE TeamRelationshipId=@TeamRelationshipId
							SET @TeamRelationshipId = (SELECT TOP 1 TeamRelationshipId FROM @TBL_TEAMRELATIONSHIP 
							ORDER BY TeamRelationshipId)

						END
					END

				END
				ELSE
				
				BEGIN
					INSERT INTO [dbo].[CWI_ClientTeamRelationship]
					([ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
					[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
					VALUES
					(@inClientId,@inEntityLookupId,@inUserId,@dtRelationshipCreatedDate,@dtRelationshipActivateDate,
					GETDATE(),@inCreatedBy,GETDATE(),@inModifiedBy)	

					IF (SELECT COUNT(*) FROM CWI_Client WHERE ParentID=@inClientId AND IsUsingClientTeamRelationship=1)<> 0 
					BEGIN	
					
						INSERT INTO @TBL_TEAMRELATIONSHIP						
						SELECT ClientId FROM CWI_ClientTeamRelationship WHERE ClientId IN 
						(SELECT ID FROM CWI_Client WHERE ParentID=@inClientId AND IsUsingClientTeamRelationship=1)						
						
						DECLARE @ClientId INT
						SET @ClientId = (SELECT TOP 1 TeamRelationshipId FROM @TBL_TEAMRELATIONSHIP 
						ORDER BY TeamRelationshipId)

						WHILE @ClientId IS NOT NULL
						BEGIN													
							INSERT INTO [dbo].[CWI_ClientTeamRelationship]
							([ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
							[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
							VALUES
							(@ClientId,@inEntityLookupId,@inUserId,@dtRelationshipCreatedDate,@dtRelationshipActivateDate,
							GETDATE(),@inCreatedBy,GETDATE(),@inModifiedBy)	

							DELETE FROM @TBL_TEAMRELATIONSHIP WHERE TeamRelationshipId=@ClientId
							SET @ClientId = (SELECT TOP 1 TeamRelationshipId FROM @TBL_TEAMRELATIONSHIP 
							ORDER BY TeamRelationshipId)

						END
					END
				END
			END
			ELSE
			BEGIN
				
				INSERT INTO [dbo].[CWI_History_ClientTeamRelationship]
				([TeamRelationshipId],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
				[RelationshipInactivateDate],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				SELECT [Id],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
				[RelationshipInActivateDate],[CreatedOn],[CreatedBy],GETDATE(),[ModifiedBy]
				FROM [dbo].[CWI_ClientTeamRelationship] WHERE [Id]=@inTeamRelationshipId

				UPDATE [dbo].[CWI_ClientTeamRelationship]
				SET [ClientId]=@inClientId,[EntityLookupId]=@inEntityLookupId,[UserId]=@inUserId,
				[RelationshipActivateDate]=@dtRelationshipActivateDate,RelationshipInActivateDate=@dtRelationshipInActivateDate,
				[ModifiedOn]=GETDATE(),ModifiedBy=@inModifiedBy
				WHERE [Id]=@inTeamRelationshipId				

				--DELETE FROM [dbo].[CWI_ClientTeamRelationship] WHERE [Id]=@inTeamRelationshipId
				
				IF (SELECT COUNT(*) FROM CWI_Client WHERE ParentID=@inClientId AND IsUsingClientTeamRelationship=1)<> 0 
					BEGIN						
						INSERT INTO @TBL_TEAMRELATIONSHIP						
						SELECT ID FROM CWI_ClientTeamRelationship WHERE EntityLookupId=@inEntityLookupId
						AND UserId=@inUserId AND ClientId IN 
						(SELECT ID FROM CWI_Client WHERE ParentID=@inClientId AND IsUsingClientTeamRelationship=1)						
						AND [EntityLookupId]=@inEntityLookupId

						SET @TeamRelationshipId = (SELECT TOP 1 TeamRelationshipId FROM @TBL_TEAMRELATIONSHIP 
						ORDER BY TeamRelationshipId)

						WHILE @TeamRelationshipId IS NOT NULL
						BEGIN
							
							INSERT INTO [dbo].[CWI_History_ClientTeamRelationship]
							([TeamRelationshipId],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
							[RelationshipInactivateDate],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
							SELECT [Id],[ClientId],[EntityLookupId],[UserId],[RelationshipCreatedDate],[RelationshipActivateDate],
							[RelationshipInActivateDate],[CreatedOn],[CreatedBy],GETDATE(),[ModifiedBy]
							FROM [dbo].[CWI_ClientTeamRelationship] WHERE [Id]=@TeamRelationshipId
															
							UPDATE [dbo].[CWI_ClientTeamRelationship]
							SET [EntityLookupId]=@inEntityLookupId,[UserId]=@inUserId,
							[RelationshipActivateDate]=@dtRelationshipActivateDate,RelationshipInActivateDate=@dtRelationshipInActivateDate,
							[ModifiedOn]=GETDATE(),ModifiedBy=@inModifiedBy
							WHERE [Id]=@TeamRelationshipId							

							--DELETE FROM [dbo].[CWI_ClientTeamRelationship] WHERE [Id]=@TeamRelationshipId

							DELETE FROM @TBL_TEAMRELATIONSHIP WHERE TeamRelationshipId=@TeamRelationshipId

							SET @TeamRelationshipId = (SELECT TOP 1 TeamRelationshipId FROM @TBL_TEAMRELATIONSHIP 
							ORDER BY TeamRelationshipId)

						END
					END					
				
			END
		END			
		

		--Data Sync from ClientWise to TMIMMRDB
		declare @isDataSyncOn bit,
						@intMMISClientID int,
						@vcClientCode varchar(3),
						@bitExists bit,
						@intMMISEntityUserId int,
						@vcCWEmail varchar(100)

		set @bitExists = 0
		set @isDataSyncOn = (Select case when LookupName = 'YES' then 1 else 0 end
																			from Lookup
																			Where ID = 6151 and LookupTypeID = 25)--DataSyncToTmimmrdb
			if @isDataSyncOn = 1
			BEGIN
				set @vcClientCode = (Select Clientcode from cwi_client 
																where id = @inClientId)
				set @intMMISClientID = (select ClientId 	FROM mmis.tmimmrdb.dbo.Client WHERE  CliCode	 = @vcClientCode)
				set @vcCWEmail = (Select Email from CWI_User
															where ID = @inUserId)
				set @intMMISEntityUserId = (Select UserID from mmis.tmimmrdb.dbo.awusers
																				where email =@vcCWEmail
																				)

				if exists (Select MMARepresentativeID from mmis.tmimmrdb.dbo.MMARepresentatives
									where ClientID = @intMMISClientID)
						set @bitExists = 1
							

					if @inEntityLookupId= 2001 --Account Executive
								begin
				

				if @bitexists = 1
					update mmis.tmimmrdb.dbo.MMARepresentatives
					Set AccountExecutiveUserId = @intMMISEntityUserId
					where ClientID =@intMMISClientID
				else
							INSERT INTO mmis.tmimmrdb.dbo.MMARepresentatives
							(ClientId,
							ClientServiceDirectorUserId,
							SalesRepUserId,
							AccountExecutiveUserId
							)
						VALUES
								(@intMMISClientID,
									null,
									null,
									 @intMMISEntityUserId
									)

		end
					else if @inEntityLookupId= 2002 --Account Group Director
								begin
				if @bitexists = 1
					update mmis.tmimmrdb.dbo.MMARepresentatives
					Set ClientServiceDirectorUserId = @intMMISEntityUserId
					where ClientID =@intMMISClientID
				 else
				 INSERT INTO mmis.tmimmrdb.dbo.MMARepresentatives
							(ClientId,
							ClientServiceDirectorUserId,
							SalesRepUserId,
							AccountExecutiveUserId
							)
						VALUES
								(@intMMISClientID,
									@intMMISEntityUserId,
									null,
									 null
									)
		end
					else if @inEntityLookupId= 2003 --sales rep
								begin
				if @bitexists = 1
					update mmis.tmimmrdb.dbo.MMARepresentatives
					Set SalesRepUserId = @intMMISEntityUserId
					where ClientID =@intMMISClientID
				else
					 INSERT INTO mmis.tmimmrdb.dbo.MMARepresentatives
							(ClientId,
							ClientServiceDirectorUserId,
							SalesRepUserId,
							AccountExecutiveUserId
							)
						VALUES
								(@intMMISClientID,
									null,
									@intMMISEntityUserId,
									 null
									)
			end
			END
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
GO
