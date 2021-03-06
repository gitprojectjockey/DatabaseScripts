/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientInvoice]    Script Date: 3/19/2014 5:30:27 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientInvoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientInvoice]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientInvoice]    Script Date: 3/19/2014 5:30:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientInvoice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/****************************************************************************************
* PROCEDURE: prc_CWI_SetClientInvoice
* Purpose : This Proc will be called to insert/update the Client Invoice details
* Invoked from : Client.aspx
* CREATED: Bala 

* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
**********************************************************************  

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientInvoice 
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetClientInvoice]
	@InvoiceId	int = 0 out,
	@ClientId int,
	@IsConsolidated	bit=0,
	@InvoiceTypeLookupId int,
	@DeliveryMethodLookupIds varchar(MAX),
	@Email varchar(max),
	@Author	int	
AS
SET @InvoiceId =0
SELECT top 1 @InvoiceId = Id FROM CWI_ClientInvoice WHERE ClientId = @ClientId

BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @tblDeliveryMethod TABLE(DeliveryMethodLookupIds int)
		INSERT INTO @tblDeliveryMethod 
			SELECT Items FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@DeliveryMethodLookupIds,'','')

			--Select * from @tblDeliveryMethod


		If @InvoiceId = 0
		BEGIN
			INSERT INTO CWI_ClientInvoice
			(
			ClientId,
			IsConsolidated,
			InvoiceTypeLookupId,
			Email,
			CreatedBy, 
			CreatedOn, 
			ModifiedBy, 
			ModifiedOn
			)
			VALUES
			(
			@ClientId,
			@IsConsolidated,
			@InvoiceTypeLookupId,
			@Email,
			@Author,
			getdate(),
			@Author,
			getdate()

			)
			SET @InvoiceId =  SCOPE_IDENTITY()
			
			--INSERT INTO dbo.CWI_ClientInvoiceDelivery 
			--	SELECT @ClientId,DeliveryMethodLookupIds,1,@Author,getdate(),@Author,getdate() FROM @tblDeliveryMethod 
			
		END
	ELSE
	BEGIN
		UPDATE CWI_ClientInvoice SET 
			ClientId=@ClientId,
			IsConsolidated=@IsConsolidated,
			InvoiceTypeLookupId=@InvoiceTypeLookupId,
			Email=@Email,
			ModifiedBy = @Author,
			ModifiedOn = getdate()
			WHERE 	Id = @InvoiceId
			

		END
	
	
		INSERT INTO dbo.CWI_ClientInvoiceDelivery 
		SELECT @ClientId,DeliveryMethodLookupIds,1,@Author,getdate(),@Author,getdate() 
		FROM @tblDeliveryMethod t 
		LEFT OUTER JOIN CWI_ClientInvoiceDelivery CD ON CD.ClientId = @ClientId AND CD.DeliveryMethodLookupId = t.DeliveryMethodLookupIds
		WHERE CD.Id is null

		UPDATE dbo.CWI_ClientInvoiceDelivery SET ModifiedBy = @Author, ModifiedOn = getdate(), IsActive = 1
		WHERE ClientId=@ClientId AND DeliveryMethodLookupId  in 
		(SELECT DeliveryMethodLookupIds FROM @tblDeliveryMethod) 

		Update CWI_ClientInvoiceDelivery 
			SET IsActive=0 
		WHERE ClientId=@ClientId AND DeliveryMethodLookupId not in 
		(SELECT DeliveryMethodLookupIds FROM @tblDeliveryMethod) 
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW

		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;

		RETURN


		
' 
END
GO
