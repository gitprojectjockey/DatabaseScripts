/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorProducts]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorProducts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorProducts]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorProducts]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorProfile  
* Purpose : This PROC would be called TO get the vendor product data
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorProducts 10
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetVendorProducts]
	@VendorId int	
AS
BEGIN
	DECLARE @classId int
	SELECT @classId = ClassificationLookupId FROM CWI_Vendor WHERE Id =@VendorId
	SELECT 
		VP.ID, CP.ID ClassProductId,  PL.LookupName Product,   
		VP.ProductDesc, ISNULL(ProductDetails,'''') ProductDetails, VP.IsActive, U.Names , VP.ModifiedOn
	FROM  CWI_ClassificationProduct CP 
	INNER JOIN vw_CWI_ProductLookup PL
		ON CP.ProductTypeLookupId = PL.Id AND CP.ClassificationLookupId = @classId
	INNER JOIN  CWI_VendorProduct VP 
		ON VP.ClassificationProductId = CP.ID AND VP.VendorId = @VendorId 
		 AND VP.IsDeleted = 0
	INNER JOIN CWI_User U
		ON U.Id = VP.ModifiedBy
	ORDER BY PL.LookupName
END' 
END
GO
