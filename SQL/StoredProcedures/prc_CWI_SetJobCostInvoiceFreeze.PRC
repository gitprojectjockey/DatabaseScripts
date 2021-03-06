/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobCostInvoiceFreeze]    Script Date: 5/28/2014 8:04:10 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobCostInvoiceFreeze]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobCostInvoiceFreeze]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobCostInvoiceFreeze]    Script Date: 5/28/2014 8:04:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobCostInvoiceFreeze]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_SetJobCostInvoiceFreeze] 
* Purpose : This PROC would be called TO UPDATE the expected and actual cost & invoice for the selected media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
 18-11-2013           
 28MAY14	Mohankumar		Validation added      
**********************************************************************  
Execution example :,
**********************************************************************  
exec [prc_CWI_SetJobCostInvoiceFreeze] NULL,1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobCostInvoiceFreeze]	
	@inMediaBuyId int,			
	@decExpectedCost decimal(18,2)=NULL,
	@decExpectedInvoice decimal(18,2)=NULL,
	@decActualCost decimal(18,2)=NULL,
	@decActualInvoice decimal(18,2)=NULL,
	@isActualCostFreeze bit,
	@isActualInvoiceFreeze bit,
	@isComplimentary bit,
	@isComplimentaryInvoice bit,
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	

	begin try	
		IF EXISTS (SELECT top 1 1 FROM CWI_JobMediaBuy WHERE [ID]=@inMediaBuyId and (DNR=1 OR isremoved = 1 OR iscancelled = 1 
		OR StatusId NOT IN( 20102 /* Selected */, 20103 /* Generated */)
		OR (@isComplimentary=1 AND @decActualCost<>0) OR (@isComplimentaryInvoice=1 AND @decActualInvoice<>0)))
		Begin
			declare @message NVARCHAR(2000) = ''Page refreshed as the media buy has been updated by another user''; 
			THROW 50000,@message , 1; 
		End
	end try
	begin catch
		throw;
	end catch
	BEGIN TRY
		UPDATE 	[dbo].[CWI_JobMediaBuy]		
		SET [ExpectedCost]=@decExpectedCost,[ExpectedInvoice]=@decExpectedInvoice,
		[ActualCost]=@decActualCost,[ActualInvoice]=@decActualInvoice,
		[IsActualCostFreeze]=@isActualCostFreeze,[IsActualInvoiceFreeze]=@isActualInvoiceFreeze,
		[IsComplimentary]=@isComplimentary,[IsComplimentaryInvoice]=@isComplimentaryInvoice,
		ModifiedBy=@inUserId,ModifiedOn=GETDATE()
		WHERE [ID]=@inMediaBuyId
				
		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END

' 
END
GO
