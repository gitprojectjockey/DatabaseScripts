/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobMediaBuyCosts]    Script Date: 8/19/2014 3:09:38 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobMediaBuyCosts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobMediaBuyCosts]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobMediaBuyCosts]    Script Date: 8/19/2014 3:09:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobMediaBuyCosts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobMediaBuyCosts 
* Purpose : This PROC would be called TO UPDATE the expected and actual cost & invoice, freeze, compliment for the selected media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Mohankumar
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  13AUG14	Mohankumar		User name, email and modified application added
  29OCT14	Vijesh			Modified for updating virtual card update request
**********************************************************************  
Execution example :,
**********************************************************************  
exec prc_CWI_SetJobMediaBuyCosts NULL,1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobMediaBuyCosts]	
	@inMediaBuyId bigint,	
	@decExpectedCost decimal(18,2)=NULL,
	@decExpectedInvoice decimal(18,2)=NULL,
	@decActualCost decimal(18,2)=NULL,
	@decActualInvoice decimal(18,2)=NULL,
	@bIsActualCostFreeze bit=NULL,
	@bIsActualInvoiceFreeze bit=NULL,
	@bIsComplimentary bit=NULL,
	@bIsComplimentaryInvoice bit=NULL,
	@vcCostFreezeComment varchar(max) = NULL,
	@vcInvoiceFreezeComment varchar(max) = NULL,
	@vcComplimentComment varchar(max) = NULL,
	@vcComplimentInvoiceComment varchar(max) = NULL,
	@inUserId int,
	@vcChangeType varchar(2),/* ''EC'' -EXPECTED COST CHANGE, ''EI'' - Expected Invoice, ''AC'' - Actual Cost, ''AI'' - Actual Invoice
								 ''CF'' - Cost Freeze, ''IF'' - Invoice Freee, ''CC'' - Compliment Cost, ''CI'' - Compliment Invoice*/
	@invoice   decimal(18,2) = NULL OUTPUT,
	@vcModifiedApplication varchar(100)= ''Clientwise Internal''
