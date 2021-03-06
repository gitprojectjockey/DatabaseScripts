/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobCostInvoiceForMediaBuy]    Script Date: 11/4/2014 2:45:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobCostInvoiceForMediaBuy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobCostInvoiceForMediaBuy]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobCostInvoiceForMediaBuy]    Script Date: 11/4/2014 2:45:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobCostInvoiceForMediaBuy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobCostInvoiceForMediaBuy 
* Purpose : This PROC would be called TO UPDATE the expected and actual cost & invoice for the selected media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  28MAY14	Mohankumar		Validation added  
  28OCT14	Vijesh			Modified for updating Virtual Card when cost of Media Buy has changed     

**********************************************************************  
Execution example :,
**********************************************************************  
exec prc_CWI_SetJobCostInvoiceForMediaBuy NULL,1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobCostInvoiceForMediaBuy]	
	@inJobId bigint,	
	@inVendorId int,		
	@decExpectedCost decimal(18,2)=NULL,
	@decExpectedInvoice decimal(18,2)=NULL,
	@decActualCost decimal(18,2)=NULL,
	@decActualInvoice decimal(18,2)=NULL,
	@inUserId int,
	@vcChangeType varchar(2),
	@inRowCount int OUTPUT  
AS
BEGIN	
	
	 DECLARE @IsActualCostFreeze bit,
			@IsActualInvoiceFreeze bit,
			@IsComplimentary bit,
			@IsComplimentaryInvoice bit,
			@isStatusChanged bit

	SELECT @IsActualCostFreeze=IsActualCostFreeze,
			@IsActualInvoiceFreeze = IsActualInvoiceFreeze,
			@IsComplimentary = IsComplimentary,
			@IsComplimentaryInvoice =IsComplimentaryInvoice ,
			@isStatusChanged= (
				CASE WHEN (DNR=1 OR isremoved = 1 OR iscancelled = 1 OR StatusId NOT IN (20102/* Selected */,20103/*Generated*/)) THEN 1 ELSE 0 END
				)
			
	FROM CWI_JobMediaBuy WHERE [JobId]=@inJobId AND [VendorId]=@inVendorId 

	begin try	
		IF EXISTS (SELECT top 1 1 FROM CWI_JobMediaBuy WHERE [JobId]=@inJobId AND [VendorId]=@inVendorId 
		and (DNR=1 OR isremoved = 1 OR iscancelled = 1 
		OR StatusId NOT IN( 20102 /* Selected */, 20103 /* Generated */)
		OR (IsComplimentary=1 AND @decActualCost<>0) OR (IsComplimentaryInvoice=1 AND @decActualInvoice<>0)))
		Begin
			declare @message NVARCHAR(2000) = ''Unable to update as the media buy has been updated by another user''; 
			THROW 50000,@message , 1; 
		End
	end try
	begin catch
		throw;
	end catch

	BEGIN TRY
	
		IF @vcChangeType = ''E''  ---EXPECTED COST CHANGE
		BEGIN
			UPDATE 	[dbo].[CWI_JobMediaBuy]		
			SET [ExpectedCost]=@decExpectedCost,[ExpectedInvoice]=@decExpectedInvoice,
			ModifiedBy=@inUserId,ModifiedOn=GETDATE()
			WHERE [JobId]=@inJobId AND [VendorId]=@inVendorId
		END
		ELSE IF @vcChangeType = ''A''	---ACTUAL COST CHANGE
		BEGIN
			UPDATE 	[dbo].[CWI_JobMediaBuy]		
			SET [ActualCost]=@decActualCost,[ActualInvoice]=@decActualInvoice,ModifiedBy=@inUserId,ModifiedOn=GETDATE()
			WHERE [JobId]=@inJobId AND [VendorId]=@inVendorId

			-------Virtual Card Update Request needed when cost of Media Buy has changed---------

			declare @mmrpo bigint=null 
			select @mmrpo = MMRPO from CWI_JobMediaBuy where [JobId]=@inJobId AND [VendorId]=@inVendorId

			if isnull(@mmrpo,0)<> 0	-----Update only after insertion generated
			begin 
				declare @CCLimit numeric(18,2),@TransCount smallint=NULL,@MediaBuyID bigint, @inRowCnt int 

				select @MediaBuyID = ID from CWI_JobMediaBuy where [JobId]=@inJobId 
									AND [VendorId]=@inVendorId and IsRemoved=0			

				select @CCLimit =CONVERT(numeric(18,2), @decActualCost + 1)

				select @TransCount = DefaultTransCount from CWI_Vendor where Id=@inVendorId and IsDeleted=0
			
				INSERT INTO COMDATACommunicationControl
				(SettlementID,ComDataTemplateID,Created,ResponseCode,CCLimit,TransCount)
				SELECT @MediaBuyID,2,GETDATE(),0,@CCLimit,@TransCount		
	
				--EXEC prc_CWI_SetVCLimitAndTransCount @MediaBuyID,@CCLimit,@TransCount,'''',@inUserId,@inRowCnt
			end

			----------------------------End-----------------------------------

		END	
		
				
		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)		
		
		-- EXEC prc_CWI_SetBudgetFromMediaBuy 	@inJobId,1,@inUserId /*Update is handled in  sql job . SP is prc_CWI_BudgetUpdate */		
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END
	

	






' 
END
GO
