/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAuthorizedInvoiceToProcess]    Script Date: 3/15/2014 9:42:43 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAuthorizedInvoiceToProcess]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetAuthorizedInvoiceToProcess]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAuthorizedInvoiceToProcess]    Script Date: 3/15/2014 9:42:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAuthorizedInvoiceToProcess]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetAuthorizedInvoiceToProcess 
* Purpose : This PROC would be called TO get all the authorized invoices which are ready to be processed
* Invoked from : ClientwiseInvoiceService
* CREATED: MohanKumar Sundaram  03/04/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetAuthorizedInvoiceToProcess
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetAuthorizedInvoiceToProcess]
	
AS

	select 
		Id,
		InvoiceNo,
		ClientId,
		InvoiceDate,
		IsConsolidated,
		InvoiceTypeLookupId
		 
	from CWI_Invoice
	where (InvoiceNo IS NULL OR InvoiceFile IS NULL)
	AND IsDeleted = 0
' 
END
GO


