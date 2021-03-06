IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetVendorDataToTMIMMRDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Data_SetVendorDataToTMIMMRDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetVendorDataToTMIMMRDB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
--Vendor Data Push

/*******************************************************************  
* PROCEDURE: prc_Data_SetVendorDataToTMIMMRDB
* Purpose : This PROC would be called TO perform a data push of Vendor Additions/Modifications
						from ClientWise to TMIMMRDB Database using linked server
* Invoked from : Sql job xxxxxxx
* CREATED: Ajay Thacker
* CREATED ON : 23-May-2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_Data_SetVendorDataToTMIMMRDB
**********************************************************************/ 
CREATE PROC [dbo].[prc_Data_SetVendorDataToTMIMMRDB]
AS
DECLARE 
	@dtLastClientSyncDateTime DATETIME,
	@dtCurrentDateTime DATETIME,
	@curVendorId INT,
	@curVendorCode VARCHAR(5),
	@vcVendorCode VARCHAR(3),
	@bitExists BIT,
	@curAccountRefId VARCHAR(100),
	@curAgencyDisc NUMERIC(18,3),
	@curVendorContactId INT,
	@curVendorContactName VARCHAR(100),
	@curVendorContactPhoneWork VARCHAR(50),
	@curVendorContactFax VARCHAR(50),
	@curVendorContactEmail VARCHAR(100),
	@curVendorContactNotes VARCHAR(1000),
	@curVendorContactTypeLookupId INT,
	@intMMISPaperID INT,
	@curVendorCorrespondenceLookupId INT,
	@concatEmails VARCHAR(1000),
	@intPubsCorresId INT,
	@intPubsCorrespondenceProtocolId INT
	
	
