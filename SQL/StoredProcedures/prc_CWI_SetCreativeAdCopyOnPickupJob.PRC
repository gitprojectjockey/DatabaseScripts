/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCreativeAdCopyOnPickupJob]    Script Date: 10/13/2014 9:12:23 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCreativeAdCopyOnPickupJob]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCreativeAdCopyOnPickupJob]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCreativeAdCopyOnPickupJob]    Script Date: 10/13/2014 9:12:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCreativeAdCopyOnPickupJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetCreativeAdCopyOnPickupJob
* Purpose : This PROC would be called to add or update the media buy with creative ad copy
* Invoked from : CopyJob.aspx
* CREATED: Vijesh Mahi - 7/Oct/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_SetCreativeAdCopyOnPickupJob]
	@inJobId bigint=2254,	
	@vcVendorId varchar(MAX)=1121,	
	@inMMRPO bigint=NULL,
	@inMediaBuyStatus int,	
	@filePath varchar(max)= NULL,
	@fileName varchar(max)= NULL,	
	@author =2

**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetCreativeAdCopyOnPickupJob]
	@inJobId bigint,	
	@vcVendorId varchar(MAX),	
	@inMMRPO bigint=NULL,
	@inMediaBuyStatus int,	
	@filePath varchar(max)= NULL,
	@fileName varchar(max)= NULL,
	@author int,
	@inMediaBuyId bigint=NULL output
AS
	BEGIN 
		BEGIN TRANSACTION TRAN1
		BEGIN TRY

			DECLARE @vcMessage varchar(max)

			EXEC prc_CWI_SetJobMediaBuy @inJobId,@vcVendorId,@inMMRPO,@inMediaBuyStatus,@author,@vcMessage OUTPUT

			Set @inMediaBuyId = (Select ID from CWI_JobMediaBuy where JobId=@inJobId and VendorId=convert(bigint,@vcVendorId))

			if isnull(@filePath,'''')<>''''
			begin
				Set @filePath = @filePath+convert(varchar,@inMediaBuyId)
			end
			
			exec [prc_CWI_SetFinalAdCopy] @inMediaBuyId,@filePath,@fileName,@author

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION TRAN1;
			EXEC prc_CWI_AppRaiseError;
			THROW;
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION TRAN1;

	END


' 
END
GO
