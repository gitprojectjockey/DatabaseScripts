/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteVendorContactClient]    Script Date: 1/27/2014 12:39:19 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteVendorContactClient]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteVendorContactClient]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteVendorContactClient]    Script Date: 1/27/2014 12:39:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteVendorContactClient]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorContactClient
* Purpose : This PROC would be called to Remove the customer to contact  
* Invoked from :AssignCustomerToContact.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_DeleteVendorContactClient] 
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_DeleteVendorContactClient]
	@ID INT OUT
	,@UserId INT
AS
BEGIN
BEGIN TRAN
BEGIN TRY
		INSERT INTO [dbo].[CWI_History_VendorContactClient]
			(
			[VendorContactClientID]
			,[VendorContactId]
			,[ClientId]
			,[IsDeleted]
			,[CreatedBy]
			,[CreatedOn]
			,[ModifiedBy]
			,[ModifiedOn])	   
		   
		(SELECT ID
			,[VendorContactId]
			,[ClientId]
			,[IsDeleted]
			,[CreatedBy]
			,[CreatedOn]
			,[ModifiedBy]
			,[ModifiedOn]
		FROM
		[CWI_VendorContactClient] WHERE Id=@ID);

	UPDATE [dbo].[CWI_VendorContactClient]
		SET
			IsDeleted=1                   
			,[ModifiedBy]=@UserId
			,[ModifiedOn]=GETDATE() 
		WHERE Id=@ID;
		


END TRY
BEGIN Catch
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION;
	EXEC prc_CWI_AppRaiseError;
		THROW;
END CATCH
	IF @@TRANCOUNT>0
	COMMIT TRANSACTION;
	SET @ID=@ID;
	
END
' 
END
GO
