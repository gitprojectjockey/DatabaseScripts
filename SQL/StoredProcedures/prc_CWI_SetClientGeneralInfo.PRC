/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientGeneralInfo]    Script Date: 3/25/2014 2:06:20 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientGeneralInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientGeneralInfo]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientGeneralInfo]    Script Date: 3/25/2014 2:06:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientGeneralInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientGeneralInfo
* Purpose : This PROC would be called TO insert Client General Information (from Client General Tab)
* Invoked from : Client.aspx
* CREATED: Ajay Thacker
* CREATED ON : 1Mar2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  24MAR14	Mohankumar		New Division status is set based on it''s client''s status

**********************************************************************  
Execution example :
**********************************************************************  
declare @p17 int
set @p17=13960
declare @p18 varchar(1000)
set @p18=''''
exec dbo.prc_CWI_SetClientGeneralInfo @inClientID=13960,@inParentID=NULL,@vcClientCode=''A11'',@vcClientName=''XEROX - T&T - SPRINT - LEXINGTON, KY'',@vcAddressLine1=''5210 MARYLAND WAY test'',@vcAddressLine2=''SUITE 301'',@intCountryID=1,@intStateID=51,@vcCity=''
BRENTWOOD'',@vcZip=''37027'',@vcWorkPhone=''8593894436'',@vcWorkExtn='''',@vcWorkFax=''7706450833'',@inClientStatusLookupID=502,@inHierarchyTypeLookupID=522,@inCreatedBy=13,@inNewClientID=@p17 output,@vcErrorMsg=@p18 output
select @p17, @p18
**********************************************************************/ 
  
  --select * from cwi_client where clientcode = ''ajx''
  --select ID From CWI_Client where ClientCode = ''acs'' and ID != 13957

CREATE PROCEDURE [dbo].[prc_CWI_SetClientGeneralInfo]    
    @inClientID int = null,
	@inParentID int=null,
    @vcClientCode varchar(5),
	@vcClientName varchar(255),
	@vcAddressLine1 varchar(255),
	@vcAddressLine2  varchar(255),
	@intCountryID  int,
	@intStateID int,
	@vcCity varchar(50),
	@vcZip varchar(50),
	@vcWorkPhone varchar(50),
	@vcWorkExtn varchar(10),
	@vcWorkFax varchar(50),
	@inClientStatusLookupID int,
	@inHierarchyTypeLookupID int,
	
	@inCreatedBy int,
	@inNewClientID int out,
	
	@vcErrorMsg varchar(1000) out

