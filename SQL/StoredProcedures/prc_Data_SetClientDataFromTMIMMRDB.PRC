/****** Object:  StoredProcedure [dbo].[prc_Data_SetClientDataFromTMIMMRDB]    Script Date: 12/2/2013 2:35:46 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetClientDataFromTMIMMRDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Data_SetClientDataFromTMIMMRDB]
GO

/****** Object:  StoredProcedure [dbo].[prc_Data_SetClientDataFromTMIMMRDB]    Script Date: 12/2/2013 2:35:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetClientDataFromTMIMMRDB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'--Client Data Pull



/*******************************************************************  

* PROCEDURE: prc_Data_SetClientDataFromTMIMMRDB

* Purpose : This PROC would be called TO perform a one time Client Data pull from PRoduction

* Invoked from : Manually

* CREATED: Ajay Thacker

* CREATED ON : 12Apr2013

* MODIFICATION HISTORY  

* DATE      AUTHOR          DESCRIPTION  

            



**********************************************************************  

Execution example :

**********************************************************************  

exec prc_Data_SetClientDataFromTMIMMRDB

**********************************************************************/ 

CREATE proc [dbo].[prc_Data_SetClientDataFromTMIMMRDB]

as





--Declare Variables

declare @bitParentCodeUsed bit,

				@bitAnyRelatedClientCodeUsed bit,

				@vcCurParentCode varchar(50),

				@intAddressID int,

				@intCountryIDUSA int,

				@intClientStatusLookupIDActive int,

				@intHierarchyTypeLookupIDClient int,

				@intHierarchyTypeLookupIDDivision int,

				@intUserIDSystem int,

				@vcDefaultDivisionCode varchar(3),

				@intClientID int,

				@intDivisionID int,

				@vcCurClientCode varchar(3),

				@intRoundToLookupIDStandard int,

				@intClientStatusLookupIDInActive int,

				@numDefMarkup numeric(5,2)













--To Avoid Unnecessary joins each time, I am fetching the values one time only

set @intCountryIDUSA = (Select ID From Country where CountryCode = ''US'')

set @intClientStatusLookupIDActive = (Select ID from Lookup where LookupTypeId = 5

																					and LookupName = ''Active'')

set @intClientStatusLookupIDInActive = (Select ID from Lookup where LookupTypeId = 5

																					and LookupName = ''InActive'')

																				

set @intHierarchyTypeLookupIDClient = (Select ID from Lookup where LookupTypeId = 6

																					and LookupName = ''Client'')

set @intHierarchyTypeLookupIDDivision = (Select ID from Lookup where LookupTypeId = 6

																					and LookupName = ''Division'')

set @intRoundToLookupIDStandard = (Select ID from Lookup where LookupTypeId = 20

																					and LookupName = ''Standard'')



--Create a System user 

if not exists (Select ID from CWI_User where Login = ''System'')

begin

			Insert into CWI_User

			(

			Login,

			Domain,

			Names,

			Email,

			IsActive,

			CreatedBy,

			CreatedOn,

			ModifiedBy,

			ModifiedOn

			)

			values

			(

			''System'',

			''oss'',

			''System'',

			''ClientWiseAdmin@xerox.com'',

			1,

			''oss\athacker'',

			getdate(),

			''oss\athacker'',

			getdate()

			)



			set @intUserIDSystem = @@IDENTITY

end

else

			set @intUserIDSystem =(Select ID from CWI_User where Login = ''System'')



BEGIN TRANSACTION Trans1

BEGIN TRY

--We Delete Existing Test Records From Dev

delete from [dbo].[CWI_History_Address]

delete from [dbo].[CWI_History_Client]

delete from [dbo].[CWI_History_ClientClassification]

delete from [dbo].[CWI_History_ClientService]

delete from [dbo].[CWI_History_ClientTeamRelationship]



Delete from CWI_ClientActivation

delete from CWI_ClientClassification

delete from CWI_ClientService

delete from CWI_ClientTearSheet

delete from CWI_ClientTeamRelationship

delete from cwi_clientContact



Delete from CWI_Address  where ID in 

(	Select AddressID from  CWI_Client C inner join CWI_Address A

			on A.ID = C.AddressID)

Delete from CWI_Client



declare curParent cursor for

			Select  ParentCd from kbcdb1.tmimmrdb.dbo.Parent P



open curParent

fetch from curParent into @vcCurParentCode