AS
BEGIN	
	
	 DECLARE @IsActualCostFreeze bit,
			@IsActualInvoiceFreeze bit,
			@IsComplimentary bit,
			@IsComplimentaryInvoice bit,
			@isStatusChanged bit,
			@ActualCost decimal(18,2)

	DECLARE @divisionId int,
			@classId int,
			@inJobId bigint
	begin try	
		SELECT 
				@inJobId = Jobid,
				@IsActualCostFreeze=IsActualCostFreeze,
				@IsActualInvoiceFreeze = IsActualInvoiceFreeze,
				@IsComplimentary = IsComplimentary,
				@IsComplimentaryInvoice =IsComplimentaryInvoice ,
				@isStatusChanged= (
					CASE WHEN (DNR=1 OR isremoved = 1 OR iscancelled = 1 OR StatusId NOT IN (20102/* Selected */,20103/*Generated*/)) THEN 1 ELSE 0 END
					)
			
		FROM CWI_JobMediaBuy WHERE Id= @inMediaBuyId 


		IF @isStatusChanged =1
		Begin
			declare @message NVARCHAR(2000) = ''Unable to update as the media buy has been updated by another user''; 
			THROW 50000,@message , 1; 
		End
	end try
	begin catch
		throw;
	end catch

	DECLARE @vcUserName varchar(100),
			@vcUserEmail varchar(100)
	
	SELECT @vcUserName=Names, @vcUserEmail = Email FROM CWI_User WHERE Id = @inUserId

	
	IF @vcChangeType IN (''EC'',''AC'', ''IF'', ''CI'')/* if cost change/ invoice free/invoice compliment, calculate invoice based on division''s markup */
	Begin
		SELECT @divisionId = DivisionId, @classId = ClassificationId FROM  CWI_Job WHERE Id = @inJobId
		DECLARE @cost decimal(18,2)
		if @vcChangeType = ''EC''
		BEGIN
			SET @cost = @decExpectedCost
		END
		ELSE IF @vcChangeType = ''AC''
		BEGIN
			SET @cost = @decActualCost
		END
		ELSE
		BEGIN
			SET @cost = @ActualCost
		END
		
		select @invoice = dbo.fnc_CWI_GetDivisionMarkupInvoice(@divisionId,@classId,@cost)
		
	End

	BEGIN TRY
		IF @vcChangeType = ''EC''  ---EXPECTED COST CHANGE
		BEGIN
			UPDATE 	[dbo].[CWI_JobMediaBuy]		
			SET [ExpectedCost]=@decExpectedCost,[ExpectedInvoice]=@invoice,
			ModifiedBy=@inUserId,ModifiedOn=GETDATE(),
			ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication
			WHERE Id=@inMediaBuyId
			RETURN
		END
		ELSE IF @vcChangeType = ''EI''  ---EXPECTED INVOICE CHANGE
		BEGIN
			UPDATE 	[dbo].[CWI_JobMediaBuy]		
			SET [ExpectedInvoice]=@decExpectedInvoice,
			ModifiedBy=@inUserId,ModifiedOn=GETDATE(),
			ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication
			WHERE  Id=@inMediaBuyId
			RETURN
		END
		ELSE IF @vcChangeType = ''AC''	---ACTUAL COST CHANGE
		BEGIN
			IF @IsActualCostFreeze=1
			Begin
				SET @message  = ''Unable to update Actual Cost as it is freezed''; 
				THROW 50000,@message , 1; 
			End

			IF @IsComplimentary=1 
			Begin
				SET @message  = ''Unable to update Actual Cost as it is set as Compliment''; 
				THROW 50000,@message , 1; 
			End
			IF @IsActualInvoiceFreeze=1 OR @IsComplimentaryInvoice =1 /* if invoice frezzed or set as compliment, do not update calculated invoice */
			Begin
				UPDATE 	[dbo].[CWI_JobMediaBuy]		
				SET [ActualCost]=@decActualCost,
					ModifiedBy=@inUserId,ModifiedOn=GETDATE(),
					ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication,
					CostUpdatedBy = @inUserId, CostUpdatedByName= @vcUserName, CostUpdatedByEmail = @vcUserEmail, CostUpdatedApplication = @vcModifiedApplication
				WHERE  Id=@inMediaBuyId
			End
			Else
			Begin /* update cost and invoice */
				UPDATE 	[dbo].[CWI_JobMediaBuy]		
				SET [ActualCost]=@decActualCost,[ActualInvoice]=@invoice,
					ModifiedBy=@inUserId,ModifiedOn=GETDATE(),
					ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication,
					CostUpdatedBy = @inUserId, CostUpdatedByName= @vcUserName, CostUpdatedByEmail = @vcUserEmail, CostUpdatedApplication = @vcModifiedApplication
				WHERE  Id=@inMediaBuyId				
			End

			-------Virtual Card Update Request needed when cost of Media Buy has changed---------
			declare @mmrpo bigint=null 
			select @mmrpo = MMRPO from CWI_JobMediaBuy where Id=@inMediaBuyId

			if isnull(@mmrpo,0)<> 0	-----Update only after insertion generated
			begin 
			
				declare @CCLimit numeric(18,2),@TransCount smallint=NULL, @inRowCnt int, @inVendorId int

				select @inVendorId=VendorId from CWI_JobMediaBuy where Id=@inMediaBuyId					

				select @CCLimit =Convert(numeric(18,2),( @decActualCost + 1))

				select @TransCount = DefaultTransCount from CWI_Vendor where Id=@inVendorId and IsDeleted=0
			
				INSERT INTO COMDATACommunicationControl
				(SettlementID,ComDataTemplateID,Created,ResponseCode,CCLimit,TransCount)
				SELECT @inMediaBuyId,2,GETDATE(),0,@CCLimit,@TransCount		
	
				--EXEC prc_CWI_SetVCLimitAndTransCount @inMediaBuyId,@CCLimit,@TransCount,'''',@inUserId,@inRowCnt
			end
				----------------------------End-----------------------------------	

		END	
		ELSE IF @vcChangeType = ''AI''	---ACTUAL INVOICE CHANGE
		BEGIN
			IF @IsActualInvoiceFreeze=1
			Begin
				SET @message  = ''Unable to update Actual Invoice as it is freezed''; 
				THROW 50000,@message , 1; 
			End
			
			IF @IsComplimentaryInvoice=1 
			Begin
				SET @message  = ''Unable to update Actual Invoice as it is set as Compliment''; 
				THROW 50000,@message , 1; 
			End

			UPDATE 	[dbo].[CWI_JobMediaBuy]		
			SET 
				[ActualInvoice]=@decActualInvoice,
				ModifiedBy=@inUserId,
				ModifiedOn=GETDATE(),
				ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication
			WHERE  Id=@inMediaBuyId

			
		END	
		ELSE IF @vcChangeType = ''CF''	---COST FREEZED
		BEGIN
			IF @bIsActualCostFreeze= @IsActualCostFreeze /* if old and new value are same, don''t update anything */
			Begin
				RETURN;
			End

			IF LTRIM(RTRIM(@vcCostFreezeComment)) = ''''
			Begin
				SET @message  = ''Unable to update Cost Freeze as no Comment mentioned''; 
				THROW 50000,@message , 1; 
			End
			
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE 	[dbo].[CWI_JobMediaBuy]		
				SET 
					IsActualCostFreeze=@bIsActualCostFreeze,
					ModifiedBy=@inUserId,
					ModifiedOn=GETDATE(),
					ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication
				WHERE  Id=@inMediaBuyId

				EXEC prc_CWI_SetComment @inUserId, 207/*MediaBuyFreezeActualCost*/, @inMediaBuyId, NULL, @vcCostFreezeComment, 1, @vcUserName, @vcUserEmail
				
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT >0 
					ROLLBACK TRANSACTION ;
				EXEC prc_CWI_AppRaiseError; 
				THROW
			END CATCH
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION ;
			



		END	
		ELSE IF @vcChangeType = ''IF''	---INVOICE FREEZED
		BEGIN
			IF @bIsActualInvoiceFreeze= @IsActualInvoiceFreeze /* if old and new value are same, don''t update anything */
			Begin
				RETURN;
			End

			IF LTRIM(RTRIM(@vcInvoiceFreezeComment)) = ''''
			Begin
				SET @message  = ''Unable to update Invoice Freeze as no Comment mentioned''; 
				THROW 50000,@message , 1; 
			End
			
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE 	[dbo].[CWI_JobMediaBuy]		
				SET 
					IsActualInvoiceFreeze=@bIsActualInvoiceFreeze,
					ActualInvoice = (CASE WHEN @bIsActualInvoiceFreeze=0 AND @IsComplimentaryInvoice = 0 THEN @invoice 
										ELSE ActualInvoice END),/* if invoice not freezed and not compliment invoice, set calculated invoice */
					ModifiedBy=@inUserId,
					ModifiedOn=GETDATE(),
				ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication
				WHERE  Id=@inMediaBuyId

				EXEC prc_CWI_SetComment @inUserId, 209/*MediaBuyFreezeActualInvoice*/, @inMediaBuyId, NULL, @vcInvoiceFreezeComment, 1, @vcUserName, @vcUserEmail

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT >0 
					ROLLBACK TRANSACTION ;
				EXEC prc_CWI_AppRaiseError; 
				THROW
			END CATCH
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION ;
			


		END	
		ELSE IF @vcChangeType = ''CC''	---COST COMPLIMENT
		BEGIN
			IF @bIsComplimentary= @IsComplimentary /* if old and new value are same, don''t update anything */
			Begin
				RETURN;
			End

			IF LTRIM(RTRIM(@vcComplimentComment)) = ''''
			Begin
				SET @message  = ''Unable to update Compliment as no Comment mentioned''; 
				THROW 50000,@message , 1; 
			End
			
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE 	[dbo].[CWI_JobMediaBuy]		
				SET 
					IsComplimentary=@bIsComplimentary,
					ActualCost = 0,
					ModifiedBy=@inUserId,
					ModifiedOn=GETDATE(),
			ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication,
			CostUpdatedBy = @inUserId, CostUpdatedByName= @vcUserName, CostUpdatedByEmail = @vcUserEmail, CostUpdatedApplication = @vcModifiedApplication
				WHERE  Id=@inMediaBuyId
				
				EXEC prc_CWI_SetComment @inUserId, 208/*MediaBuyComplimentary*/, @inMediaBuyId, NULL, @vcComplimentComment, 1, @vcUserName, @vcUserEmail

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT >0 
					ROLLBACK TRANSACTION ;
				EXEC prc_CWI_AppRaiseError; 
				THROW
			END CATCH
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION ;

			
		END		
		ELSE IF @vcChangeType = ''CI''	---INVOICE COMPLIMENT
		BEGIN
			IF @bIsComplimentaryInvoice= @IsComplimentaryInvoice /* if old and new value are same, don''t update anything */
			Begin
				RETURN;
			End

			IF LTRIM(RTRIM(@vcComplimentInvoiceComment)) = ''''
			Begin
				SET @message  = ''Unable to update Compliment Invoice as no Comment mentioned''; 
				THROW 50000,@message , 1; 
			End
			
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE 	[dbo].[CWI_JobMediaBuy]		
				SET 
					IsComplimentaryInvoice=@bIsComplimentaryInvoice,
					ActualInvoice = (CASE 
										WHEN @bIsComplimentaryInvoice=1 THEN 0
										WHEN @bIsComplimentaryInvoice=0 AND @IsActualInvoiceFreeze = 0 THEN @invoice 
										ELSE ActualInvoice END),/* if compliment invoice, set invoice as 0.
													 if invoice not freezed and not compliment invoice, set calculated invoice */
					ModifiedBy=@inUserId,
					ModifiedOn=GETDATE(),
			ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication
				WHERE  Id=@inMediaBuyId
				
				EXEC prc_CWI_SetComment @inUserId, 210/*MediaBuyComplimentartyInvoice*/, @inMediaBuyId, NULL, @vcComplimentInvoiceComment, 1, @vcUserName, @vcUserEmail
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT >0 
					ROLLBACK TRANSACTION ;
				EXEC prc_CWI_AppRaiseError; 
				THROW
			END CATCH
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION ;

			
		END		
		SELECT @invoice = ActualInvoice FROM CWI_JobMediaBuy WHERE Id = @inMediaBuyId	
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END
	





' 
END
GO


