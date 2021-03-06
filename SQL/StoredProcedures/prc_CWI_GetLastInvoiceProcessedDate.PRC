/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLastInvoiceProcessedDate]    Script Date: 3/17/2014 2:33:49 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLastInvoiceProcessedDate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetLastInvoiceProcessedDate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLastInvoiceProcessedDate]    Script Date: 3/17/2014 2:33:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLastInvoiceProcessedDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetLastInvoiceProcessedDate  
* Purpose : This PROC would be called to get the last invoice processed date
* Invoked from : ManageInvoice.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************
DECLARE @dtInvoiceDate DATETIME  
exec [prc_CWI_GetLastInvoiceProcessedDate] @dtInvoiceDate
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetLastInvoiceProcessedDate] 
@dtInvoiceDate DATETIME OUTPUT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON			
		
		SET @dtInvoiceDate = (SELECT MIN(InvoiceDate) FROM CWI_Job J
								INNER JOIN CWI_JobMediaBuy MB 
								ON MB.JobId=J.ID  
								WHERE InvoiceId IS NULL
								AND ISNULL(MB.IsCancelled,0) = 0 
								AND ISNULL(MB.DNR,0) = 0
								AND ISNULL(J.IsQuote,0) = 0
								AND J.IsCancelled=0
								AND ISNULL(MB.IsRemoved,0) = 0 AND J.[JobStatusLookupId] NOT IN (8004,8006,8007,8008,8009,8010))		  

	END TRY

	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END










' 
END
GO
