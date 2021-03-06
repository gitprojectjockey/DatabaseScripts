IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetTeamClientRelationShipDataToTMIMMRDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Data_SetTeamClientRelationShipDataToTMIMMRDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetTeamClientRelationShipDataToTMIMMRDB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--Team / Client RelationShip Data Push

/*******************************************************************  
* PROCEDURE: prc_Data_SetTeamClientRelationShipDataToTMIMMRDB
* Purpose : This PROC would be called TO perform a data push of Client Additions/Modifications
						from ClientWise to TMIMMRDB Database using linked server
* Invoked from : Sql job xxxxxxx
* CREATED: Ajay Thacker
* CREATED ON : 21-May-2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_Data_SetTeamClientRelationShipDataToTMIMMRDB
**********************************************************************/ 
CREATE PROC [dbo].[prc_Data_SetTeamClientRelationShipDataToTMIMMRDB]
as


--Declare Variables
DECLARE 
	@dtLastClientSyncDateTime DATETIME,
	@dtCurrentDateTime DATETIME,
	@curClientId INT,
	@curClientCode varchar(5),
	@curHierarchyTypeLookupId INT,
	@vcClientCode varchar(3),
	@bitExists bit,
	@intMMISEntityUserId int,
	@vcCWEmail varchar(100),
	@intMMISClientID int,
	@curClientTeamUserId int,
	@curEntityLookupId int,
	@curRelationshipActivateDate  datetime

