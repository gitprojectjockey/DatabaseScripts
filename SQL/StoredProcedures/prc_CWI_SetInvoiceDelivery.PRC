/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceDelivery]    Script Date: 4/15/2014 4:21:47 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceDelivery]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetInvoiceDelivery]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceDelivery]    Script Date: 4/15/2014 4:21:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceDelivery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetInvoiceDelivery

* Purpose : This PROC would be called TO update the delivery after delivering
* Invoked from : ClientwiseInvoiceService
* CREATED: MohanKumar Sundaram  03/04/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetInvoiceDelivery
	@InvoiceDeliveryId = 1
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetInvoiceDelivery]
	@InvoiceDeliveryId bigint

AS
	
	UPDATE [CWI_InvoiceDelivery] SET DeliveryOn = GETDATE()
	WHERE Id = @InvoiceDeliveryId




' 
END
GO


