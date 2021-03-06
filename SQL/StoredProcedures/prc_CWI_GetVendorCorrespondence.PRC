/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorCorrespondence]    Script Date: 11/11/2014 8:17:46 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorCorrespondence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorCorrespondence]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorCorrespondence]    Script Date: 11/11/2014 8:17:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorCorrespondence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorCorrespondence  
* Purpose : This PROC would be called TO get the vendor correspondence types
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorCorrespondence @VendorId = 7072, @CorrespondenceLookupId = 702

  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorCorrespondence]
    @VendorId int,
	@CorrespondenceLookupId int = NULL
AS
SELECT 
	VC.Id,
	VC.CorrespondenceLookupId,
	VC.DeliveryMethodLookupId,
	l.LookupName DeliveryMethod,
	ISNULL(VC.Fax,0) Fax,		
	ISNULL(VDC.VendorContactID,0) VendorContactID,
	VDC.EmailID,	
	VC.IsActive,
	VDC.IsAssociatedClients,
	ISNULL(VDC.IsActive,0) as [Status]
FROM 
	CWI_VendorCorrespondence VC

INNER JOIN Lookup L on VC.DeliveryMethodLookupId=l.Id
Left    JOIN 
	CWI_VendorCorrespondenceDelivery VDC ON VC.Id=VDC.VendorCorrespondenceID
	WHERE 
	VC.VendorId = @VendorId  and L.IsActive=1 AND (VDC.IsActive IS NULL OR  VDC.IsActive=1)
	AND VC.CorrespondenceLookupId = @CorrespondenceLookupId order by DeliveryMethodLookupId asc ;--,  VDC.VendorContactID DeliveryMethodLookupId asc ;

	

	 




' 
END
GO


