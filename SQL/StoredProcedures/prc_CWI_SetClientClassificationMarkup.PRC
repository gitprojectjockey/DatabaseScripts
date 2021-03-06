/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientClassificationMarkup]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientClassificationMarkup' )
 DROP PROCEDURE [dbo].[prc_CWI_SetClientClassificationMarkup]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientClassificationMarkup]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientClassificationMarkup
* Purpose : This PROC would be called TO Insert / Update Classification Markup
				
* Invoked from : Client_Accounting.ascx  (from Client Accounting Tab)
* CREATED: Ajay Thacker
* CREATED ON : 3Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
declare @p2 xml
set @p2=convert(xml,N'<DocumentElement><ClientClassificationMarkup><ClientClassificationID>73847</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>Default</MarkupPct><ClassificationLookupID>401</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73848</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>5.00</MarkupPct><ClassificationLookupID>402</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73849</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>2</MarkupPct><ClassificationLookupID>403</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73850</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>Default</MarkupPct><ClassificationLookupID>404</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73851</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>Default</MarkupPct><ClassificationLookupID>405</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73852</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>Default</MarkupPct><ClassificationLookupID>406</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73853</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>12.00</MarkupPct><ClassificationLookupID>407</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73854</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>2.00</MarkupPct><ClassificationLookupID>408</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73855</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>Default</MarkupPct><ClassificationLookupID>409</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73856</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>5.00</MarkupPct><ClassificationLookupID>410</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>73857</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct>Default</MarkupPct><ClassificationLookupID>411</ClassificationLookupID></ClientClassificationMarkup></DocumentElement>')
exec dbo.prc_CWI_SetClientClassificationMarkup @inClientID=13034,@xmlClassification=@p2,@inCreatedBy=13

declare @p2 xml
set @p2=convert(xml,N'<DocumentElement><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>401</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>402</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>403</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>404</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>405</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>406</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>407</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>408</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>409</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>410</ClassificationLookupID></ClientClassificationMarkup><ClientClassificationMarkup><ClientClassificationID>0</ClientClassificationID><RoundToLookupID>3005</RoundToLookupID><MarkupPct/><ClassificationLookupID>411</ClassificationLookupID></ClientClassificationMarkup></DocumentElement>')
exec dbo.prc_CWI_SetClientClassificationMarkup @inClientID=14207,@xmlClassification=@p2,@inCreatedBy=13
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetClientClassificationMarkup]    
    @inClientID int,
	@xmlClassification xml,
	@inCreatedBy int
	

AS
BEGIN


	--BEGIN TRANSACTION Trans1
	BEGIN TRY

	
	declare @numDefaultMarkup numeric(5,2)
	set @numDefaultMarkup = (Select  MarkupPct  from cwi_client where id = @inClientID)

	DECLARE @tblClientClassification TABLE
	(
		ClientClassificationID int,
		ClassificationLookupID int,
		MarkupPct numeric(5,2),
		RoundToLookupID int
		
	)			

	Insert into @tblClientClassification
	(
	ClientClassificationID,ClassificationLookupID,MarkupPct,RoundToLookupID
	)
	select 
	    COLX.value('(./ClientClassificationID)[1]','int'),
		COLX.value('(./ClassificationLookupID)[1]','int'),
		case when COLX.value('(./MarkupPct)[1]','varchar(50)') = 'Default' then @numDefaultMarkup
					when COLX.value('(./MarkupPct)[1]','varchar(50)') = '' then @numDefaultMarkup
					 else COLX.value('(./MarkupPct)[1]','varchar(50)')  end,
		COLX.value('(./RoundToLookupID)[1]','int')
		from @xmlClassification.nodes('DocumentElement/ClientClassificationMarkup') AS TABX(COLX)

		--We Insert records in CWI_ClientClassification that do not exist
		Insert into CWI_ClientClassification
		(
		ClientID,ClassificationLookupID,MarkupPct,RoundToLookupID,CreatedBy,CreatedOn
		)
		Select @inClientID,
					tmp.ClassificationLookupID,
					tmp.MarkupPct,
					tmp.RoundToLookupID,
					@inCreatedBy,
					getdate()
		from @tblClientClassification tmp
		left join CWI_ClientClassification cc
			on tmp.ClientClassificationID = cc.ID
		where cc.ID is null
			and tmp.ClientClassificationID = 0 --for new, we pass id as 0 from front end

		--We Update records in CWI_ClientClassification table that already exist
		Update CWI_ClientClassification
			Set MarkupPct = tmp.MarkupPct,
					RoundToLookupID = tmp.RoundToLookupID,
					ModifiedBy = @inCreatedBy,
					ModifiedOn = getdate()
		from @tblClientClassification tmp
		inner join CWI_ClientClassification cc
		on tmp.ClientClassificationID = cc.ID

		--Check if this was a Client whose Markup Value got changed. 
		--If yes, then we have work to do :(
		--We need to update all those lucky client's classification values who tagged along with the parent.
		if exists (Select ID from cwi_Client where ID = @inClientID and ParentID is null)
		begin

														Update child 
																Set MarkupPct = parent.MarkupPct,
																		RoundToLookupID = parent.RoundToLookupID,
																		ModifiedBy = @inCreatedBy,
																		ModifiedOn = getdate()
															from CWI_ClientClassification parent
																inner join CWI_ClientClassification child
																	on parent.ClassificationLookupID= child.ClassificationLookupID
																	and parent.ClientID  = @inClientID
															where child.ClientID in 
															(Select ID from CWI_Client 
																													where ParentID = @inClientID
																														and IsUsingClientMarkupAndFee = 1)
		end


		--DATA SYNC SETTINGS
		declare @isDataSyncOn bit,
						@intParentID int,
						@vcCode varchar(3)

		set @isDataSyncOn = (Select case when LookupName = 'YES' then 1 else 0 end
																			from Lookup
																			Where ID = 6151 and LookupTypeID = 25)--DataSyncToTmimmrdb

		if @isDataSyncOn = 1
			BEGIN
							set @intParentID = (Select isnull(ParentID,0) from CWI_Client
																where ID = @inClientID)

							set @vcCode = (Select ClientCode from cwi_Client where id = @inClientID)


							if @intParentID  = 0 --this is a top level client
							begin	--User has updated a markup for a classification for top level client
										--so we need to update all related Divisions that have use client checked

											create table #UseClient
											(
											ClientCode varchar(3)
											)

											insert into #UseClient
										(ClientCode)
											Select ClientCode from CWI_Client
											where ParentID = @inClientID
											and IsUsingClientMarkupAndFee = 1

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
																		and C.CliCode in (Select ClientCode from #useClient)
															inner join mmis.tmimmrdb.dbo.MediaClassMarkup MCM
																on C.CliCode = MCM.CliCode
															inner join  mmis.tmimmrdb.dbo.MediaClass MC
																on MCM.MediaClassID = MC.ID
															inner join dbo.Lookup Look
																	on replace(Look.LookupName,'Job boards','Internet') = MC.Classification
																			and Look.LookupTypeID = 3
														where CWIC.ID = @inClientID
							end
							else --user has updated a division's class  markup, so we need to just update that division's markup
							begin
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
																	on replace(Look.LookupName,'Job boards','Internet') = MC.Classification
																			and Look.LookupTypeID = 3
														where CWIC.ID = @inClientID
							end
			END

	END TRY
	BEGIN CATCH	
	IF @@TRANCOUNT >0 
			--ROLLBACK TRANSACTION Trans1;
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
	--IF @@TRANCOUNT > 0
		--COMMIT TRANSACTION Trans1;

END
	
GO
