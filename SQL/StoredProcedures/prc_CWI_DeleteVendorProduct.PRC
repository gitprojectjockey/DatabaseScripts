/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteVendorProduct]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteVendorProduct]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteVendorProduct]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteVendorProduct]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteVendorProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteVendorProduct  
* Purpose : This PROC would be called TO delete the vendor product 
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_DeleteVendorProduct 10, 1200
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_DeleteVendorProduct]
	@VendorProductId int,
	@VendorId int,
	@Author	int
AS
BEGIN
	UPDATE  CWI_VendorProduct  SET IsDeleted = 1, ModifiedBy = @Author, ModifiedOn = getdate()
	WHERE  Id = @VendorProductId 

	EXEC prc_CWI_GetVendorProducts @VendorId
END

' 
END
GO
