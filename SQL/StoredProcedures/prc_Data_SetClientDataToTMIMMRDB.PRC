IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetClientDataToTMIMMRDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Data_SetClientDataToTMIMMRDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetClientDataToTMIMMRDB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
--Client Data Push

/*******************************************************************  
* PROCEDURE: prc_Data_SetClientDataToTMIMMRDB
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
exec prc_Data_SetClientDataToTMIMMRDB
**********************************************************************/ 
CREATE PROC [dbo].[prc_Data_SetClientDataToTMIMMRDB]
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
	@curRelationshipActivateDate datetime

BEGIN TRY
	--Fetch when was the last time the sync for Client was performed
	SET @dtLastClientSyncDateTime = (SELECT CONVERT(DATETIME,LookupName)  FROM dbo.Lookup
																				WHERE Id = 6151) --ClientSyncDateTimeToTmimmrdb

   set @dtCurrentDateTime = getdate()
	
	--STEP 1 : CHECK IF THERE WERE ANY NEW CLIENTS  / DIVISIONS CREATED AFTER THE LAST SYNC TIME
	IF EXISTS (SELECT Id FROM CWI_Client
						WHERE CreatedOn > @dtLastClientSyncDateTime  and CreatedOn <= @dtCurrentDateTime) 
	BEGIN
			DECLARE cur_NewClient CURSOR
			FOR
				SELECT Id,HierarchyTypeLookupID FROM CWI_Client WHERE CreatedOn > @dtLastClientSyncDateTime
																and CreatedOn <= @dtCurrentDateTime
			OPEN cur_NewClient
			FETCH FROM cur_NewClient into @curClientId,@curClientCode,@curHierarchyTypeLookupId
			WHILE @@FETCH_STATUS = 0
			 BEGIN
				if @curHierarchyTypeLookupId = 521 -- Client
					--we add the main client in Parent table, and we add the division in Client table
				BEGIN
							if not exists (Select ParentCd from mmis.tmimmrdb.dbo.Parent where ParentCd = @curClientCode)
								INSERT INTO mmis.tmimmrdb.dbo.Parent
								(
								ParentCd,
								CompanyName,
								BillAddr1,
								BillAddr2,
								BillCity,
								BillStCode,
								BillZip,
								Phone,
								PhoneExt,
								Fax,
								AdTracking,
								AdTrackingReports,
								ConsolidatedInvoice, 
								EmailAdApproval, 
								InvDeliveryType,
								CWClientId
								)
								SELECT
								left(C.ClientCode,3),
								C.ClientName,
								A.AddressLine1,
								A.AddressLine2,
								A.City,
								(Select StateCode from [State] where ID = A.StateID),
								A.Zip,
								A.WorkPhone,
								A.WorkExtn,
								A.WorkFax,
								0, --Ad Tracking
								0, --Ad Tracking Reports
								0, --Consolidated Invoice
								0, --Email Ad Approval
								''Manual'',--InvDeliveryType
								@curClientId
								FROM CWI_Client C
									inner join CWI_Address A
											on C.AddressID = A.ID
								where C.ID = @curClientId
				END
				ELSE --Division
				BEGIN
							if not exists (Select CliCode from mmis.tmimmrdb.dbo.Client where CliCode = @curClientCode)
							BEGIN
								INSERT INTO mmis.tmimmrdb.dbo.Client
									(
									CliCode,
									ParentCode,
									ClientName,
									BillAddr1,
									BillAddr2,
									BillCity,
									BillStCode,
									BillZip,
									Phone1,
									PhoneExt1,
									Fax1,
									TrkingSht,
									CustSignOff,
									MMSoftware,
									[FaxInvoice],
									[AttachTear],
									[POReq],
									[Active],
									[ActgXRefTrnsfrdToFinance],
									[AdTrackingReports],
									[EmailAdApproval],
									InvoiceType,
									InvDeliveryType,
									CWClientId
									)
									SELECT
									left(C.ClientCode,3),
									left(P.ClientCode,3),
									C.ClientName,
									A.AddressLine1,
									A.AddressLine2,
									A.City,
									(Select StateCode from [State] where ID = A.StateID),
									A.Zip,
									A.WorkPhone,
									A.WorkExtn,
									A.WorkFax,
									0, --Tracking Sheet
									0, --CustSignOff
									0,--MMSoftware
									0, --FaxInvoice
									0, --AttachTear
									0,--PoReq
									1, --Active
									0,--ActgXRefTrnsfrdToFinance
									0,--AdTrackingReports
									1,--EmailAdApproval
									''C'', --InvoiceType
									''Manual'',
									@curClientId
									FROM CWI_Client C
											inner join CWI_Client P
													on C.ParentID = P.ID
											inner join CWI_Address A
													on C.AddressID = A.ID
									where C.ID = @curClientId

								--We also insert zero markup records for MediaClass for this new division
								INSERT INTO mmis.tmimmrdb.dbo.MediaClassMarkup
								(
								MediaClassID,CliCode,MarkupPercent
								)
								Select 
										MC.ID,
									left(@curClientCode,3),
									0
								from 
										mmis.tmimmrdb.dbo.MediaClass MC
											inner join dbo.Lookup Look
																			on replace(Look.LookupName,''Job Boards'',''Internet'') = MC.Classification
																					and Look.LookupTypeID = 3 --Classification
																					and Look.IsActive = 1
								order by mc.id
							END

				END

				FETCH NEXT FROM cur_NewClient into @curClientId,@curClientCode,@curHierarchyTypeLookupId
			END

			CLOSE cur_NewClient
			DEALLOCATE cur_NewClient

	END

	--STEP 2 : CHECK IF THERE WERE ANY EXISTING CLIENTS / DIVISIONS UPDATED AFTER THE LAST SYNC TIME
	IF EXISTS (SELECT Id FROM CWI_Client
						WHERE ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
	BEGIN
					DECLARE cur_ExistingClient CURSOR
			FOR
				SELECT Id,ClientCode,HierarchyTypeLookupID FROM CWI_Client WHERE ModifiedOn > @dtLastClientSyncDateTime
												and ModifiedOn <= @dtCurrentDateTime
			OPEN cur_ExistingClient
			FETCH FROM cur_ExistingClient into @curClientId,@curClientCode,@curHierarchyTypeLookupId
			WHILE @@FETCH_STATUS = 0
			 BEGIN
				if @curHierarchyTypeLookupId = 521 -- Client
				BEGIN
						Update mmis.tmimmrdb.dbo.Parent
						SET
							  ParentCd = left(C.ClientCode,3),
							  CompanyName =C.ClientName,
							  ActgXRef = C.ActgXRef,
								BillAddr1 = A.AddressLine1,
								BillAddr2 = A.AddressLine2,
								BillCity = A.City,
								BillStCode = (Select StateCode from [State] where ID = A.StateID),
								BillZip = A.Zip,
								Phone = A.WorkPhone,
								PhoneExt = A.WorkExtn,
								Fax = A.WorkFax,
								CWClientID = @curClientId
						FROM CWI_Client C
									inner join CWI_Address A
											on C.AddressID = A.ID							
									inner join mmis.tmimmrdb.dbo.Parent P
											--on P.CWClientID = @curClientId
											on P.ParentCd =  left(C.ClientCode,3)
								where C.ID = @curClientId
								
									
				END
				ELSE --Division
				BEGIN
						Update mmis.tmimmrdb.dbo.Client
						SET
							   CliCode = left(CWIC.ClientCode,3),
								ClientName =CWIC.ClientName,
								PoReq = CWIC.IsPOReqd,
								ActgXRef = CWIC.ActgXRef,
								MarkupPct = CWIC.MarkupPct,
								BillAddr1 =A.AddressLine1,
								BillAddr2 =A.AddressLine2,
								BillCity = A.City,
								BillStCode = (Select StateCode from [State] where ID = A.StateID),
								BillZip =A.Zip,
								Phone1 =A.WorkPhone,
								PhoneExt1 =A.WorkExtn,
								Fax1 =A.WorkFax
						 FROM  CWI_Client CWIC
									inner join CWI_Address A
											on CWIC.AddressID = A.ID
								 inner join 	mmis.tmimmrdb.dbo.Client C						
										--on C.CWClientID = CWIC.ID
										on C.CliCode =  left(CWIC.ClientCode,3)
								WHERE CWIC.ID = @curClientId
								
				END


				FETCH NEXT FROM cur_ExistingClient into @curClientId,@curClientCode,@curHierarchyTypeLookupId
			 END

			 CLOSE cur_ExistingClient
			 DEALLOCATE cur_ExistingClient
	END


	--STEP 3 : CHECK IF THERE WERE ANY CLIENT CLASSIFICATION MARKUPS CHANGED FROM CLIENT ACCOUNTING TAB
	IF EXISTS (SELECT Id FROM CWI_ClientClassification where
								(CreatedOn > @dtLastClientSyncDateTime and CreatedOn <= @dtCurrentDateTime)
								or 
								(ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
							)
				BEGIN
						declare cur_ClientClassification cursor for
						Select distinct ClientID
							from CWI_ClientClassification
							where 
							(CreatedOn > @dtLastClientSyncDateTime and CreatedOn <= @dtCurrentDateTime)
									or 
									(ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
						open cur_ClientClassification
						fetch from cur_ClientClassification into @curClientID
																										  
						while @@fetch_Status = 0
						BEGIN
								
									Update mmis.tmimmrdb.dbo.MediaClassMarkup
												Set MarkupPercent = case when CC.MarkupPct is null then null
																							when CC.MarkupPct < 1 then CC.MarkupPct * 100
																							else CC.MarkupPct
																					end
												From CWI_Client CWIC
												inner join CWI_ClientClassification CC
														on CWIC.ID = CC.ClientID
												inner join mmis.tmimmrdb.dbo.Client C
														on CWIC.ClientCode = C.CliCode
																and CWIC.ID = @curClientID
													inner join mmis.tmimmrdb.dbo.MediaClassMarkup MCM
														on C.CliCode = MCM.CliCode
													inner join  mmis.tmimmrdb.dbo.MediaClass MC
														on MCM.MediaClassID = MC.ID
													inner join dbo.Lookup Look
															on replace(Look.LookupName,''Jobboard'',''Internet'') = MC.Classification
																	and Look.LookupTypeID = 3
												where CWIC.ID = @curClientID

								fetch from cur_ClientClassification into @curClientID
						END
						close cur_ClientClassification
						deallocate cur_ClientClassification
				END

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
																										WHERE  CliCode	 = @vcClientCode)
													set @vcCWEmail = (Select Email from CWI_User
															where ID = @curClientTeamUserId)
													set @intMMISEntityUserId = (Select UserID from mmis.tmimmrdb.dbo.awusers
																													where email =@vcCWEmail
																													)
														if exists (Select MMARepresentativeID from mmis.tmimmrdb.dbo.MMARepresentatives
																			where ClientID = @intMMISClientID)
																	set @bitExists = 1

															if @curEntityLookupId= 2001 --Account Executive
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
																	UPDATE mmis.tmimmrdb.dbo.SettlementMMARepresentatives
																				SET		AccountExecutiveUserId = @intMMISEntityUserId
																				FROM Settlements As S INNER JOIN SettlementMMARepresentatives As SMM
																					ON S.ID = SMM.SettlementId
																				WHERE S.CliCode = left(@vcClientCode,3)
																				AND S.WeekEnding >= @curRelationshipActivateDate
															end
															else if @curEntityLookupId= 2002 --Account Group Director
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
																					UPDATE mmis.tmimmrdb.dbo.SettlementMMARepresentatives
																					SET		ClientServiceDirectorUserId = @intMMISEntityUserId
																					FROM Settlements As S INNER JOIN SettlementMMARepresentatives As SMM
																						ON S.ID = SMM.SettlementId
																					WHERE S.CliCode = left(@vcClientCode,3)
																					AND S.WeekEnding >= @curRelationshipActivateDate
																			end
															else if @curEntityLookupId= 2003 --sales rep
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
																								UPDATE mmis.tmimmrdb.dbo.SettlementMMARepresentatives
																								SET		SalesRepUserId = @intMMISEntityUserId
																								FROM Settlements As S INNER JOIN SettlementMMARepresentatives As SMM
																									ON S.ID = SMM.SettlementId
																								WHERE S.CliCode = left(@vcClientCode,3)
																								AND S.WeekEnding >= @curRelationshipActivateDate
																					end
											fetch from cur_ClientTeam into @curClientID,@curClientTeamUserId,@curEntityLookupId,@curRelationshipActivateDate
									END
									close cur_ClientTeam
									deallocate cur_ClientTeam

							END

	--Update the lookup with the current sync time
	Update dbo.Lookup
	Set LookupName = convert(varchar(20),@dtCurrentDateTime)
	WHERE Id = 6151


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

						set @vcemailSubject = ''ClientWise : Data Sync for Client Failed''
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
