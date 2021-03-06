/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientAccountingInfo]    Script Date: 10/15/2014 6:59:40 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientAccountingInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientAccountingInfo]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientAccountingInfo]    Script Date: 10/15/2014 6:59:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientAccountingInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientAccountingInfo
* Purpose : This PROC would be called TO Set Client Accounting Information (from Client Accounting Tab)
* Invoked from : Client_Accounting.ascx
* CREATED: Ajay Thacker
* CREATED ON : 5Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetClientAccountingInfo]
    @inClientID int,
	@vcActgXref varchar(50),
	@bitPOReqd bit,
	@numMarkupPct numeric(5,2),
	@bitIsUsingClientMarkupAndFee bit,
	@inCreatedBy int
as
BEGIN
	BEGIN TRY
			
			--Check if the IsUsingClientMarkupAndFee Value has changed
			Declare @bitExistingIsUsingClientMarkupAndFee bit,
							@numClientMarkupPct numeric(5,2),
							@intParentID int
							

			set @intParentID = (Select isnull(ParentID,0) from CWI_Client
																where ID = @inClientID)
		
			--check if this is a Client Update or a Division Update
			if @intParentID = 0 --Client Update
			begin
					set @numClientMarkupPct = (Select MarkupPct from CWI_Client
																					where ID = @inClientID)
					
					Update CWI_Client
								Set ActgXref = @vcActgXref,
										IsPOReqd = @bitPOReqd,
										MarkupPct = @numMarkupPct,
										ModifiedBy = @inCreatedBy,
										ModifiedOn = getdate()
								where ID = @inClientID

				--Check if Client''s Default Markup has changed. 
				--If yes, then we have work to do :(
				--We need to update all those lucky division''s default markup who tagged along with the parent.
				if @numClientMarkupPct != @numMarkupPct
				begin
				Update CWI_Client 
										Set MarkupPct =@numMarkupPct,
												ModifiedBy = @inCreatedBy,
												ModifiedOn = getdate()
									where ID in
														(Select ID from CWI_Client 
															where ParentID = @inClientID
															and IsUsingClientMarkupAndFee = 1
														)

				end


			end
			else --Division Update
			begin

					set @bitExistingIsUsingClientMarkupAndFee = (Select isnull(IsUsingClientMarkupAndFee,0) from CWI_Client
																														where ID = @inClientID)


					if ( @bitExistingIsUsingClientMarkupAndFee != @bitIsUsingClientMarkupAndFee OR @bitExistingIsUsingClientMarkupAndFee = @bitIsUsingClientMarkupAndFee) --user has changed value
					begin
								Update CWI_Client
								Set IsUsingClientMarkupAndFeeModifiedBy = @inCreatedBy,
								IsPOReqd = @bitPOReqd,
								IsUsingClientMarkupAndFeeModifiedOn = getdate()
								where ID = @inClientID

								if @bitIsUsingClientMarkupAndFee = 1 --User has opted to use Client''s Classification Markup and Fee For Division
								begin
									
										--Upsert Classification Markup
										if exists (select ID from CWI_ClientClassification
													where ClientID = @inClientID)
													begin
																Update child 
																Set MarkupPct = parent.MarkupPct,
																		RoundToLookupID = parent.RoundToLookupID,
																		ModifiedBy = @inCreatedBy,
																		ModifiedOn = getdate()
															from CWI_ClientClassification parent
																inner join CWI_ClientClassification child
																	on parent.ClassificationLookupID= child.ClassificationLookupID
																	and parent.ClientID = @intParentID
															where child.ClientID = @inClientID
													end

													else
													begin
														Insert into CWI_ClientClassification
														(
														ClientID,ClassificationLookupID,MarkupPct,RoundToLookupID,CreatedBy,CreatedOn
														)
														Select @inClientID,
																	parent.ClassificationLookupID,
																	parent.MarkupPct,
																	parent.RoundToLookupID,
																	@inCreatedBy,
																	getdate()
														from CWI_ClientClassification parent
														where Parent.ClientID = @intParentID
														end

											--Upsert Service Fee
											if exists(Select ID from CWI_ClientService
																where ClientID = @inClientID)
																begin
																		Update child
																		Set ServiceFee = parent.ServiceFee,
																				ModifiedBy = @inCreatedBy,
																				ModifiedOn = GETDATE()
																		from CWI_ClientService parent
																			inner join CWI_ClientService child
																				on parent.ServiceID = child.ServiceID
																					and parent.ClientID = @intParentID
																		where child.ClientID = @inClientID
																end
																else
																begin
																	Insert into CWI_ClientService
																	(
																		ClientID,
																		ServiceID,
																		ServiceFee,
																		CreatedBy,
																		CreatedOn
																	)
																	Select
																		@inClientID,
																		parent.ServiceID,
																		parent.ServiceFee,
																		@inCreatedBy,
																		getdate()
																	from CWI_ClientService parent
																	where Parent.ClientID = @intParentID
																end

								--Update Default Markup of Division with the Default Markup of Client
								set @numClientMarkupPct	 = (Select MarkupPct from CWI_Client where ID = @intParentID)
									
								Update CWI_Client
								Set 
								MarkupPct = @numClientMarkupPct,
								IsUsingClientMarkupAndFee = 1,
								ModifiedBy = @inCreatedBy,
								ModifiedOn = getdate()
								where ID = @inClientID

								end
								else --User has opted to set the Division''s own Classification Markup And Fee
								Begin
										
										Update CWI_Client
						Set 
								MarkupPct = @numMarkupPct,
								IsUsingClientMarkupAndFee = 0,
								ModifiedBy = @inCreatedBy,
								ModifiedOn = getdate()
						where ID = @inClientID
								End
					end
					else --User is just performing a regular update, and not a IsUsingClientMarkupAndFeeUpdate for the Division
					begin
								Update CWI_Client
								Set ActgXref = @vcActgXref,
										IsPOReqd = @bitPOReqd,
										MarkupPct = @numMarkupPct,
										IsUsingClientMarkupAndFee = @bitIsUsingClientMarkupAndFee,
										ModifiedBy = @inCreatedBy,
										ModifiedOn = getdate()
								where ID = @inClientID
					End
			end
			

		declare @isDataSyncOn bit
		set @isDataSyncOn = (Select case when LookupName = ''YES'' then 1 else 0 end
																			from Lookup
																			Where ID = 6151 and LookupTypeID = 25)--DataSyncToTmimmrdb

		if @isDataSyncOn = 1
			BEGIN

					declare @vcCode varchar(3),
									@inttmpCount int

					--create temp table to get all division codes that have the use client setting
					create table #UseClient
					(
					ClientCode varchar(3)
					)

					set @vcCode = (Select ClientCode from cwi_Client where id = @inClientID)
					if @intParentID = 0 --Client Update
					begin
						 if @numClientMarkupPct != @numMarkupPct
						 begin
								update mmis.tmimmrdb.dbo.Parent
									set ActgXRef =@vcActgXref
								where ParentCd =@vcCode

								insert into #UseClient
								(ClientCode)
								Select ClientCode from CWI_Client
								where ParentID = @inClientID
								and IsUsingClientMarkupAndFee = 1

								set @inttmpCount = (Select isnull(count(ClientCode),0) from #UseClient)
								
								--to update markups for all clients that have the option checked
								--use the temp table to update the markup percentages in mmis
								if @inttmpCount > 0
										Update mmis.tmimmrdb.dbo.Client
										Set MarkupPct = @numMarkupPct
										where Clicode in (Select ClientCode from #useClient)

						end
						
		
					End
					else --division
					begin
						if @bitExistingIsUsingClientMarkupAndFee != @bitIsUsingClientMarkupAndFee --user has changed value
							begin
								if @bitIsUsingClientMarkupAndFee = 1 --User has opted to use Client''s Classification Markup and Fee For Division
								begin
											set @numClientMarkupPct = (Select MarkupPct from CWI_Client
																					where ID = @inClientID)
											update mmis.tmimmrdb.dbo.Client
												set [MarkupPct] = @numClientMarkupPct
												where  clicode = @vcCode
																								

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
																and C.CliCode = @vcCode
													inner join mmis.tmimmrdb.dbo.MediaClassMarkup MCM
														on C.CliCode = MCM.CliCode
													inner join  mmis.tmimmrdb.dbo.MediaClass MC
														on MCM.MediaClassID = MC.ID
													inner join dbo.Lookup Look
															on replace(Look.LookupName,''Jobboard'',''Internet'') = MC.Classification
																	and Look.LookupTypeID = 3
												where CWIC.ID = @inClientID
														


								end
									else --User has opted to set the Division''s own Classification Markup And Fee
								Begin
											update mmis.tmimmrdb.dbo.Client
												set [MarkupPct] = @numClientMarkupPct
												where  clicode = @vcCode

												--need to add code for class markups
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
																and C.CliCode = @vcCode
													inner join mmis.tmimmrdb.dbo.MediaClassMarkup MCM
														on C.CliCode = MCM.CliCode
													inner join  mmis.tmimmrdb.dbo.MediaClass MC
														on MCM.MediaClassID = MC.ID
													inner join dbo.Lookup Look
															on replace(Look.LookupName,''Jobboard'',''Internet'') = MC.Classification
																	and Look.LookupTypeID = 3
												where CWIC.ID = @inClientID

								End
							end
					end
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
