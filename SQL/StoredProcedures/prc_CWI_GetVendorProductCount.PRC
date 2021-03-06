/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorProductCount]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorProductCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorProductCount]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorProductCount]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorProductCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorProductCount  
* Purpose : This PROC would be called TO get the vendor product count for checking while changing classification
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorProductCount 10
  
**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_GetVendorProductCount]
	@VendorId int
AS

select count(*) from CWI_VendorProduct
Where VendorId = @VendorId
' 
END
GO
