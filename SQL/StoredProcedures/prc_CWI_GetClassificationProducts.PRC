/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClassificationProducts]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClassificationProducts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClassificationProducts]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClassificationProducts]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClassificationProducts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClassificationProducts  
* Purpose : This PROC would be called TO get the vendor product data for profile tab
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClassificationProducts @VendorId = 5990, @ClassificationId = NULL
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetClassificationProducts]
	@VendorId int = NULL,
	@ClassificationId int = NULL	
AS
BEGIN
	IF @ClassificationId IS NULL
	BEGIN
		SELECT top 1 @ClassificationId = ClassificationLookupId FROM CWI_Vendor  WHERE ID = @VendorId
	END
	
	SELECT 
		CP.ID ClassProductId, PL.LookupName Product, PL.ID ProductLookupID
	FROM  CWI_ClassificationProduct CP 
	INNER JOIN vw_CWI_ProductLookup PL
		ON CP.ProductTypeLookupId = PL.Id AND CP.ClassificationLookupId = @ClassificationId  
		AND CP.IsActive = 1 AND PL.IsActive = 1
			
	ORDER BY PL.LookupName

END


	
	

' 
END
GO
