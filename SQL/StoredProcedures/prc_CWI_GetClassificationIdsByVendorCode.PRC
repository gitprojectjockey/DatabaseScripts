/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClassificationIdsByVendorCode]    Script Date: 7/19/2013 1:35:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClassificationIdsByVendorCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClassificationIdsByVendorCode]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClassificationIdsByVendorCode]    Script Date: 7/19/2013 1:35:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClassificationIdsByVendorCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetClassificationIdsByVendorCode]  
* Purpose : This PROC would be called to get the details with Division budget
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_GetClassificationIdsByVendorCode @VendorCode=''9596,9593''

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetClassificationIdsByVendorCode]
	@VendorCode varchar(MAX)
	
AS
BEGIN
	SELECT CWI_Vendor.ClassificationLookupId ,
	 CWI_Vendor.Id as VendorId
	From
	CWI_Vendor WHERE CWI_Vendor.Id in(Select items From fnc_SplitCommaSeparatedValuesIntoTable(@VendorCode,'',''))
END

' 
END
GO
