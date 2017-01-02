/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceFile]    Script Date: 3/27/2014 3:36:50 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceFile]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceFile]    Script Date: 3/27/2014 3:36:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceFile 
* Purpose : This PROC would be called TO get the invoice file 
* Invoked from : ManageInvoice.aspx
* CREATED: MohanKumar Sundaram  03/11/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetInvoiceFile
	@ClientId = 13957,
	@InvoiceDate = ''2013-10-27''
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetInvoiceFile]
	@ClientId int = NULL,
	@InvoiceDate Datetime = NULL,
	@InvoiceId bigInt=null,
	@InvoiceFile varchar(max) = NULL out
AS


IF( @InvoiceId IS NOT NULL )
BEGIN

 SELECT @InvoiceFile = InvoiceFile FROM CWI_Invoice
	WHERE 
		ID=@InvoiceId
	
	

END
else
	BEGIN
	SELECT @InvoiceFile = InvoiceFile FROM CWI_Invoice
	WHERE 
		ClientId = @ClientId
		AND InvoiceDate = @InvoiceDate
	
	IF @InvoiceFile IS NULL
	BEGIN
		SELECT @InvoiceFile = InvoiceFile FROM CWI_Invoice
		WHERE 
		ClientId = (SELECT ParentId FROM CWI_Client WHERE Id = @ClientId)
		AND InvoiceDate = @InvoiceDate
		END
	END' 
END
GO
