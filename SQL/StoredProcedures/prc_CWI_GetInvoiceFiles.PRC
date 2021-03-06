/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceFiles]    Script Date: 4/3/2014 3:04:31 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceFiles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceFiles]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceFiles]    Script Date: 4/3/2014 3:04:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceFiles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceFiles 
* Purpose : This PROC would be called TO get the multiple invoice files for a consolidated invoice pdf
* Invoked from : ManageInvoiceDelivery.aspx
* CREATED: Vijesh Mahi  03/26/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetInvoiceFiles
	@vcInvoiceIds=''78,79,77,80''
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetInvoiceFiles]
@vcInvoiceIds varchar(max)
AS
BEGIN	

	SELECT InvoiceFile,InvoiceNo FROM CWI_Invoice
	WHERE ID IN (Select items From fnc_SplitCommaSeparatedValuesIntoTable(@vcInvoiceIds,'',''))	
	
END


' 
END
GO
