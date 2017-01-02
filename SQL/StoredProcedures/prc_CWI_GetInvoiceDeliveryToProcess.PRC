/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceDeliveryToProcess]    Script Date: 4/15/2014 4:20:47 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceDeliveryToProcess]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceDeliveryToProcess]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceDeliveryToProcess]    Script Date: 4/15/2014 4:20:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceDeliveryToProcess]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceDeliveryToProcess

* Purpose : This PROC would be called TO get the invoice(s) that are ready to deliver
* Invoked from : ClientwiseInvoiceService
* CREATED: MohanKumar Sundaram  15APR2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetInvoiceDeliveryToProcess

**********************************************************************/ 
 

CREATE PROC [dbo].[prc_CWI_GetInvoiceDeliveryToProcess]

AS
	


DECLARE @TemplateFile varchar(max)='''',
		@TemplateSubject varchar(max)=''''
	
SELECT TOP 1 @TemplateFile = TemplateFile, 
			@TemplateSubject = TemplateSubject
FROM CWI_EmailTemplate  
WHERE Id= 18 AND  IsActive = 1


select I.Id, I.InvoiceNo,I.InvoiceDate, I.InvoiceFile, ID.Id InvoiceDeliveryId, ID.DeliveryLookupId,ID.DeliveryEmail,
	@TemplateFile TemplateFile, @TemplateSubject TemplateSubject 
 from CWI_Invoice I(NOLOCK)
	INNER JOIN CWI_InvoiceDelivery  ID(NOLOCK)
	ON I.Id = ID.InvoiceId	
WHERE
	ID.IsDeleted = 0
	AND ID.DeliveryOn IS NULL

' 
END
GO


