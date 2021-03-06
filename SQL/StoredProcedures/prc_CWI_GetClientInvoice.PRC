/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientInvoice]    Script Date: 3/14/2014 7:22:40 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientInvoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientInvoice]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientInvoice]    Script Date: 3/14/2014 7:22:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientInvoice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetClientInvoice]  
* Purpose : This PROC would be called TO get cient invoice details
* Invoked from : client.aspx
* CREATED: BALA
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetClientInvoice] 13961
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientInvoice]
    @ClientId int 
AS
	SELECT 
		CI.Id,		
		CI.ClientId,
		CI.IsConsolidated,
		ISNULL(CI.InvoiceTypeLookupId,0) InvoiceTypeLookupId,
		CI.Email,
		CID.DeliveryMethodLookupId
	FROM CWI_ClientInvoice CI
	INNER JOIN
	CWi_ClientInvoiceDelivery CID ON CI.ClientId=CID.ClientId AND CI.ClientId=@ClientId AND CID.IsActive=1;

	' 
END
GO
