/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteVendorContact]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteVendorContact]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteVendorContact]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteVendorContact]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteVendorContact]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteVendorContact  
* Purpose : This PROC would be called TO delete the vendor contact
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_DeleteVendorContact
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_DeleteVendorContact]
    @ContactId int,
	@Author int
AS

	
	BEGIN TRY
		UPDATE CWI_VendorContact
		SET IsDeleted = 1, ModifiedBy =@Author, ModifiedOn = GETDATE()
		WHERE Id = @ContactId
	END TRY
	BEGIN CATCH
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH


 ' 
END
GO
