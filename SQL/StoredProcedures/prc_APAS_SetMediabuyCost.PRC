/****** Object:  StoredProcedure [dbo].[prc_APAS_SetMediabuyCost]    Script Date: 11/5/2014 3:35:47 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_SetMediabuyCost]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_SetMediabuyCost]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_SetMediabuyCost]    Script Date: 11/5/2014 3:35:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_SetMediabuyCost]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_APAS_SetMediabuyCost  
* Purpose : This PROC would be called TO update media buy cost from APAS
* Invoked from : PaperCostWizard.aspx
* CREATED: MohanKumar Sundaram 05AUG14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_APAS_SetMediabuyCost @MediaBuyId  = 123,  
  @NetCost = 12,  
  @notes = NULL,  
  @email = ''test@test.com'',  
  @Gross = 23,  
  @CostType = ''Gross'',  
  @CostUsed = ''M''
  
**********************************************************************/ 
 
CREATE proc [dbo].[prc_APAS_SetMediabuyCost]
  
  @MediaBuyId bigint = null, 
  @Gross as decimal(13,2) = NULL,  
  @NetCost decimal(13,2),  
  @notes varchar(1000) = null,  
  @AuthorName varchar(200) = null,  
  @AuthorEmail varchar(200) = null,  
  @CostType as varchar(10),  
  @CorrespondenceRefId bigint 

as  
  

DECLARE @IsActualCostFreeze bit,
	@IsActualInvoiceFreeze bit,
	@IsComplimentary bit,
	@IsComplimentaryInvoice bit,
	@invoice decimal(18,2)

DECLARE @divisionId int,
	@classId int,
	@inJobId bigint

  
declare @isCancelled bit
declare @isInvoiced bit
declare @DNR bit
declare @PayMehtodId int

declare @message NVARCHAR(2000) =''''


set @notes=ISNULL(@notes,'''')  
  
--Get the values for IsActualInvoiceFreeze and IsComplimentaryInvoice from CWI_JobMediaBuy for the MMRPO.  
select 
	
	@isCancelled = IsCancelled,
	@isInvoiced = CASE WHEN StatusId IN (20102 /*Selected*/, 20103 /*Generated*/) THEN 0 ELSE 1 END, 
	@DNR = DNR,
	@inJobId = Jobid,
	@IsActualCostFreeze=IsActualCostFreeze,
	@IsActualInvoiceFreeze = IsActualInvoiceFreeze,
	@IsComplimentary = IsComplimentary,
	@IsComplimentaryInvoice =IsComplimentaryInvoice 
FROM CWI_JobMediaBuy where Id = @MediaBuyId 

IF @isCancelled = 1 
BEGIN
	SET @message = ''Warning: The MMRPO has been cancelled. Please refresh the page and try again OR call MMR for any clarifications.'';
	THROW 50000,@message , 1; 
	return;
END

IF @DNR=1
BEGIN
	SET @message = ''Warning: The MMRPO has been DNR''''d. Please refresh the page and try again OR call MMR for any clarifications.'';
	THROW 50000,@message , 1; 
	return;
END
IF @IsComplimentary=1
BEGIN
	SET @message = ''Warning: The MMRPO''''s cost is compliment. Please refresh the page and try again OR call MMR for any clarifications.'';
	THROW 50000,@message , 1; 
	return;
END

IF @IsActualCostFreeze=1
BEGIN
	SET @message = ''Warning: The MMRPO''''s cost is frozen. Please refresh the page and try again OR call MMR for any clarifications.'';
	THROW 50000,@message , 1; 
	return;
END

IF @isInvoiced = 1
BEGIN
	SET @message = ''The cost of this MMRPO is already been invoiced. Please refresh the page and try again OR call MMR for any clarifications.'';
	THROW 50000,@message , 1; 
	return;
END
  
SELECT @divisionId = DivisionId, @classId = ClassificationId FROM  CWI_Job WHERE Id = @inJobId
	
select @invoice = dbo.fnc_CWI_GetDivisionMarkupInvoice(@divisionId,@classId,@NetCost)

DECLARE @QuotedByAuthor VARCHAR(100) = NULL,
		@QuotedByAuthorEmail VARCHAR(100) = NULL,
		@QuotedDate VARCHAR(100) = NULL

IF @Gross IS NOT NULL
Begin
	SELECT @QuotedByAuthor  = @AuthorName,
		@QuotedByAuthorEmail  = @AuthorEmail,
		@QuotedDate  = getdate()
End

BEGIN TRANSACTION
BEGIN TRY
  
	UPDATE CWI_JobMediaBuy  
	SET 
		QuotedCost=ISNULL(@Gross,QuotedCost),
		CostType=@CostType,  
		ActualCost = @netcost, 
		[ActualInvoice]=@invoice, 
		QuotedByAuthor=ISNULL(@QuotedByAuthor,QuotedByAuthor),
		QuotedByAuthorEmail=ISNULL(@QuotedByAuthorEmail,QuotedByAuthorEmail), 
		QuotedDate=ISNULL(@QuotedDate,QuotedDate),  
		ModifiedOn=getdate(),  
		ModifiedBy=1   /* system*/,
		ModifiedByName=@AuthorName  /* system*/,
		ModifiedApplication = ''APAS'',
		ModifiedByEmail=@AuthorEmail   /* system*/,
		CostUpdatedBy = @AuthorName,
		CostUpdatedByEmail = @AuthorEmail,
		CostUpdatedApplication = ''APAS'',
		CostUpdatedOn=GETDATE(),
		CostUpdateDeliveryId  = ISNULL(@CorrespondenceRefId,CostUpdateDeliveryId)
	WHERE Id = @MediaBuyId

	IF @PayMehtodId = 852 /* Virtual Card */
	BEGIN
		declare @CCNumber as varchar(25)    
		declare @CCLimit numeric(18,2)

		select @CCLimit =CONVERT(numeric(18,2), @netcost + 1)

		Select @CCNumber = scd.CCNumber from SettlementComDataCCNumber scd 
		inner join CWI_JobMediaBuy s on     
		scd.SettlementID = s.ID 
		Where s.Id = @MediaBuyId   

		-- If the user hits Save Multiple times then the same line gets entered  
		-- and the vendor ComData gets an alert to possible fraudulent activity  
		-- due to "duplicate Transactions" .. check first to see if the transaction still exists  
		if not exists (Select top 1 ''x'' from ComdataCommunicationControl where Settlementid = @MediaBuyId 
			and ComDataTemplateID = 2 and ProcessedDate is Null and CCLimit = @CCLimit)  
		Begin
			Insert into COMDATACommunicationControl (SettlementID,ComDataTemplateID,Created,ResponseCode,CCLimit)    
			values (@MediaBuyId,2,getdate(),0,@CCLimit)    
         
			--Update the AP Status    
			--exec vcm_UpdateAPStatus @CCNumber    
		END  
    
	END    

	IF LTRIM(RTRIM(@notes)) <> ''''
	BEGIN
		EXEC prc_CWI_SetComment @inUserId = 1, /*system*/
			@inObjectLookupId =211, /*MediaBuy*/
			@inObjectId= @MediaBuyId,
			@inCommentId = NULL,
			@vcComment= @notes,
			@inRowCount = NULL,
			@vcUserName = @AuthorName,
			@vcUserEmail = @AuthorEmail
	
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT >0 
		ROLLBACK TRANSACTION ;
	EXEC prc_CWI_AppRaiseError; 
	THROW
END CATCH
IF @@TRANCOUNT > 0
	COMMIT TRANSACTION ;    
    







' 
END
GO


