/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceDeliveryResend]    Script Date: 4/11/2014 1:43:13 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceDeliveryResend]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetInvoiceDeliveryResend]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceDeliveryResend]    Script Date: 4/11/2014 1:43:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceDeliveryResend]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetInvoiceDeliveryResend  
* Purpose : This PROC would be called to update the invoice delivery
* Invoked from : ManageInvoiceDelivery.aspx
* CREATED: Mohankumar Sundaram		27MAR14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetInvoiceDeliveryResend
@invoiceId = 1,
@deliveryMethod = ''22121'',
@inUserId=3
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetInvoiceDeliveryResend] 
	@invoiceId bigint,
	@deliveryMethod varchar(max),
	@email varchar(max) = NULL,
	@inUserId INT 
AS
BEGIN	
	SET NOCOUNT ON
	BEGIN TRY	
		IF NOT EXISTS(SELECT top 1 1 FROM CWI_Invoice WHERE Id = @invoiceId)
		begin
			declare @message NVARCHAR(2000) = ''Invoice Id '' + CAST(@invoiceId as VARCHAR(max)) + '' not exists'';

			THROW 50000,@message , 1; 

		end

		DECLARE @tblDeliveryMethod TABLE
		(
			MethodId INT
		)

		INSERT INTO @tblDeliveryMethod
		SELECT 
			cast(Items as int)
		FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@deliveryMethod, '','')			

		BEGIN TRANSACTION TRAN1
			BEGIN TRY
				-----------------updating the field as deleted if record already exists--------
				UPDATE [CWI_InvoiceDelivery] SET IsDeleted = 1, ModifiedBy  =@inUserId, ModifiedOn = GETDATE()
				WHERE  InvoiceId = @invoiceId AND IsDeleted = 0
					
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
					@invoiceId,
					MethodId,
					CASE WHEN MethodId = 22121 THEN NULL ELSE @email END, /* for print no email is NULL*/
					CASE WHEN MethodId = 22121 THEN GETDATE() ELSE NULL END, /* for print delivery immediate*/
					@inUserId,
					GETDATE(),
					@inUserId,
					GETDATE(),
					0
				FROM @tblDeliveryMethod					

				-----------------updating the invoice table------------ 
				UPDATE CWI_Invoice
					SET 
						[StatusLookupId]=8010 ----pending finance submission status
				WHERE Id = @invoiceId	
					AND StatusLookupId = 8009 /* Pending Invoice Delivery    */
				
				UPDATE CWI_Invoice
					SET [DeliveryOn]=GETDATE(),
						[DeliveryBy]=@inUserId
				WHERE Id = @invoiceId	
					

				----------------updating job table----------
				UPDATE J
				SET JobStatusLookupId=8010 ----pending finance submission status
				FROM CWI_Job J 
				WHERE J.InvoiceId = @invoiceId

					
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
	SET NOCOUNT OFF
END


' 
END
GO


