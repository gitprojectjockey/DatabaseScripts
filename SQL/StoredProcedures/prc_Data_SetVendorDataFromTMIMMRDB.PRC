/****** Object:  StoredProcedure [dbo].[prc_Data_SetVendorDataFromTMIMMRDB]    Script Date: 10/13/2014 5:48:28 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetVendorDataFromTMIMMRDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Data_SetVendorDataFromTMIMMRDB]
GO

/****** Object:  StoredProcedure [dbo].[prc_Data_SetVendorDataFromTMIMMRDB]    Script Date: 10/13/2014 5:48:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Data_SetVendorDataFromTMIMMRDB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'--Vendor Data Pull

/*******************************************************************  
* PROCEDURE: prc_Data_SetVendorDataFromTMIMMRDB
* Purpose : This PROC would be called TO perform a one time Vendor Data pull from PRoduction
* Invoked from : Manually
* CREATED: Ajay Thacker
* CREATED ON : 15Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_Data_SetVendorDataFromTMIMMRDB
**********************************************************************/ 
CREATE proc [dbo].[prc_Data_SetVendorDataFromTMIMMRDB]
as

--Declare Variables
declare @bitVendorCodeUsed bit,
				@intBillingAddressID int,
				@intPhysicalAddressID int,
				@intCountryIDUSA int,
				@intUserIDSystem int,
				@vcCurPaperCode varchar(5),
				@intVendorGroupLookupID_AmericanGraphics int,
				@intVendorGroupLookupID_Ramp int,
				@intVendorGroupLookupID_Randall int,
				@intVendorGroupLookupID_Target int,
				@intVendorStatusLookupID_Active int,
				@intVendorStatusLookupID_Inactive int,
				@intPaymethodLookupID_GhostCard int,
				@intPaymethodLookupID_Invoice  int,
				@intPaymethodLookupID_VirtualCard int,
				@dtLastUsed datetime,
				@intVendorID int,
				@intVendorCorrespondenceLookupID_Insertion int,
				@intVendorCorrespondenceLookupID_Quote int,
				@intVendorCorrespondenceLookupID_SettlementReminder int,
				@intVendorCorrespondenceLookupID_Cancellation int,
				@vcFax varchar(50),
				 @intcurCorrespondenceID int,
				 @vccurProtocolType varchar(1),
				@vccurEmail varchar(500)




--To Avoid Unnecessary joins each time, I am fetching the values one time only
set @intCountryIDUSA = (Select ID From Country where CountryCode = ''US'')
set @intVendorGroupLookupID_AmericanGraphics = (Select ID from Lookup where LookupTypeId = 9
																					and LookupName = ''American Graphics Group'')
set @intVendorGroupLookupID_Ramp = (Select ID from Lookup where LookupTypeId = 9
																					and LookupName = ''Ramp'')
set @intVendorGroupLookupID_Randall = (Select ID from Lookup where LookupTypeId = 9
																					and LookupName = ''Randall Publishing'')
set @intVendorGroupLookupID_Target = (Select ID from Lookup where LookupTypeId = 9
																					and LookupName = ''Target Media Group'')
set @intVendorStatusLookupID_Active = (Select ID from Lookup where LookupTypeId = 8
																					and LookupName = ''Active'')
set @intVendorStatusLookupID_InActive = (Select ID from Lookup where LookupTypeId = 8
																					and LookupName = ''Inactive'')

set @intPaymethodLookupID_GhostCard = (Select ID from Lookup where LookupTypeId = 15
																					and LookupName = ''Ghost Card'')
set @intPaymethodLookupID_Invoice = (Select ID from Lookup where LookupTypeId = 15
																					and LookupName = ''Invoice'')
set @intPaymethodLookupID_VirtualCard = (Select ID from Lookup where LookupTypeId = 15
																					and LookupName = ''Virtual Card'')
set @intVendorCorrespondenceLookupID_Insertion = 701 /* Insertion Order */
set @intVendorCorrespondenceLookupID_Quote = 703 /* Quote Request */
set @intVendorCorrespondenceLookupID_SettlementReminder = 705 /*Settlement Reminder */
set @intVendorCorrespondenceLookupID_Cancellation = 704 /*Cancellation */



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
delete from CWI_VendorProduct
delete from CWI_VendorContact
delete from CWI_VendorCorrespondence
delete from CWI_Vendor

create table #tmpEmail
(
Email varchar(max)
)