BEGIN TRY
	--Fetch when was the last time the sync for TeamClientRelationShip was performed
	SET @dtLastClientSyncDateTime = (SELECT CONVERT(DATETIME,LookupName)  FROM dbo.Lookup
																				WHERE Id = 6153) --TeamClientRelationshipSyncDateTimeToTmimmrdb

   set @dtCurrentDateTime = getdate()

	--STEP 4: CHECK IF THERE WERE ANY CLIENT TEAM RELATIONSHIPS ADDED / UPDATED FROM TEAM RELATIONSHIP TAB
	IF EXISTS (Select Id from CWI_ClientTeamRelationship
								where 
								(CreatedOn > @dtLastClientSyncDateTime and CreatedOn <= @dtCurrentDateTime)
										or 
										(ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
							)
					BEGIN

								declare cur_ClientTeam cursor for
								Select distinct ClientID,UserId,EntityLookupId,RelationShipActivateDate
									from CWI_ClientTeamRelationship
									where 
									(CreatedOn > @dtLastClientSyncDateTime and CreatedOn <= @dtCurrentDateTime)
											or 
											(ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
								open cur_ClientTeam
								fetch from cur_ClientTeam into @curClientID,@curClientTeamUserId,@curEntityLookupId,@curRelationshipActivateDate 
																										  
								while @@fetch_Status = 0
								BEGIN
												
												set @vcClientCode = (Select Clientcode from cwi_client 
																								where id = @curClientID)
												set @intMMISClientID = (select ClientId 	FROM mmis.tmimmrdb.dbo.Client 
																										WHERE  CliCode	 = left(@vcClientCode,3))
													set @vcCWEmail = (Select Email from CWI_User
															where ID = @curClientTeamUserId)
													set @intMMISEntityUserId = (Select UserID from mmis.tmimmrdb.dbo.awusers
																													where email =@vcCWEmail
																													)
														if exists (Select MMARepresentativeID from mmis.tmimmrdb.dbo.MMARepresentatives
																			where ClientID = @intMMISClientID)
																	set @bitExists = 1

															if @curEntityLookupId= 2001 --Account Executive
															BEGIN
																		if @bitexists = 1
																					UPDATE mmis.tmimmrdb.dbo.MMARepresentatives
																					Set AccountExecutiveUserId = @intMMISEntityUserId
																					where ClientID =@intMMISClientID
																		ELSE
																					INSERT INTO mmis.tmimmrdb.dbo.MMARepresentatives
																					(
																						ClientId,
																						ClientServiceDirectorUserId,
																						SalesRepUserId,
																						AccountExecutiveUserId
																					)
																					VALUES
																					(
																						@intMMISClientID,
																						null,
																						null,
																						@intMMISEntityUserId
																					 )
																				UPDATE mmis.tmimmrdb.dbo.SettlementMMARepresentatives
																				SET		AccountExecutiveUserId = @intMMISEntityUserId
																				FROM mmis.tmimmrdb.dbo.Settlements As S INNER JOIN mmis.tmimmrdb.dbo.SettlementMMARepresentatives As SMM
																					ON S.ID = SMM.SettlementId
																				WHERE S.CliCode = left(@vcClientCode,3)
																				AND S.WeekEnding >= @curRelationshipActivateDate
																				

															END
															ELSE IF @curEntityLookupId= 2002 --Account Group Director
															BEGIN
																			IF @bitexists = 1
																						UPDATE mmis.tmimmrdb.dbo.MMARepresentatives
																						Set ClientServiceDirectorUserId = @intMMISEntityUserId
																						where ClientID =@intMMISClientID
																			ELSE
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
																					UPDATE mmis.tmimmrdb.dbo.SettlementMMARepresentatives
																				SET		ClientServiceDirectorUserId = @intMMISEntityUserId
																				FROM mmis.tmimmrdb.dbo.Settlements As S INNER JOIN mmis.tmimmrdb.dbo.SettlementMMARepresentatives As SMM
																					ON S.ID = SMM.SettlementId
																				WHERE S.CliCode = left(@vcClientCode,3)
																				AND S.WeekEnding >= @curRelationshipActivateDate

															END
															ELSE IF @curEntityLookupId= 2003 --sales rep
															BEGIN
																			IF @bitexists = 1
																								update mmis.tmimmrdb.dbo.MMARepresentatives
																								Set SalesRepUserId = @intMMISEntityUserId
																								where ClientID =@intMMISClientID
																			ELSE
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
																				UPDATE mmis.tmimmrdb.dbo.SettlementMMARepresentatives
																				SET		SalesRepUserId = @intMMISEntityUserId
																				FROM mmis.tmimmrdb.dbo.Settlements As S INNER JOIN mmis.tmimmrdb.dbo.SettlementMMARepresentatives As SMM
																					ON S.ID = SMM.SettlementId
																				WHERE S.CliCode = left(@vcClientCode,3)
																				AND S.WeekEnding >= @curRelationshipActivateDate

															END
											fetch from cur_ClientTeam into @curClientID,@curClientTeamUserId,@curEntityLookupId,@curRelationshipActivateDate 
									END
									close cur_ClientTeam
									deallocate cur_ClientTeam

							END

	--Update the lookup with the current sync time
	Update dbo.Lookup
	Set LookupName = convert(varchar(20),@dtCurrentDateTime)
	WHERE Id = 6153


END TRY
	BEGIN CATCH	
		declare @vcbody NVARCHAR(MAX),
				@vcprofilename varchar(255), 
				@vcemailSubject varchar(255),
				@vcEmailAddress varchar(255)

					set @vcprofilename = (SELECT [LookupName] FROM [dbo].[Lookup]
							WHERE [LookupTypeId]=16 --DatabaseEmailProfileName
							AND [IsActive]=1) 

						set @vcEmailAddress = ''ajay.thacker@xerox.com''

						set @vcemailSubject = ''ClientWise : Data Sync for TeamClientRelationShip Failed''
						set @vcbody = ERROR_MESSAGE()

						--Send Email
						EXEC msdb.dbo.sp_send_dbmail 
													@profile_name=@vcprofilename, 
													@recipients = @vcEmailAddress,
													--@copy_recipients= '''',
													--@blind_copy_recipients = '''',
													@subject = @vcemailSubject, 
													@body = @vcbody,
													@body_format = ''HTML''	 


		
	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
	' 
END
GO
