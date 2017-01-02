/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoicePO]    Script Date: 3/15/2014 9:07:00 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoicePO]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoicePO]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoicePO]    Script Date: 3/15/2014 9:07:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoicePO]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoicePO 
* Purpose : This PROC would be called TO get PO details for job
* Invoked from : ManageInvoice.aspx
* CREATED: MohanKumar Sundaram  03/15/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetInvoicePO
	@JobId = 6
  
**********************************************************************/ 



CREATE PROC [dbo].[prc_CWI_GetInvoicePO]
	@JobId bigint
AS
select 
	J.PONumber, 
	J.InvoiceId,
	J.JobStatusLookupId,
	ISNULL(CDI.IsConsolidated,0) IsConsolidated,
	CDI.InvoiceTypeLookupId
from CWI_Job J
LEFT OUTER JOIN vw_CWI_ClientDivisionInvoice CDI
	ON j.DivisionId = CDI.ClientDivId
WHERE
	J.Id = @JobId' 
END
GO


