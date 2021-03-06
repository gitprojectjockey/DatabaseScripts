/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMediabuyCalculatedInvoice]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMediabuyCalculatedInvoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetMediabuyCalculatedInvoice]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMediabuyCalculatedInvoice]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMediabuyCalculatedInvoice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetMediabuyCalculatedInvoice
* Purpose : This PROC would be called TO get the calculated invoice amount based on division''s markup, compliment and freeze settings
* Invoked from : ManageVirtualCard.aspx
* CREATED: Mohankumar
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
    

**********************************************************************  
Execution example :,
**********************************************************************  
declare	@decInvoice   decimal(18,2) = NULL 
exec prc_CWI_GetMediabuyCalculatedInvoice 1,10, @decInvoice output
print @decInvoice
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetMediabuyCalculatedInvoice]	
	@inMediaBuyId bigint,	
	@decActualCost decimal(18,2)=NULL,
	@decInvoice   decimal(18,2) = NULL OUTPUT
AS
BEGIN	
	
	 DECLARE @IsActualCostFreeze bit,
			@IsActualInvoiceFreeze bit,
			@IsComplimentary bit,
			@IsComplimentaryInvoice bit,
			@isStatusChanged bit,
			@ActualCost decimal(18,2),
			@ActualInvoice decimal(18,2)

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
					),
				@ActualInvoice = ActualInvoice
			
		FROM CWI_JobMediaBuy (NOLOCK) WHERE Id= @inMediaBuyId 

	

		IF @IsActualInvoiceFreeze=1 OR @IsComplimentaryInvoice =1 /* if invoice freezed or set as compliment, do not update calculated invoice */
		BEGIN
			SET @decInvoice = @ActualInvoice
			RETURN
		END	
	
		
		SELECT @divisionId = DivisionId, @classId = ClassificationId FROM  CWI_Job (NOLOCK) WHERE Id = @inJobId

		
		select @decInvoice = dbo.fnc_CWI_GetDivisionMarkupInvoice(@divisionId,@classId,@decActualCost)
	end try
	begin catch
		throw;
	end catch		
END

' 
END
GO
