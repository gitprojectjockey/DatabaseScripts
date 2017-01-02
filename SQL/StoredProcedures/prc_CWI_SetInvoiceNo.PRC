/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceNo]    Script Date: 4/8/2014 11:25:08 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceNo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetInvoiceNo]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceNo]    Script Date: 4/8/2014 11:25:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceNo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetInvoiceNo 
* Purpose : This PROC would be called TO generate the invoice no and update it
* Invoked from : ClientwiseInvoiceService
* CREATED: MohanKumar Sundaram  03/11/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetInvoiceNo
	@InvoiceId = 1,
	@InvoiceNo = null out
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetInvoiceNo]
	@InvoiceId bigint,
	@InvoiceNo bigint = null out
As
	BEGIN TRANSACTION
	BEGIN TRY
	Declare @No int=0;

	SELECT @No=ISNULL(InvoiceNo,0) FROM CWI_Invoice where Id=@InvoiceId; --AND ISNULL(InvoiceNo,0)=ISNULL(@InvoiceNo,0);

IF( @No=0)
BEGIN
	SELECT @InvoiceNo = ISNULL(MAX(InvoiceNo ),0) + 1 FROM CWI_Invoice

		UPDATE CWI_Invoice 
		SET InvoiceNo =@InvoiceNo
		WHERE
			Id= @InvoiceId
			AND InvoiceNo IS NULL
			AND IsDeleted = 0 ;
			SET @InvoiceNo=@InvoiceNo;

END	
else		
	BEGIN
	SELECT @InvoiceNo=InvoiceNo FROM CWI_Invoice where Id=@InvoiceId ;
	SET @InvoiceNo=@InvoiceNo;
	END	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;
		

' 
END
GO
