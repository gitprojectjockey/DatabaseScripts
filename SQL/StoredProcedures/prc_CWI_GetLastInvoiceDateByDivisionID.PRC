/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLastInvoiceDateByDivisionID]    Script Date: 5/13/2014 8:46:50 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLastInvoiceDateByDivisionID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetLastInvoiceDateByDivisionID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLastInvoiceDateByDivisionID]    Script Date: 5/13/2014 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLastInvoiceDateByDivisionID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetLastInvoiceDateByDivisionID  
* Purpose : This PROC would be called TO get the Last InvoiceDate 
			
* Invoked from : jobs.aspx
* CREATED: Saravanan  
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetLastInvoiceDateByDivisionID @DivisionID =14842 

  Select  dbo.fnc_GetLastInvoiceGeneratedDate(14842)
**********************************************************************/ 
 
CREATE PROC [dbo].[prc_CWI_GetLastInvoiceDateByDivisionID]
	@DivisionId Bigint = NULL
AS
BEGIN
	
	Select dbo.fnc_GetLastInvoiceGeneratedDate(@DivisionId) as InvoiceDate; 

END




' 
END
GO
