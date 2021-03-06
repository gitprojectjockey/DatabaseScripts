/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteVendor]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteVendor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteVendor]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteVendor]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteVendor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteVendor  
* Purpose : This PROC would be called TO delete the vendor details
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_DeleteVendor
  
**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_DeleteVendor]
	@VendorId	int = 0 ,
	@Author	int

AS
BEGIN

	UPDATE CWI_Vendor SET IsDeleted = 1, ModifiedBy = @Author, ModifiedOn = getdate()
	WHERE Id = @VendorId and LastUsedOn is null
	
	IF @@ROWCOUNT =0
	begin
		declare @message NVARCHAR(2000) = ''Vendor can not be deleted because it is in use'';
		THROW 50000,@message , 1; 
	end

END



' 
END
GO
