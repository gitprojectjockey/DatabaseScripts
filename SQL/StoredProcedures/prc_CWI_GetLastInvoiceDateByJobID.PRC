/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLastInvoiceDateByJobID]    Script Date: 4/28/2014 6:25:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLastInvoiceDateByJobID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetLastInvoiceDateByJobID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLastInvoiceDateByJobID]    Script Date: 4/28/2014 6:25:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLastInvoiceDateByJobID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetLastInvoiceDateByJobID  
* Purpose : This PROC would be called TO get the Last InvoiceDate 
			
* Invoked from : jobs.aspx
* CREATED: Saravanan  
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetLastInvoiceDateByJobID 

  
**********************************************************************/ 
 
CREATE PROC [dbo].[prc_CWI_GetLastInvoiceDateByJobID]
	@JobId Bigint = NULL
AS
BEGIN
	
	SELECT 
		ISNULL(MAX(J.InvoiceGeneratedDate),'''') InvoiceDate 
	FROM 
		cwi_job J
	INNER JOIN 
		CWI_MarketingPlan MP 
	ON J.DivisionId=MP.DivisionID where J.id=@JobId ;

END




' 
END
GO
