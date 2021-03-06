/****** Object:  StoredProcedure [dbo].[prc_CWI_SetSettlement]    Script Date: 11/4/2014 2:45:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetSettlement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetSettlement]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetSettlement]    Script Date: 11/4/2014 2:45:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetSettlement]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetSettlement  
* Purpose : This PROC would be called to retrieve all the settlement details
* Invoked from : ManageSettlement.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  13AUG14	Mohankumar		quoted cost name & email, cost update cost & email added
  29OCT14	Vijesh			Modified for updating virtual card update request
**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetSettlement] @MMRPO  = null
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetSettlement]	
	@inMMRPO bigint=NULL,	
	@decQuotedCost decimal(18,2)=NULL,
	@decNetCost decimal(18,2)=NULL,
	@decGrossInvoice decimal(18,2)=NULL,
	@isDNR bit=0,
	@vcCostType varchar(100)=NULL,
	@inUserId int,
	@inRowCount int OUTPUT ,
	@vcModifiedApplication varchar(100)= ''Clientwise Internal'' 
AS
BEGIN	

	BEGIN TRY	
		DECLARE @vcUserName varchar(100),
				@vcUserEmail varchar(100),
				@ActualCost decimal(18,2)
	
		SELECT @vcUserName=Names, @vcUserEmail = Email FROM CWI_User WHERE Id = @inUserId


		SELECT 
				@ActualCost= ActualCost
			
		FROM CWI_JobMediaBuy WHERE MMRPO = @inMMRPO

		IF @inMMRPO IS NOT NULL
		BEGIN
			IF @ActualCost <> @decNetCost /* if actual cost changes, calculate actual invoice */
			BEGIN
				UPDATE CWI_JobMediaBuy
				SET ActualCost=@decNetCost,ActualInvoice=@decGrossInvoice,
					DNR=@isDNR,CostType=@vcCostType,QuotedCost=@decQuotedCost,
					ModifiedBy=@inUserId,ModifiedOn=GETDATE(),
					QuotedBy=@inUserId,QuotedDate=GETDATE(),
					ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication,
					CostUpdatedBy = @inUserId, CostUpdatedByName= @vcUserName, CostUpdatedByEmail = @vcUserEmail, CostUpdatedApplication = @vcModifiedApplication,
					QuotedByAuthor =  @vcUserName, QuotedByAuthorEmail= @vcUserEmail

				WHERE MMRPO=@inMMRPO
				
				-------Virtual Card Update Request needed when cost of Media Buy has changed---------
			
				declare @CCLimit numeric(18,2),@TransCount smallint=NULL,@MediaBuyID bigint, @inRowCnt int, @inVendorId int

				select @MediaBuyID = ID,@inVendorId=VendorId from CWI_JobMediaBuy where MMRPO=@inMMRPO			

				select @CCLimit =Convert(numeric(18,2), @decNetCost + 1)

				select @TransCount = DefaultTransCount from CWI_Vendor where Id=@inVendorId and IsDeleted=0
			
				INSERT INTO COMDATACommunicationControl
				(SettlementID,ComDataTemplateID,Created,ResponseCode,CCLimit,TransCount)
				SELECT @MediaBuyID,2,GETDATE(),0,@CCLimit,@TransCount		
	
				--EXEC prc_CWI_SetVCLimitAndTransCount @MediaBuyID,@CCLimit,@TransCount,'''',@inUserId,@inRowCnt

				----------------------------End-----------------------------------	
			
			END
			ELSE
			BEGIN
				UPDATE CWI_JobMediaBuy
				SET ActualCost=@decNetCost,ActualInvoice=@decGrossInvoice,
					DNR=@isDNR,CostType=@vcCostType,QuotedCost=@decQuotedCost,
					ModifiedBy=@inUserId,ModifiedOn=GETDATE(),
					QuotedBy=@inUserId,QuotedDate=GETDATE(),
					ModifiedByName=@vcUserName, ModifiedByEmail = @vcUserEmail, ModifiedApplication = @vcModifiedApplication,
					QuotedByAuthor =  @vcUserName, QuotedByAuthorEmail= @vcUserEmail
				WHERE MMRPO=@inMMRPO	
			END
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)		
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