AS
BEGIN
	DECLARE @inAddressID int,
						@isDataSyncOn bit,
						@inNewParentID int,
						@inNewChildID int,
						@vcStateCode varchar(2),
						@intUserIDSystem int

						set @isDataSyncOn = (Select case when LookupName = ''YES'' then 1 else 0 end
																			from Lookup
																			Where ID = 6151 and LookupTypeID = 25)--DataSyncToTmimmrdb

	BEGIN TRY

			
		set @vcErrorMsg = ''''
		if @inClientID is null OR @inClientID=0 --new Client record to be inserted
		BEGIN

			if exists(select ID From CWI_Client where ClientCode = @vcClientCode)
				begin
					set @vcErrorMsg = ''Client Code '' + @vcClientCode + '' already exists. Save Failed.''
					return
				end

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
			CreatedBy
			)
			values
			(
			@vcAddressLine1,
			@vcAddressLine2,
			@intCountryID,
			@intStateID,
			@vcCity,
			@vcZip,
			@vcWorkPhone,
			@vcWorkExtn,
			@vcWorkFax,
			@inCreatedBy
			)

			Set @inAddressID = @@IDENTITY

			DECLARE @inNewDivisionStatusId INT

			IF ISNULL(@inParentID ,0) > 0 /* If new division, find out the status  */
			BEGIN
				/* 
                 * New Division Status Logic
                 * If new division, the status will be based on the client (parent)
				 * If Client''s  status is On Hold, the division''s status is active since division does not have the status "On Hold"
                 If Client''s  status is prospect/active/Inactive, the division''s status is same as client''s status. 
                 */
				

				EXEC prc_CWI_GetClientStatus @inParentID, @inNewDivisionStatusId out
				IF @inNewDivisionStatusId = 503 -- On Hold
				Begin
					SET @inClientStatusLookupID = 502 --Active
				End
			END


			Insert into CWI_Client
			(
			ClientCode,
			ClientName,
			AddressID,
			ClientStatusLookupID,
			LastStatusModifiedBy,
			LastStatusModifiedOn,
			HierarchyTypeLookupID,
			ParentId,
			CreatedBy
			)
			values
			(
			@vcClientCode,
			@vcClientName,
			@inAddressID,
			@inClientStatusLookupID,
			@inCreatedBy,
			getdate(),
			@inHierarchyTypeLookupID,
			@inParentID,
			@inCreatedBy
			)

			set @inNewClientID = @@IDENTITY
		

		     if @inHierarchyTypeLookupID = 521 --client, then we need to create a default Division
			 begin
				
				set @inNewParentID = @inNewClientID
				/* 
                 * New Division Status Logic
                 * If new division, the status will be based on the client (parent)
				 * If Client''s  status is On Hold, the division''s status is active since division does not have the status "On Hold"
                 If Client''s  status is prospect/active/Inactive, the division''s status is same as client''s status. 
                 */
				

				EXEC prc_CWI_GetClientStatus @inNewParentID, @inNewDivisionStatusId out

				IF(@inNewDivisionStatusId = 503) --On Hold
				Begin
					SET @inNewDivisionStatusId =502 --Active
				End
				/*  New Division Status Logic ENDS */

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
					CreatedBy
					)
					values
					(
					@vcAddressLine1,
					@vcAddressLine2,
					@intCountryID,
					@intStateID,
					@vcCity,
					@vcZip,
					@vcWorkPhone,
					@vcWorkExtn,
					@vcWorkFax,
					@inCreatedBy
					)

					Set @inAddressID = @@IDENTITY

					Insert into CWI_Client
					(
					ClientCode,
					ClientName,
					AddressID,
					ClientStatusLookupID,
					LastStatusModifiedBy,
					LastStatusModifiedOn,
					HierarchyTypeLookupID,
					ParentId,
					CreatedBy
					)
					values
					(
					@vcClientCode,
					@vcClientName,
					@inAddressID,
					@inNewDivisionStatusId,
					@inCreatedBy,
					getdate(),
					522, --division
					@inNewParentID,
					@inCreatedBy
					)

					set @inNewChildID = @@identity
		end

			 /******************************division level activation***************************/
			 IF @inParentID IS NOT NULL
			 BEGIN				
				IF (SELECT [ClientStatusLookupID] FROM CWI_Client WHERE ID=@inParentID)=502 -- 502 IS FOR STATUS ACTIVE--
				BEGIN
					UPDATE CWI_Client
					SET ActgXref =NULL,
					ClientStatusLookupID = 502,
					LastStatusModifiedBy = @inCreatedBy,
					LastStatusModifiedOn = GETDATE()
					WHERE ID = @inNewClientID				
					
					Insert into CWI_ClientActivation(ClientID,ActivationRequestedBy,[ActivatedBy],[ActivatedOn])
					SELECT @inNewClientID,@inCreatedBy,[ActivatedBy],GETDATE()
					FROM [dbo].[CWI_ClientActivation] WHERE [ClientID]=@inParentID
									
				END
			 END
			 /*****************************end******************************/	

		END
		ELSE --Existing Client Record to be updated
		BEGIN
			SELECT @inParentID = ParentId FROM CWI_Client WHERE Id = @inClientID

			if exists(select ID From CWI_Client where ClientCode = @vcClientCode and ID
							not in (Select ID from CWI_Client where ID = @inClientID or ID = @inParentID OR ParentID = @inClientID or ParentID = @inParentID))
				begin
					set @vcErrorMsg = ''Client Code '' + @vcClientCode + '' already exists. Save Failed.''
					return
				end

			set @inNewClientID = @inClientID
			set @inAddressID = (select AddressID from CWI_CLient 
								where ID = @inClientID)
			

			UPDATE [dbo].[CWI_Address]
			   SET [AddressLine1] = @vcAddressLine1
				  ,[AddressLine2] = @vcAddressLine2
				  ,[CountryID] = @intCountryID
				  ,[StateID] = @intStateID
				  ,[City] = @vcCity
				  ,[Zip] = @vcZip
				  ,[WorkPhone] = @vcWorkPhone
				  ,[WorkExtn] = @vcWorkExtn
				  ,[WorkFax] = @vcWorkFax
				  ,[ModifiedBy] = @inCreatedBy
				  ,[ModifiedOn] = getdate()
			 WHERE  ID = @inAddressID

			UPDATE [dbo].[CWI_Client]
			   SET [ClientCode] = @vcClientCode
				  ,[ClientName] = @vcClientName
				  ,[ClientStatusLookupID] = @inClientStatusLookupID
				  ,[LastStatusModifiedBy] =  @inCreatedBy
				  ,[LastStatusModifiedOn] = getdate()
				  ,[HierarchyTypeLookupID] = @inHierarchyTypeLookupID
				  --,[ParentID] = @inParentID
				  ,[ModifiedBy] = @inCreatedBy
				  ,[ModifiedOn] = getdate()
			 WHERE  ID = @inClientID

			 /*******************ACTIVATE DIVISION WHILE ACTIVATING CLIENT************************************/	
			 IF @inParentID IS NOT NULL AND @inClientStatusLookupID=502	
			 BEGIN
				UPDATE CWI_Client
				SET ActgXref =NULL,
						ClientStatusLookupID = @inClientStatusLookupID,
						LastStatusModifiedBy = @inCreatedBy,
						LastStatusModifiedOn = GETDATE()
				WHERE ID IN	(SELECT [ID] FROM [dbo].[CWI_Client] WHERE [ParentID]=@inClientID)
		
				Update CWI_ClientActivation
				Set ActivatedBy  = @inCreatedBy,
					ActivatedOn = getdate()
				where ClientID IN (SELECT [ID] FROM [dbo].[CWI_Client] WHERE [ParentID]=@inClientID)
			END
		/************************************END************************************/

			 
		END

		--Data Sync to TMIMMRDB 
		--I could have inserted this code inside the above if statements but it would be easier later to just
		--comment out this entire block below when we no longer need the sync
		if @isDataSyncOn = 1
		BEGIN
				declare @vcParentCode varchar(3)
				set @vcStateCode = (Select StateCode from [State] where ID = @intStateID)
				set @intUserIDSystem =(Select ID from CWI_User where Login = ''System'')

				--Check if this is a new record or existing
				if @inClientID is null --new Client record to be inserted
				BEGIN
						if @inHierarchyTypeLookupID = 521 --client
							--we add the main client in Parent table, and we add the division in Client table
						BEGIN
								Insert into mmis.tmimmrdb.dbo.Parent
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
								P.Fax,
								AdTracking,
								AdTrackingReports,
								ConsolidatedInvoice, 
								EmailAdApproval, 
								InvDeliveryType,
								CWClientId
								)
								values
								(
								left(@vcClientCode,3),
								@vcClientName,
								@vcAddressLine1,
								@vcAddressLine2,
								@vccity,
								@vcStateCode,
								@vcZip,
								@vcWorkPhone,
								@vcWorkExtn,
								@vcWorkFax,
								0, --Ad Tracking
								0, --Ad Tracking Reports
								0, --Consolidated Invoice
								0, --Email Ad Approval
								''Manual'',--InvDeliveryType
								@inNewParentID
								)



						END


						set @vcParentCode = (Select left(ClientCode,3) from CWI_Client
																		where ParentID = @inNewClientID)
						if @vcParentCode is null 
							set @vcParentCode = left(@vcClientCode,3)

						Insert into mmis.tmimmrdb.dbo.Client
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
									values
								(
								left(@vcClientCode,3),
								@vcParentCode,
								@vcClientName,
								@vcAddressLine1,
								@vcAddressLine2,
								@vccity,
								@vcStateCode,
								@vcZip,
								@vcWorkPhone,
								@vcWorkExtn,
								@vcWorkFax,
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
								@inNewChildID
								)

						--We also insert zero markup records for MediaClass for this new division
						Insert into mmis.tmimmrdb.dbo.MediaClassMarkup
						(
						MediaClassID,CliCode,MarkupPercent
						)
						Select 
							 MC.ID,
							left(@vcClientCode,3),
							0
						from 
								mmis.tmimmrdb.dbo.MediaClass MC
									inner join dbo.Lookup Look
																	on replace(Look.LookupName,''Job boards'',''Internet'') = MC.Classification
																			and Look.LookupTypeID = 3
						order by mc.id
								
						



				END --end of adding new records
				else
				BEGIN --Update Existing Record
						if @inHierarchyTypeLookupID = 521 --client
						begin
								Update mmis.tmimmrdb.dbo.Parent
									set ParentCd = left(@vcClientCode,3),
											CompanyName =@vcClientName,
								BillAddr1 = @vcAddressLine1,
								BillAddr2 = @vcAddressLine2,
								BillCity = @vcCity,
								BillStCode = @vcStateCode,
								BillZip = @vcZip,
								Phone = @vcWorkPhone,
								PhoneExt = @vcWorkExtn,
								Fax = @vcWorkFax,
								CWClientID = @inClientID
								where ParentCd = @vcClientCode
						end
						else if @inHierarchyTypeLookupID = 522 --Division
						Begin
								Update mmis.tmimmrdb.dbo.Client
									set CliCode = left(@vcClientCode,3),
								ClientName =@vcClientName ,
								BillAddr1 =@vcAddressLine1 ,
								BillAddr2 =@vcAddressLine2 ,
								BillCity = @vcCity,
								BillStCode = @vcStateCode,
								BillZip =@vcZip,
								Phone1 =@vcWorkPhone,
								PhoneExt1 =@vcWorkExtn,
								Fax1 =@vcWorkFax,
								CWClientID = @inClientID
								where CliCode = @vcClientCode
						END

				END
		END
		


	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END


' 
END
GO