while @@FETCH_STATUS = 0

BEGIN

	print @vcCurParentCode

		

	--Check if any related Clients have been used for that Parent Code in Settlements 

		if exists (Select ID from kbcdb1.tmimmrdb.dbo.Settlements S

								inner join kbcdb1.tmimmrdb.dbo.Client C

									on S.CliCode = C.CliCode

								inner join kbcdb1.tmimmrdb.dbo.Parent P

									on P.ParentCd = C.ParentCode

								where P.ParentCd =@vcCurParentCode

									and invoicenum is not null)

			set @bitAnyRelatedClientCodeUsed = 1

		else

			set @bitAnyRelatedClientCodeUsed = 0



			--Logic Details

			--If either Parent or Client has been used, 

			

			-->Step 1a we insert Parents address into CWI_Address

			-->Step 1b we insert tmimmrdb.Parents record into ClientWiseDev.CWI_Client table as a top level ''Client''

			

			-->Step 2a We create default Division Address  for that Parent Record

			-->Step 2b We create default Division record  for that Parent Record

			-->Step 2c We possibly create TearSheet Records for that Default Divisions Record



			-->Step 3a We create other Division(s) Address for that Parent Record

			-->Step 3b We create other Division(s) Records for that Parent Record

			-->Step 3c We Create TearSheet Records for that Division''s Records

			-->Step 3d We insert Media Class Markup into CWI_ClientClassification

			

			-->Step 4a We Create Other Division(s) Address for those Divisions that do not have any Parent

			-->Step4b We Create Other Division(s) Record for those Divisions that do not have any Parent

			-->Step4c We Create TearSheet Records for that Division''s Records

			-->Step4d We insert Media Class Markup into CWI_ClientClassification



			if  @bitAnyRelatedClientCodeUsed = 1

			BEGIN



						--1a Top Level Client''s Address

						Insert into CWI_Address

						(

						AddressLine1,

						AddressLine2,

						CountryID,

						StateID,

						City,

						Zip,

						WorkPhone,

						WorkExtn,

						WorkFax,

						CreatedBy,

						CreatedOn)

						Select 

							isnull(P.BillAddr1,''''),

							P.BillAddr2,

							@intCountryIDUSA,

							(Select ID from dbo.[State] where StateCode = P.BillStCode),

							isnull(P.BillCity,''''),

							isnull(P.BillZip,''''),

							replace(P.Phone,''-'',''''),

							P.PhoneExt,

							replace(P.Fax,''-'',''''),

							@intUserIDSystem,

							getdate()

							From  kbcdb1.tmimmrdb.dbo.Parent P

							where P.ParentCd = @vcCurParentCode

							

						set @intAddressID = @@IDENTITY



						--1b Top level Client

						insert into CWI_Client

						(

						AddressID,

						ParentID,

						ClientStatusLookupID,

						HierarchyTypeLookupID,

						MarkupPct,

						ActgXref,

						IsPOReqd,

						ClientCode,

						ClientName,

						LastStatusModifiedBy,

						LastStatusModifiedOn,

						CreatedBy,

						CreatedOn

						)

						Select

						@intAddressID,

						null, --this is a top level Client

						@intClientStatusLookupIDActive,

						@intHierarchyTypeLookupIDClient,

						null, --this is a top level Client, we never invoice at this level, markuppct is not applicable

						P.ActgXRef,

						null, --this is a top level Client, we never invoice at this level, IsPoReqd is not applicable

						P.ParentCd,

						P.CompanyName,

						@intUserIDSystem,

						getdate(),

						@intUserIDSystem,

						getdate()

						from kbcdb1.tmimmrdb.dbo.Parent P

						where P.ParentCd = @vcCurParentCode



						set @intClientID = @@IDENTITY



						insert into CWI_ClientContact

						(

						ClientID,

						Name,

						ContactTypeLookupId,

						Email,

						PhoneWork,

						PhoneOther,

						Fax,

						CreatedBy,

						CreatedOn,

						ModifiedBy,

						ModifiedOn

						)

						Select 

						@intClientID,

						isnull(C.ordercontact,''''),

						6101, --recruiter

						isnull(C.[E-Mail],''''),

						isnull(C.Phone1,''''),

						isnull(C.Phone2,''''),

						isnull(C.Fax1,''''),

						@intUserIDSystem,

						getdate(),

						@intUserIDSystem,

						getdate()

						from kbcdb1.tmimmrdb.dbo.Client C

								Where  C.CliCode = @vcCurParentCode













					

						/*

						-- 2a and 2b If there is a Default Division for this Parent then Create Division record

						if exists (select C.CliCode from kbcdb1.tmimmrdb.dbo.Parent P

												inner join kbcdb1.tmimmrdb.dbo.Client C

												on P.ParentCd = C.CliCode

											where  P.ParentCd = @vcCurParentCode

											)

						BEGIN



								--2a Create Address For Default Division from kbc''s Client Table

								Insert into CWI_Address

								(

								AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

								CreatedBy,

								CreatedOn)

								Select 

									isnull(C.BillAddr1,''''),

									C.BillAddr2,

									@intCountryIDUSA,

									(Select ID from dbo.[State] where StateCode = C.BillStCode),

									isnull(C.BillCity,''''),

									isnull(C.BillZip,''''),

									C.Phone1,

									C.PhoneExt1,

									C.Fax1,

									@intUserIDSystem,

									getdate()

									From   kbcdb1.tmimmrdb.dbo.Parent P

														inner join kbcdb1.tmimmrdb.dbo.Client C

														on P.ParentCd = C.CliCode

													where  P.ParentCd = @vcCurParentCode

							

								set @intAddressID = @@IDENTITY



								--2b Create Default Division from kbc''s Client Table

								insert into CWI_Client

								(

								AddressID,

								ParentID,

								ClientStatusLookupID,

								HierarchyTypeLookupID,

								MarkupPct,

								ActgXref,

								IsPOReqd,

								ClientCode,

								ClientName,

								LastStatusModifiedBy,

								LastStatusModifiedOn,

								CreatedBy,

								CreatedOn

								)

								Select

								@intAddressID,

								@intClientID,

								@intClientStatusLookupIDActive,

								@intHierarchyTypeLookupIDDivision,

								C.MarkupPct,

								C.ActgXRef,

								PoReq,

								C.CliCode,

								C.ClientName,

								@intUserIDSystem,

								getdate(),

								@intUserIDSystem,

								getdate()

								from  kbcdb1.tmimmrdb.dbo.Parent P

														inner join kbcdb1.tmimmrdb.dbo.Client C

														on P.ParentCd = C.CliCode

													where  P.ParentCd = @vcCurParentCode



								set @intDivisionID = @@IDENTITY



								--2c Create TearSheet Address

								if exists (Select C.CliCode From kbcdb1.tmimmrdb.dbo.Parent P

														inner join kbcdb1.tmimmrdb.dbo.Client C

														on P.ParentCd = C.CliCode

													where  P.ParentCd = @vcCurParentCode

														and  TearContact is not null and  TearAddr1 is not null)

								begin

										

											Insert into CWI_Address

								(

								AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

								CreatedBy,

								CreatedOn)

								Select 

									isnull(C.TearAddr1,''''),

									C.TearAddr2,

									@intCountryIDUSA,

									(Select ID from dbo.[State] where StateCode = C.TearStCode),

									isnull(C.TearCity,''''),

									isnull(C.TearZip,''''),

									null,

									null,

									null,

									@intUserIDSystem,

									getdate()

									from  kbcdb1.tmimmrdb.dbo.Parent P

														inner join kbcdb1.tmimmrdb.dbo.Client C

														on P.ParentCd = C.CliCode

													where  P.ParentCd = @vcCurParentCode

									and  TearContact is not null and  TearAddr1 is not null

							

											set @intAddressID = @@IDENTITY

											

											insert into CWI_ClientTearSheet

								(

								ClientId,

								AddressId,

								TearName,

								TearContact,

								CreatedBy,

								CreatedOn,

								ModifiedBy,

								ModifiedOn

								)

								Select 

								@intDivisionID,

								@intAddressID,

								isnull(C.TearName,''''),

								isnull(C.TearContact,''''),

								@intUserIDSystem,

								getdate(),

								@intUserIDSystem,

								getdate()

								From kbcdb1.tmimmrdb.dbo.Client C

									Where  C.CliCode = @vcCurClientCode

								end



						END

						ELSE --2a and 2b There was no default Division in TMIMMRDB, so create a Default Division same as Client rec

						BEGIN 

								

								--2a Default Division Address

								Insert into CWI_Address

								(

								AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

								CreatedBy,

								CreatedOn)

								Select 

									AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

									CreatedBy,

									getdate()

									From CWI_Address

									where ID = @intAddressID

							

								set @intAddressID = @@IDENTITY

						



								--2b Create Default Division same as Client rec

								insert into CWI_Client

								(

								AddressID,

								ParentID,

								ClientStatusLookupID,

								HierarchyTypeLookupID,

								MarkupPct,

								ActgXref,

								IsPOReqd,

								ClientCode,

								ClientName,

								LastStatusModifiedBy,

								LastStatusModifiedOn,

								CreatedBy,

								CreatedOn

								)

								Select

								@intAddressID,

								@intClientID,

								@intClientStatusLookupIDActive,

								@intHierarchyTypeLookupIDDivision,

								null, --since there was no default division in tmimmrdb, so we do not know the Markup

								null, --since there was no default division in tmimmrdb, so we do not know the ActgXref

								null, --since there was no default division in tmimmrdb, so we do not know the IsPOReqd

								ClientCode,

								ClientName,

								LastStatusModifiedBy,

								getdate(),

								CreatedBy,

								getdate()

								from CWI_Client

								where ID = @intClientID





								set @intDivisionID = @@IDENTITY

						End



						*/

						--3a and 3b Create Other Divisions Address and Division Record along with

						

						declare curDivision cursor for

						Select distinct C.CliCode from  kbcdb1.tmimmrdb.dbo.Client C

									inner join  kbcdb1.tmimmrdb.dbo.Parent P

										on C.ParentCode = P.ParentCd

									inner join kbcdb1.tmimmrdb.dbo.Settlements S

											on S.CliCode = C.CliCode

									where P.ParentCd = @vcCurParentCode

									and S.Invoicenum is not null

									--and C.CliCode != @vcCurParentCode --ignore default division



					open curDivision

					Fetch from curDivision into @vcCurClientCode

					while @@FETCH_STATUS = 0

						BEGIN

							

							--3a Create Address For Division from kbc''s Client Table

								Insert into CWI_Address

								(

								AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

								CreatedBy,

								CreatedOn)

								Select 

									isnull(C.BillAddr1,''''),

									C.BillAddr2,

									@intCountryIDUSA,

									(Select ID from dbo.[State] where StateCode = C.BillStCode),

									isnull(C.BillCity,''''),

									isnull(C.BillZip,''''),

									replace(C.Phone1,''-'',''''),

									C.PhoneExt1,

									replace(C.Fax1,''-'',''''),

									@intUserIDSystem,

									getdate()

									From  kbcdb1.tmimmrdb.dbo.Client C

									Where  C.CliCode = @vcCurClientCode

							

								set @intAddressID = @@IDENTITY



								--3b Create Default Division from kbc''s Client Table

								insert into CWI_Client

								(

								AddressID,

								ParentID,

								ClientStatusLookupID,

								HierarchyTypeLookupID,

								MarkupPct,

								ActgXref,

								IsPOReqd,

								ClientCode,

								ClientName,

								LastStatusModifiedBy,

								LastStatusModifiedOn,

								CreatedBy,

								CreatedOn

								)

								Select

								@intAddressID,

								@intClientID,

								case when C.Active = 1 then @intClientStatusLookupIDActive

											else @intClientStatusLookupIDInActive

											end

								,

								@intHierarchyTypeLookupIDDivision,

						case when C.MarkupPct is null then null

											when C.MarkupPct < 1 then C.MarkupPct * 100

											else C.MarkupPct

											end

								,

								C.ActgXRef,

								PoReq,

								C.CliCode,

								C.ClientName,

								@intUserIDSystem,

								getdate(),

								@intUserIDSystem,

								getdate()

								from kbcdb1.tmimmrdb.dbo.Client C

								Where  C.CliCode = @vcCurClientCode



								set @intDivisionID = @@IDENTITY



								insert into CWI_ClientContact

						(

						ClientID,

						Name,

						ContactTypeLookupId,

						Email,

						PhoneWork,

						PhoneOther,

						Fax,

						CreatedBy,

						CreatedOn,

						ModifiedBy,

						ModifiedOn

						)

						Select 

						@intDivisionID,

						isnull(C.ordercontact,''''),

						6101, --recruiter

						isnull(C.[E-Mail],''''),

						isnull(C.Phone1,''''),

						isnull(C.Phone2,''''),

						isnull(C.Fax1,''''),

						@intUserIDSystem,

						getdate(),

						@intUserIDSystem,

						getdate()

						from kbcdb1.tmimmrdb.dbo.Client C

								Where  C.CliCode =@vcCurClientCode



									set @numDefMarkup = (Select MarkupPct from CWI_Client where ID = @intDivisionID)



									--3c Create TearSheet Address

								if exists (Select C.CliCode From  kbcdb1.tmimmrdb.dbo.Client C

													Where  C.CliCode = @vcCurClientCode

														and  TearContact is not null and  TearAddr1 is not null)

								begin

										

											Insert into CWI_Address

								(

								AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

								CreatedBy,

								CreatedOn)

								Select 

									isnull(C.TearAddr1,''''),

									C.TearAddr2,

									@intCountryIDUSA,

									(Select ID from dbo.[State] where StateCode = Coalesce(C.TearStCode,C.BillSTCode)),

									isnull(C.TearCity,''''),

									isnull(C.TearZip,''''),

									null,

									null,

									null,

									@intUserIDSystem,

									getdate()

									From  kbcdb1.tmimmrdb.dbo.Client C

									Where  C.CliCode = @vcCurClientCode

									and  TearContact is not null and  TearAddr1 is not null

							

											set @intAddressID = @@IDENTITY

											

											insert into CWI_ClientTearSheet

								(

								ClientId,

								AddressId,

								TearName,

								TearContact,

								CreatedBy,

								CreatedOn,

								ModifiedBy,

								ModifiedOn

								)

								Select 

								@intDivisionID,

								@intAddressID,

								isnull(C.TearName,''''),

								isnull(C.TearContact,''''),

								@intUserIDSystem,

								getdate(),

								@intUserIDSystem,

								getdate()

								From kbcdb1.tmimmrdb.dbo.Client C

									Where  C.CliCode = @vcCurClientCode

								end



								--3d  Media Class Markup



									--First we insert all media classifications with the default markup percentage

									Insert Into CWI_ClientClassification

									(

									ClientID,

									ClassificationLookupID,

									MarkupPct,

									RoundToLookupID,

									CreatedBy,

									CreatedOn

									)

									Select 

									@intDivisionID,

									Look.ID,

									@numDefMarkup,

									@intRoundToLookupIDStandard,

									@intUserIDSystem,

									getdate()

									from dbo.Lookup Look

									where Look.LookupTypeID = 3







									--Next we update those media class default percentage that exist in tmimmrdb

									update CWI_ClientClassification

									set MarkupPct =case when MCM.MarkupPercent is null then null

											when MCM.MarkupPercent < 1 then MCM.MarkupPercent * 100

											else MCM.MarkupPercent

											end

									From CWI_Client CWIC

										inner join kbcdb1.tmimmrdb.dbo.Client C

											on CWIC.ClientCode = C.CliCode

									inner join kbcdb1.tmimmrdb.dbo.MediaClassMarkup MCM

											on C.CliCode = MCM.CliCode

										inner join  kbcdb1.tmimmrdb.dbo.MediaClass MC

											on MCM.MediaClassID = MC.ID

										inner join dbo.Lookup Look

											on Look.LookupName = MC.Classification

													and Look.LookupTypeID = 3

									inner join CWI_ClientClassification CC

													on CWIC.ID = CC.ClientID

													and CC.ClassificationLookupID = Look.ID



									where CWIC.ID = @intDivisionID

																	



							Fetch next  from curDivision into @vcCurClientCode

					END

					close curDivision

					deallocate curDivision

					



			END



	fetch next from curParent into @vcCurParentCode

END



close curParent

deallocate curParent



	--4a and 45b Create Other Divisions (Orphans with no parent) Address and Division Record and

							

						declare curDivisionOrphans cursor for

						Select distinct C.CliCode from  kbcdb1.tmimmrdb.dbo.Client C

									inner join kbcdb1.tmimmrdb.dbo.Settlements S

										on S.CliCode = C.CliCode

									where C.ParentCode  is null

									and S.Invoicenum is not null

									



					open curDivisionOrphans

					Fetch from curDivisionOrphans into @vcCurClientCode

					while @@FETCH_STATUS = 0

						BEGIN

						--4a Create Other Division (Orphans with no parent) address for PArent REcord

							Insert into CWI_Address

								(

								AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

								CreatedBy,

								CreatedOn)

								Select 

									isnull(C.BillAddr1,''''),

									C.BillAddr2,

									@intCountryIDUSA,

									(Select ID from dbo.[State] where StateCode = C.BillStCode),

									isnull(C.BillCity,''''),

									isnull(C.BillZip,''''),

									replace(C.Phone1,''-'',''''),

									C.PhoneExt1,

									replace(C.Fax1,''-'',''''),

									@intUserIDSystem,

									getdate()

									From  kbcdb1.tmimmrdb.dbo.Client C

									Where  C.CliCode = @vcCurClientCode



									set @intAddressID = @@IDENTITY



									--4b Create Other Division (Orphans with no parent) record for Parent Record

										insert into CWI_Client

										(

										AddressID,

										ParentID,

										ClientStatusLookupID,

										HierarchyTypeLookupID,

										MarkupPct,

										ActgXref,

										IsPOReqd,

										ClientCode,

										ClientName,

										LastStatusModifiedBy,

										LastStatusModifiedOn,

										CreatedBy,

										CreatedOn

										)

										Select

										@intAddressID,

										null,

										case when C.Active = 1 then @intClientStatusLookupIDActive

											else @intClientStatusLookupIDInActive

											end

										,

										@intHierarchyTypeLookupIDClient,

										null, --this is a top level Client, we never invoice at this level, markuppct is not applicable

										C.ActgXRef,

										null, --this is a top level Client, we never invoice at this level, IsPoReqd is not applicable

										c.CliCode,

										C.ClientName,

										@intUserIDSystem,

										getdate(),

										@intUserIDSystem,

										getdate()

										from kbcdb1.tmimmrdb.dbo.Client C

										where C.CliCode = @vcCurClientCode



										set @intClientID = @@IDENTITY



												insert into CWI_ClientContact

												(

												ClientID,

												Name,

												ContactTypeLookupId,

												Email,

												PhoneWork,

												PhoneOther,

												Fax,

												CreatedBy,

												CreatedOn,

												ModifiedBy,

												ModifiedOn

												)

												Select 

												@intClientID,

												isnull(C.ordercontact,''''),

												6101, --recruiter

												isnull(C.[E-Mail],''''),

												isnull(C.Phone1,''''),

												isnull(C.Phone2,''''),

												isnull(C.Fax1,''''),

												@intUserIDSystem,

												getdate(),

												@intUserIDSystem,

												getdate()

												from kbcdb1.tmimmrdb.dbo.Client C

														Where  C.CliCode =@vcCurClientCode





							--Create Address For Default Division 

								Insert into CWI_Address

								(

								AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

								CreatedBy,

								CreatedOn)

								Select 

									AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								replace(WorkPhone,''-'',''''),

								WorkExtn,

								replace(WorkFax,''-'',''''),

									CreatedBy,

									getdate()

									From CWI_Address

									where ID = @intAddressID



								set @intAddressID = @@IDENTITY



								--Create Default Division for that Client

								insert into CWI_Client

								(

								AddressID,

								ParentID,

								ClientStatusLookupID,

								HierarchyTypeLookupID,

								MarkupPct,

								ActgXref,

								IsPOReqd,

								ClientCode,

								ClientName,

								LastStatusModifiedBy,

								LastStatusModifiedOn,

								CreatedBy,

								CreatedOn

								)

								Select

								@intAddressID,

								@intClientID,

									case when C.Active = 1 then @intClientStatusLookupIDActive

											else @intClientStatusLookupIDInActive

											end,

								@intHierarchyTypeLookupIDDivision,

							case when C.MarkupPct is null then null

											when C.MarkupPct < 1 then C.MarkupPct * 100

											else C.MarkupPct

											end,

								C.ActgXRef,

								PoReq,

								C.CliCode,

								C.ClientName,

								@intUserIDSystem,

								getdate(),

								@intUserIDSystem,

								getdate()

								from kbcdb1.tmimmrdb.dbo.Client C

								Where  C.CliCode = @vcCurClientCode



								set @intDivisionID = @@IDENTITY



									insert into CWI_ClientContact

												(

												ClientID,

												Name,

												ContactTypeLookupId,

												Email,

												PhoneWork,

												PhoneOther,

												Fax,

												CreatedBy,

												CreatedOn,

												ModifiedBy,

												ModifiedOn

												)

												Select 

												@intDivisionID,

												isnull(C.ordercontact,''''),

												6101, --recruiter

												isnull(C.[E-Mail],''''),

												isnull(C.Phone1,''''),

												isnull(C.Phone2,''''),

												isnull(C.Fax1,''''),

												@intUserIDSystem,

												getdate(),

												@intUserIDSystem,

												getdate()

												from kbcdb1.tmimmrdb.dbo.Client C

														Where  C.CliCode =@vcCurClientCode



								set @numDefMarkup = (Select MarkupPct from CWI_Client where ID = @intDivisionID)



								--4c Create TearSheet Address

								if exists (Select C.CliCode From  kbcdb1.tmimmrdb.dbo.Client C

													Where  C.CliCode = @vcCurClientCode

														and  TearContact is not null and  TearAddr1 is not null)

								begin

										

											Insert into CWI_Address

								(

								AddressLine1,

								AddressLine2,

								CountryID,

								StateID,

								City,

								Zip,

								WorkPhone,

								WorkExtn,

								WorkFax,

								CreatedBy,

								CreatedOn)

								Select 

									isnull(C.TearAddr1,''''),

									C.TearAddr2,

									@intCountryIDUSA,

									(Select ID from dbo.[State] where StateCode = coalesce(C.TearStCode,C.BillSTCode)),

									isnull(C.TearCity,''''),

									isnull(C.TearZip,''''),

									null,

									null,

									null,

									@intUserIDSystem,

									getdate()

									From  kbcdb1.tmimmrdb.dbo.Client C

									Where  C.CliCode = @vcCurClientCode

									and  TearContact is not null and  TearAddr1 is not null

							

											set @intAddressID = @@IDENTITY

											

											insert into CWI_ClientTearSheet

								(

								ClientId,

								AddressId,

								TearName,

								TearContact,

								CreatedBy,

								CreatedOn,

								ModifiedBy,

								ModifiedOn

								)

								Select 

								@intDivisionID,

								@intAddressID,

								isnull(C.TearName,''''),

								isnull(C.TearContact,''''),

								@intUserIDSystem,

								getdate(),

								@intUserIDSystem,

								getdate()

								From kbcdb1.tmimmrdb.dbo.Client C

									Where  C.CliCode = @vcCurClientCode

								end



								--4d Media Class Markup

									--First we insert all media classifications with the default markup percentage

									Insert Into CWI_ClientClassification

									(

									ClientID,

									ClassificationLookupID,

									MarkupPct,

									RoundToLookupID,

									CreatedBy,

									CreatedOn

									)

									Select 

									@intDivisionID,

									Look.ID,

									@numDefMarkup,

									@intRoundToLookupIDStandard,

									@intUserIDSystem,

									getdate()

									from dbo.Lookup Look

									where Look.LookupTypeID = 3







									--Next we update those media class default percentage that exist in tmimmrdb

									update CWI_ClientClassification

									set MarkupPct =case when MCM.MarkupPercent is null then null

											when MCM.MarkupPercent < 1 then MCM.MarkupPercent * 100

											else MCM.MarkupPercent

											end

									From CWI_Client CWIC

										inner join kbcdb1.tmimmrdb.dbo.Client C

											on CWIC.ClientCode = C.CliCode

									inner join kbcdb1.tmimmrdb.dbo.MediaClassMarkup MCM

											on C.CliCode = MCM.CliCode

										inner join  kbcdb1.tmimmrdb.dbo.MediaClass MC

											on MCM.MediaClassID = MC.ID

										inner join dbo.Lookup Look

											on Look.LookupName = MC.Classification

													and Look.LookupTypeID = 3

										inner join CWI_ClientClassification CC

													on CWIC.ID = CC.ClientID

													and CC.ClassificationLookupID = Look.ID



									where CWIC.ID = @intDivisionID



							Fetch next  from curDivisionOrphans into @vcCurClientCode

					END

					close curDivisionOrphans

					deallocate curDivisionOrphans



					update CWI_Client Set ClientCode = upper(ClientCode)



END TRY

	BEGIN CATCH	

	IF @@TRANCOUNT >0 

			ROLLBACK TRANSACTION Trans1;

			print ''rolling back''

		EXEC prc_CWI_AppRaiseError;

		THROW;   		

	END CATCH

	IF @@TRANCOUNT > 0

		COMMIT TRANSACTION Trans1;' 
END
GO