BEGIN TRY
	--Fetch when was the last time the sync for Client was performed
	SET @dtLastClientSyncDateTime = (SELECT CONVERT(DATETIME,LookupName) 
																			   FROM dbo.Lookup
																			   WHERE Id = 6152) --VendorSyncDateTimeToTmimmrdb

	SET @dtCurrentDateTime = getdate()
	
	--STEP 1 : CHECK IF THERE WERE ANY NEW VENDORS CREATED AFTER THE LAST SYNC TIME
	IF EXISTS ( SELECT Id 
							 FROM CWI_Vendor
						     WHERE CreatedOn > @dtLastClientSyncDateTime 
							  AND CreatedOn <= @dtCurrentDateTime) 
	BEGIN
			DECLARE cur_NewVendor CURSOR
			FOR
				SELECT Id,VendorCode,AccountRefId,AgencyDisc FROM CWI_Vendor WHERE CreatedOn > @dtLastClientSyncDateTime
																and CreatedOn <= @dtCurrentDateTime
			OPEN cur_NewVendor
			FETCH FROM cur_NewVendor into @curVendorId,@curVendorCode,@curAccountRefId,@curAgencyDisc
			WHILE @@FETCH_STATUS = 0
			 BEGIN
				
			
							if not exists (Select PaperCode from mmis.tmimmrdb.dbo.Papers where PaperCode = @curVendorCode)
							BEGIN
												INSERT INTO MMIS.TMIMMRDB.DBO.PAPERS
							(
								PAPERCODE,
								NAME,
								ADDR1,
								ADDR2,
								CITY,
								STCODE,
								ZIP,
								PHONE,
								FAX,
								PUBLISHINGGROUP,
								PAYCODE,
								EXTENSION,
								COMMENT,
								MEDIACLASSID,
								CLASSIFICATIONID,
								ACTIVATE,
								COUNTRYCODE,
								NumOfTransAllowedForAuth,
								DefaultTransCount,
								CWVendorID
							 )
								SELECT
								V.VendorCode,
								V.VendorName,
								A.AddressLine1,
								A.AddressLine2,
								A.City,
								(Select StateCode from [State] where ID = A.StateID),
								A.Zip,
								A.WorkPhone,
								A.WorkFax,
								(Select LookupName from Lookup where ID = V.VendorGroupLookupId),
								 case when V.PayMethodLookupId = 851 then 5 -- Invoice
											when V.PayMethodLookupId = 852 then 98 --Virtual Card''
											when V.PayMethodLookupId = 854 then 99 --Ghost Card
								end,
								A.WorkExtn,
								V.Note,
								MC.ID,
								MC.ID,
								1,
								A.CountryId,
								''004'', --NumOfTransAllowedForAuth
								4,
								V.ID
								FROM CWI_Vendor V
									inner join CWI_Address A
											on V.AddressId_Physical = A.ID
									inner join Lookup Look
											on Look.ID = V.[ClassificationLookupId]
																	and V.ID = @curVendorId
										inner join MMIS.TMIMMRDB.DBO.MediaClass MC
													on replace(Look.LookupName,''job boards'',''internet'') =MC.Classification
													and Look.ID = V.[ClassificationLookupId]
								where V.ID =@curVendorId
												INSERT INTO MMIS.TMIMMRDB.DBO.PAPER_ACTG
								(
								PAPERCODE,
								TS,
								ActgXRef
								)
								values
								(
								@curVendorCode,
								@curAccountRefId,
								@curAccountRefId
								)
												INSERT INTO MMIS.TMIMMRDB.DBO.PAPER_COST
									(
									PAPERCODE,
									AgencyDisc,
									UseEstimate
									)
									values
									(
									@curVendorCode,
									@curAgencyDisc,
									0
									)
							END

				FETCH NEXT FROM cur_NewVendor into @curVendorId,@curVendorCode,@curAccountRefId,@curAgencyDisc
			END

			CLOSE cur_NewVendor
			DEALLOCATE cur_NewVendor

	END
	
	--STEP 2 : CHECK IF THERE WERE ANY EXISTING VENDORS UPDATED AFTER THE LAST SYNC TIME
	IF EXISTS (SELECT Id FROM CWI_Vendor
						WHERE ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
	BEGIN
			DECLARE cur_ExistingVendor CURSOR
			FOR
			SELECT  Id,VendorCode,AccountRefId,AgencyDisc FROM CWI_Vendor
			 WHERE ModifiedOn > @dtLastClientSyncDateTime
								and ModifiedOn <= @dtCurrentDateTime
			OPEN cur_ExistingVendor
			FETCH FROM cur_ExistingVendor into @curVendorId,@curVendorCode,@curAccountRefId,@curAgencyDisc
			WHILE @@FETCH_STATUS = 0
			 BEGIN
						Update MMIS.TMIMMRDB.DBO.PAPERS
						Set	PAPERCODE = V.VendorCode,
							NAME = left(V.VendorName,30),
							ADDR1 = left(A.AddressLine1,30),
							ADDR2 = left(A.AddressLine2,30),
							CITY = A.City,
							STCODE = (Select StateCode from [State] where ID = A.StateID),
							ZIP = A.Zip,
							PHONE = A.WorkPhone,
							FAX = A.WorkFax,
							PUBLISHINGGROUP = (Select LookupName from Lookup where ID = V.VendorGroupLookupID),
							PAYCODE =  case when V.PayMethodLookupId = 851 then 5 -- Invoice
																when V.PayMethodLookupId = 852 then 98 --Virtual Card''
																when V.PayMethodLookupId = 854 then 99 --Ghost Card
														end,
							EXTENSION = A.WorkExtn,
							COMMENT = V.Note,
							MEDIACLASSID = MC.ID,
							CLASSIFICATIONID = MC.ID,
							COUNTRYCODE = A.CountryId

							FROM  CWI_Vendor V
											inner join CWI_Address A
													on V.AddressId_Physical = A.ID
								 inner join Lookup Look
										on Look.ID = V.[ClassificationLookupId]
												and V.ID = @curVendorId
								inner join MMIS.TMIMMRDB.DBO.MediaClass MC
										on replace(Look.LookupName,''job boards'',''internet'') =MC.Classification
											and Look.ID = V.[ClassificationLookupId]
								where PaperCode = @curVendorCode
						UPDATE MMIS.TMIMMRDB.DBO.PAPER_ACTG
								SET
									PAPERCODE = @curVendorCode,
									TS = @curAccountRefId,
									ActgXRef = @curAccountRefId
								where PaperCode = @curVendorCode	
						Update MMIS.TMIMMRDB.DBO.PAPER_COST
						Set	AgencyDisc = @curAgencyDisc
						Where PaperCode = @curVendorCode	
						FETCH NEXT FROM cur_ExistingVendor into @curVendorId,@curVendorCode,@curAccountRefId,@curAgencyDisc
			 END

			 CLOSE cur_ExistingVendor
			 DEALLOCATE cur_ExistingVendor
	END

	--STEP 3 : CHECK IF THERE WERE ANY CONTACTS ADDED OR MODIFIED AFTER THE LAST SYNC TIME
	IF EXISTS (Select Id FROM CWI_VendorContact 
							WHERE
									( CreatedOn > @dtLastClientSyncDateTime and CreatedOn <= @dtCurrentDateTime)
									OR
									( ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
							)
	BEGIN
			DECLARE cur_VendorContact CURSOR
			FOR
			SELECT Id,Name,PhoneWork,Fax,Email,Notes,ContactTypeLookupId,VendorId from CWI_VendorContact
			WHERE ( CreatedOn > @dtLastClientSyncDateTime and CreatedOn <= @dtCurrentDateTime)
									OR
							( ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
			OPEN cur_VendorContact
			FETCH FROM cur_VendorContact into @curVendorContactId,@curVendorContactName,
																								@curVendorContactPhoneWork,@curVendorContactFax,
																								@curVendorContactEmail,@curVendorContactNotes,
																								@curVendorContactTypeLookupId,@curVendorId
			WHILE @@FETCH_STATUS = 0
			 BEGIN
						IF @curVendorContactTypeLookupId = 901 --Classifieds
								Update MMIS.TMIMMRDB.DBO.PAPERS
									Set Contact = @curVendorContactName,
											Phone = @curVendorContactPhoneWork,
											Fax = @curVendorContactFax,
											Email = @curVendorContactEmail
									where PaperCode = (select VendorCode from CWI_Vendor 
																				where ID = @curVendorId)
						ELSE IF @curVendorContactTypeLookupId = 903 -- AR
									Update MMIS.TMIMMRDB.DBO.Paper_Actg
									Set ARContact = @curVendorContactName,
											ARPhone = @curVendorContactPhoneWork,
											ARFax = @curVendorContactFax,
											ARComment = @curVendorContactNotes
									where PaperCode = (select VendorCode from CWI_Vendor 
																				where ID = @curVendorId)

						FETCH NEXT FROM cur_VendorContact into @curVendorContactId,@curVendorContactName,
																								@curVendorContactPhoneWork,@curVendorContactFax,
																								@curVendorContactEmail,@curVendorContactNotes,
																								@curVendorContactTypeLookupId,@curVendorId
			 END

			 CLOSE cur_ExistingVendor
			 DEALLOCATE cur_ExistingVendor
	END

--STEP 4 : CHECK IF THERE WERE ANY VENDOR CORRESPONDENCE DELIVERY METHODS ADDED OR  MODIFIED AFTER THE LAST SYNC TIME
	IF EXISTS (Select Id FROM CWI_VendorCorrespondence 
							WHERE
									( CreatedOn > @dtLastClientSyncDateTime and CreatedOn <= @dtCurrentDateTime)
									OR
									( ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)
							)
		BEGIN
			DECLARE cur_VendorCorres CURSOR
			FOR
			SELECT distinct VendorId, CorrespondenceLookupId from CWI_VendorCorrespondence 
			WHERE
						CorrespondenceLookupId in (701,703,705,704) -- we care for only insertion,quote,cancellation or settlementreminder
						and DeliveryMethodLookupId = 803 -- we only care of APas setup
						and  (CreatedOn > @dtLastClientSyncDateTime and CreatedOn <= @dtCurrentDateTime)
									OR
							( ModifiedOn > @dtLastClientSyncDateTime and ModifiedOn <= @dtCurrentDateTime)

			OPEN cur_VendorCorres
			FETCH FROM cur_VendorContact into @curVendorId,@curVendorCorrespondenceLookupId
																								
			WHILE @@FETCH_STATUS = 0
			 BEGIN
			 			--We get Papers.ID
							set @intMMISPaperID = (select P.ID from mmis.tmimmrdb.dbo.Papers P
																							inner join CWI_Vendor V
																									on P.PaperCode =  V.VendorCode
																					where V.ID = @curVendorId				
																					)

							set @intPubsCorresId = (Select case when  @curVendorCorrespondenceLookupId = 701 then 1 --insertion
																							when @curVendorCorrespondenceLookupId = 703 then 2--quote
																							when @curVendorCorrespondenceLookupId = 705 then 3--Settlement Reminder
																							when @curVendorCorrespondenceLookupId = 704 then 4 --Cancellation
																							else 0
																				end)


 								Select @concatEmails = coalesce(@concatEmails + '';'','''') + ltrim(rtrim(Fax))
																									from CWI_VendorCorrespondence
																									where VendorID =@curVendorId
																									and CorrespondenceLookupId = @curVendorCorrespondenceLookupId 
																									and DeliveryMethodLookupId =803 -- we only care of APas setup
																									and IsActive = 1
								--check if the CorrespondenceType is Already Setup
										if exists (Select CP.ID from mmis.tmimmrdb.dbo.AWPubsCorrespondenceProtocol CP
															where CP.PubID = @intMMISPaperID
															and CP.CorrespondenceID = @intPubsCorresId)
									begin
														set @intPubsCorrespondenceProtocolId = (Select CP.ID 
																																						from mmis.tmimmrdb.dbo.AWPubsCorrespondenceProtocol CP
																																						where CP.PubID = @intMMISPaperID
																																						and CP.CorrespondenceID = @intPubsCorresId)			

														--update row in AwPubsEmailCorrespondenceEmailSchedule
														--with concatenate emails separated by semi-colon
													
														update mmis.tmimmrdb.dbo.AwPubsEmailCorrespondenceEmailSchedule
																set email = @concatEmails
														where PubsEmailCorresCode = @intPubsCorrespondenceProtocolId
														
										end
										else
											begin --Looks Like the user is setting up the email for the first time
													-- insert row into awpubsCorrespondenceprotocol
													Insert into mmis.tmimmrdb.dbo.awpubsCorrespondenceprotocol
													(
													PubId,CorrespondenceId,ProtocolType,LastModificationAuthor,LastModifiedOn
													)
													values
													(
													@intMMISPaperID,@intPubsCorresId,''E'',''ClientWise'',getdate()
													)

													set @intPubsCorrespondenceProtocolId  = (select ID
																										from  mmis.tmimmrdb.dbo.awpubsCorrespondenceprotocol
																										where PubID =@intMMISPaperID
																										and CorrespondenceID =@intPubsCorresId
																										and ProtocolType = ''E''
																										)

													insert into mmis.tmimmrdb.dbo.AwPubsEmailCorrespondenceEmailSchedule
													(
														PubsEmailCorresCode,
														Email
													)
													values
													(
													@intPubsCorrespondenceProtocolId,
													@concatEmails
													)

											end


						FETCH NEXT FROM cur_VendorContact into @curVendorId,@curVendorCorrespondenceLookupId

			 END
		END

	--Update the lookup with the current sync time
	Update dbo.Lookup
	Set LookupName = convert(varchar(20),@dtCurrentDateTime)
	WHERE Id = 6152


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

						set @vcemailSubject = ''ClientWise : Data Sync for Vendor Failed''
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