--cursor for Vendors from tmimmrdb
declare curVendor cursor for
	Select distinct P.PaperCode from kbcdb1.tmimmrdb.dbo.Papers P
			inner join kbcdb1.tmimmrdb.dbo.Settlements S
					on P.PaperCode = S.PaperCode
			inner join  kbcdb1.tmimmrdb.dbo.Classification C
											on  P.ClassificationID = C.ID 
				inner join dbo.Lookup Look
											on Look.LookupName = C.ClassificationName
													and Look.LookupTypeID = 3
		where P.PaperCode not in (''CAAIL'',
																''SCHIL'',
																''WRNGA''
																) --these papers do not have paper actg or cost info setup on kbc

		open curVendor

		fetch from curVendor into @vcCurPaperCode

		while @@FETCH_STATUS = 0
		BEGIN
			print @vcCurPaperCode

			--Step 1a - Vendor Billing Address
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
							isnull(P.Addr1,''''),
							P.Addr2,
							@intCountryIDUSA,
							case when right(P.PaperCode,2) in (''ST'',''DM'',''NP'',''P1'',''P2'') then
										(Select ID from dbo.[State] where StateCode = ''TN'')
							else
									(Select ID from dbo.[State] where StateCode = P.StCode)
							end,

							isnull(P.City,''''),
							isnull(P.Zip,''''),
							P.Phone,
							P.Extension,
							P.Fax,
							@intUserIDSystem,
							getdate()
							From  kbcdb1.tmimmrdb.dbo.Papers P
							where P.PaperCode = @vcCurPaperCode
							
						set @intBillingAddressID = @@IDENTITY

			---Step 1b - Vendor Physical Address
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
							isnull(P.Addr1,''''),
							P.Addr2,
							@intCountryIDUSA,
							case when right(P.PaperCode,2) in (''ST'',''DM'',''NP'',''P1'',''P2'') then
										(Select ID from dbo.[State] where StateCode = ''TN'')
							else
									(Select ID from dbo.[State] where StateCode = P.StCode)
							end,
							isnull(P.City,''''),
							isnull(P.Zip,''''),
							P.Phone,
							P.Extension,
							P.Fax,
							@intUserIDSystem,
							getdate()
							From  kbcdb1.tmimmrdb.dbo.Papers P
							where P.PaperCode = @vcCurPaperCode
							
						set @intPhysicalAddressID = @@IDENTITY

						set @vcFax = (select isnull(WorkFax,'''') from cwi_address
														where id = @intPhysicalAddressID)


			--Step 1c Insert into CWI_Vendor

			--Last USed
			set @dtLastUsed = (select max(weekending) from  kbcdb1.tmimmrdb.dbo.Settlements sett where Papercode = @vcCurPaperCode)

			Insert into CWI_Vendor
			(
			VendorCode,
			VendorName,
			VendorTypeLookUpId,
			AddressId_Billing,
			AddressId_Physical,
			VendorGroupLookupId,
			VendorURL,
			ClassificationLookupId,
			Note,
			StatusLookupId,
			IsDeleted,
			Circulation,
			SundayCirculation,
			MediaKitURL,
			AgencyDisc,
			AccountRefID,
			PayMethodLookupId,
			LastUsedOn,
			CreatedBy,
			CreatedOn,
			ModifiedBy,
			ModifiedOn
			)
			Select 
				@vcCurPaperCode,
				P.[Name],
				null,--VendorTypeLookUpId will be null
				@intBillingAddressID,
				@intPhysicalAddressID,
				case
						when mp.Name = ''American Graphics Group'' then @intVendorGroupLookupID_Ramp 
						when mp.Name = ''Ramp'' then @intVendorGroupLookupID_Ramp
						 when mp.Name = ''Randall Publishing'' then @intVendorGroupLookupID_Randall
						 when mp.Name = ''Target Media Group'' then @intVendorGroupLookupID_Target
						  else null
				end,
				'''', --Vendor URL
				Look.ID, --[ClassificationLookupId]
				convert(varchar(max),p.comment) , --Note
				case when Activate = 1 then @intVendorStatusLookupID_Active
							else @intVendorStatusLookupID_Inactive
				end,
				0, --IsDeleted
				P.Circulation,
				P.SunCirrc,
				null,--MediaKitURL
				pc.AgencyDisc,
				pa.TS, --AccountRefID
				case when P.PayCode in (4,5,15) then @intPaymethodLookupID_Invoice
							when P.PayCode = 98 then @intPaymethodLookupID_VirtualCard
							when P.Paycode = 99 then @intPaymethodLookupID_GhostCard
				end,
				@dtLastUsed,
				@intUserIDSystem,
				getdate(),
				@intUserIDSystem,
				getdate()
				from kbcdb1.tmimmrdb.dbo.Papers P
						inner join  kbcdb1.tmimmrdb.dbo.Classification C
											on  P.ClassificationID = C.ID 
						inner join  kbcdb1.tmimmrdb.dbo.paper_cost pc
											on p.papercode = pc.papercode
						left join kbcdb1.tmimmrdb.dbo.MediaPartner mp
												on p.MediaPartnerID = mp.ID
						inner join  kbcdb1.tmimmrdb.dbo.paper_actg pa
											on p.papercode = pa.papercode
										inner join dbo.Lookup Look
											on Look.LookupName = C.ClassificationName
													and Look.LookupTypeID = 3
				where P.PaperCode = @vcCurPaperCode

				set @intVendorID = @@IDENTITY


				--Vendor Contact
				insert into CWI_VendorContact
				(
				VendorId,
				Name,
				ContactTypeLookupId,
				Title,
				Address,
				Email,
				PhoneWork,
				PhoneCell,
				PhoneOther,
				Fax,
				DOB,
				Interests,
				Notes,
				IsDeleted,
				CreatedBy,
				CreatedOn,
				ModifiedBy,
				ModifiedOn
				)
				Select
				@intVendorID,
				isnull(P.Contact,''''),
				901, --Classifieds,
				null,--title
				null,--address
				isnull(P.Email,''''),
				isnull(P.Phone,''''),
				null,
				null,
				P.Fax,
				null,
				null,
				null,
				0,
				@intUserIDSystem,
				getdate(),
				@intUserIDSystem,
				getdate()
				From  kbcdb1.tmimmrdb.dbo.Papers P
				where P.PaperCode = @vcCurPaperCode

				

				insert into CWI_VendorContact
				(
				VendorId,
				Name,
				ContactTypeLookupId,
				Title,
				Address,
				Email,
				PhoneWork,
				PhoneCell,
				PhoneOther,
				Fax,
				DOB,
				Interests,
				Notes,
				IsDeleted,
				CreatedBy,
				CreatedOn,
				ModifiedBy,
				ModifiedOn
				)
				Select
				@intVendorID,
				isnull(PA.ARContact,''''),
				903, --AR,
				null,--title
				null,--address
				'''',--email
				isnull(PA.ARPhone,''''),
				null,
				null,
				PA.ARFax,
				null,
				null,
				null,
				0,
				@intUserIDSystem,
				getdate(),
				@intUserIDSystem,
				getdate()
				From  kbcdb1.tmimmrdb.dbo.Papers P
					inner join kbcdb1.tmimmrdb.dbo.Paper_Actg PA
						on P.PaperCode = PA.PaperCode
				where P.PaperCode = @vcCurPaperCode



			--Step 1d - Vendor Delivery
			--PENDING
			declare curPubsCorrespondence cursor
			for
			Select 
				case when CP.CorrespondenceID = 1 then @intVendorCorrespondenceLookupID_Insertion
							when CP.CorrespondenceID = 2 then @intVendorCorrespondenceLookupID_Quote
							when CP.CorrespondenceID = 3 then @intVendorCorrespondenceLookupID_SettlementReminder
							when CP.CorrespondenceID = 4 then @intVendorCorrespondenceLookupID_Cancellation
				end as CorrespondenceLookupID,
				CP.ProtocolType,
				E.Email
				from kbcdb1.tmimmrdb.dbo.Papers P
				inner join kbcdb1.tmimmrdb.dbo.AWPubsCorrespondenceprotocol CP
				on P.ID = CP.PubID
				left join kbcdb1.tmimmrdb.dbo.AwPubsEmailCorrespondenceEmailSchedule E
				on E.PubsEmailCorresCode = CP.ID
				where P.Papercode = @vcCurPaperCode

				open curPubsCorrespondence
				Fetch from curPubsCorrespondence into @intcurCorrespondenceID,@vccurProtocolType,
																								@vccurEmail

				while @@FETCH_STATUS = 0
				begin
				DECLARE @vendorCorresId int = NULL
				
				if @vccurProtocolType = ''E''  or @vccurProtocolType = ''B'' 
				begin
					 
					 
					SELECT top 1 @vendorCorresId = Id FROM CWI_VendorCorrespondence WHERE VendorId = @intVendorID 
						and  CorrespondenceLookupId =@intcurCorrespondenceID
						and DeliveryMethodLookupId = 803

					IF @vendorCorresId IS NULL
					BEGIN
						INSERT INTO CWI_VendorCorrespondence
						(
							VendorId,
							CorrespondenceLookupId,
							DeliveryMethodLookupId,
							IsActive,
							CreatedBy,
							CreatedOn,
							ModifiedBy,
							ModifiedOn
						)
						VALUES
						(
							@intVendorID,
							@intcurCorrespondenceID,
							803, --apas 
							1,
							@intUserIDSystem,
							getdate(),
							@intUserIDSystem,
							getdate()
						)
						SET @vendorCorresId = IDENT_CURRENT( ''CWI_VendorCorrespondence'' )
					END

					insert into #tmpEmail
					Select * from dbo.fnc_SplitCommaSeparatedValuesIntoTable(@vccurEmail,'';'')

					INSERT INTO CWI_VendorCorrespondenceDelivery
					(
						VendorCorrespondenceID,
						VendorContactID,
						EmailID,
						IsAssociatedClients,
						IsActive,
						CreatedBy,
						CreatedOn,
						ModifiedBy,
						ModifiedOn
					)
					Select
						@vendorCorresId,
						CASE WHEN VC.Id IS NOT NULL THEN VC.Id ELSE NULL END,
						CASE WHEN VC.Id IS NULL THEN tmp.Email ELSE '''' END,
						0,
						1,
						@intUserIDSystem,
						getdate(),
						@intUserIDSystem,
						getdate()
						
					From #tmpEmail tmp
					LEFT OUTER JOIN CWI_VendorContact VC
						ON VC.Email = tmp.Email
					LEFT OUTER JOIN CWI_VendorCorrespondenceDelivery  VCD
						ON (tmp.Email = VCD.EmailID OR VCD.EmailID = VC.Id) AND VCD.VendorCorrespondenceID = 409

					WHERE
						VCD.Id IS NULL


					delete from #tmpEmail

					if @vccurProtocolType = ''B'' 
					Insert into CWI_VendorCorrespondence
					(
						VendorId,
						CorrespondenceLookupId,
						DeliveryMethodLookupId,
						Fax,
						IsActive,
						CreatedBy,
						CreatedOn,
						ModifiedBy,
						ModifiedOn
					)
					values
					(
						@intVendorID,
						@intcurCorrespondenceID,
						804, --Fax
						@vcFax,
						
						1,
						@intUserIDSystem,
						getdate(),
						@intUserIDSystem,
						getdate()
					)


				end

				else if @vccurProtocolType = ''F'' or @vccurProtocolType = ''B'' 
					SELECT top 1 @vendorCorresId = Id FROM CWI_VendorCorrespondence WHERE VendorId = @intVendorID 
							and  CorrespondenceLookupId =@intcurCorrespondenceID
							and DeliveryMethodLookupId = 804

					IF @vendorCorresId IS NULL
					BEGIN
						INSERT INTO CWI_VendorCorrespondence
						(
							VendorId,
							CorrespondenceLookupId,
							DeliveryMethodLookupId,
							IsActive,
							CreatedBy,
							CreatedOn,
							ModifiedBy,
							ModifiedOn
						)
						VALUES
						(
							@intVendorID,
							@intcurCorrespondenceID,
							804, --apas 
							1,
							@intUserIDSystem,
							getdate(),
							@intUserIDSystem,
							getdate()
						)
						SET @vendorCorresId = IDENT_CURRENT( ''CWI_VendorCorrespondence'' )
					END

					UPDATE CWI_VendorCorrespondence SET Fax= @vcFax
					WHERE Id = @vendorCorresId
					
				Fetch next from curPubsCorrespondence into @intcurCorrespondenceID,@vccurProtocolType,
																								@vccurEmail

				end
				close curPubsCorrespondence
				deallocate curPubsCorrespondence

			fetch next from curVendor into @vcCurPaperCode
			

		END --loop for cursor

		Close curVendor
		DeAllocate curVendor

END TRY
	BEGIN CATCH	
	IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
			if cursor_Status(''global'',''curVendor'') = 1  
				begin  
				close curVendor  
				deallocate curVendor  
				end
					if cursor_Status(''global'',''curPubsCorrespondence'') = 1  
				begin  
				close curPubsCorrespondence  
				deallocate curPubsCorrespondence  
				end
			print ''rolling back''
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;


' 
END
GO


