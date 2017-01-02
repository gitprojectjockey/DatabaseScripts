/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceFile]    Script Date: 3/15/2014 9:45:35 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetInvoiceFile]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceFile]    Script Date: 3/15/2014 9:45:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetInvoiceFile
* Purpose : This PROC would be called TO update the invoice file path and name
* Invoked from : ClientwiseInvoiceService
* CREATED: MohanKumar Sundaram  03/11/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetInvoiceFile
	@InvoiceId = 1,
	@InvoiceFilePath = "C:/Invoice/",
	@InvoiceFileName = "1_ACS(Corp).pdf"
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetInvoiceFile]
	@InvoiceId bigint,
	@InvoiceFilePath varchar(max),
	@InvoiceFileName varchar(max)
As
	BEGIN TRANSACTION TRAN1
		BEGIN TRY
			UPDATE CWI_Invoice 
			SET InvoiceFilePath = @InvoiceFilePath,
				InvoiceFile = @InvoiceFileName,
				StatusLookupId=8009--Pending Invoice Delivery
			WHERE
				Id = @InvoiceId
				AND IsDeleted = 0

			UPDATE J
				SET JobStatusLookupId=8009--Pending Invoice Delivery
				FROM CWI_Job J 				
				WHERE
					J.InvoiceId = @InvoiceId
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION TRAN1;
			EXEC prc_CWI_AppRaiseError;
			THROW;
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION TRAN1;

		' 
END
GO


