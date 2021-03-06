IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorContacts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorContacts]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorContacts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorContacts  
* Purpose : This PROC would be called TO get all the vendor for the vendor id
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorContacts 2
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorContacts]
    @VendorId int 

AS
    SELECT 
		VC.Id,
		VC.Name,
		VC.Title,
		VC.Email,
		VC.ContactTypeLookupId,
		L.LookupName ContactType,
		dbo.fnc_FormatRemovalPhone(VC.PhoneWork,default) as PhoneWork,
		dbo.fnc_FormatRemovalPhone(VC.PhoneCell,default) as PhoneCell,
		dbo.fnc_FormatRemovalPhone(VC.PhoneOther,default) as PhoneOther

	FROM CWI_VendorContact VC
	INNER JOIN  Lookup  L ON L.Id = VC.ContactTypeLookupId
	WHERE VendorId = @VendorId
	AND IsDeleted = 0 
' 
END
GO
