/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorCorrespondenceID]    Script Date: 9/23/2013 3:50:50 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorCorrespondenceID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorCorrespondenceID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorCorrespondenceID]    Script Date: 9/23/2013 3:50:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorCorrespondenceID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorCorrespondenceID
* Purpose : This PROC would be called TO get the vendor correspondence types
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorCorrespondenceID @VendorId = 5947, @CorrespondenceLookupId = 704,@DeliveryMethodLookupId=803
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorCorrespondenceID]
    @VendorId int,
	@CorrespondenceLookupId int = NULL,
	@DeliveryMethodLookupId int
AS
SELECT top 1 Id from CWI_VendorCorrespondence where VendorId=@VendorId and CorrespondenceLookupId=@CorrespondenceLookupId and DeliveryMethodLookupId=@DeliveryMethodLookupId; --and IsActive=1;






' 
END
GO
