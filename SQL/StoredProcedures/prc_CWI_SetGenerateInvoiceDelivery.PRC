/****** Object:  StoredProcedure [dbo].[prc_CWI_SetGenerateInvoiceDelivery]    Script Date: 4/3/2014 3:04:31 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetGenerateInvoiceDelivery]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetGenerateInvoiceDelivery]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetGenerateInvoiceDelivery]    Script Date: 4/3/2014 3:04:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetGenerateInvoiceDelivery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetGenerateInvoiceDelivery  
* Purpose : This PROC would be called to generate the invoice delivery
* Invoked from : ManageInvoiceDelivery.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetGenerateInvoiceDelivery] 
@invoiceData = ,
@inUserId=7
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetGenerateInvoiceDelivery] 
@invoiceData XML,
@inUserId INT 
AS
BEGIN	
	BEGIN TRY	

		DECLARE @tblInvoice TABLE
		(
			InvoiceId BIGINT,
			DeliveryLookupId INT,
			DeliveryEmail VARCHAR(MAX)
		)

		INSERT INTO @tblInvoice
			SELECT 
				COLX.value(''(./InvoiceId)[1]'',''BIGINT'') InvoiceId,
				COLX.value(''(./DeliveryLookupId)[1]'',''INT'') DeliveryLookupId,
				COLX.value(''(./DeliveryEmail)[1]'',''VARCHAR(MAX)'') DeliveryEmail
			FROM @invoiceData.nodes(''DocumentElement/InvoiceDataTable'') AS TABX(COLX)			

			BEGIN TRANSACTION TRAN1

				BEGIN TRY
					-----------------updating the field as deleted if record already exists--------
					UPDATE [CWI_InvoiceDelivery] SET IsDeleted = 1
					FROM [CWI_InvoiceDelivery] ID 
					INNER JOIN @tblInvoice t
					ON t.InvoiceId = ID.InvoiceId
					--AND t.DeliveryLookupId = ID.DeliveryLookupId
								
					
					----------------inserting the records from temp table to invoice delivery table----------
					INSERT INTO [dbo].[CWI_InvoiceDelivery]
					(
						InvoiceId,
						DeliveryLookupId,
						DeliveryEmail,   
						DeliveryOn,          
						CreatedBy,
						CreatedOn,
						ModifiedBy,
						ModifiedOn,
						IsDeleted
					)
					SELECT 
						InvoiceId,
						DeliveryLookupId,
						DeliveryEmail,
						CASE WHEN DeliveryLookupId=22121 THEN GETDATE() ELSE NULL END, --for delivery method other than print will be delivered by service
						@inUserId,
						GETDATE(),
						@inUserId,
						GETDATE(),
						0
					FROM @tblInvoice					

					-----------------updating the invoice table------------ 
					UPDATE INV
						SET [DeliveryOn]=GETDATE(),
							[DeliveryBy]=@inUserId,
							[StatusLookupId]=8010 ----pending finance submission status
						FROM [dbo].[CWI_Invoice] INV
							INNER JOIN @tblInvoice TI
							ON TI.InvoiceId=INV.Id		
					
					----------------updating job table----------
					UPDATE J
						SET JobStatusLookupId=8010  ----pending finance submission status
						FROM CWI_Job J 
							INNER JOIN	@tblInvoice TI 
								ON TI.InvoiceId=J.InvoiceId													
				END TRY
				BEGIN CATCH
					IF @@TRANCOUNT >0 
						ROLLBACK TRANSACTION TRAN1;
					EXEC prc_CWI_AppRaiseError;
					THROW;
				END CATCH
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION TRAN1;	

	END TRY

	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
	
END


' 
END
GO
