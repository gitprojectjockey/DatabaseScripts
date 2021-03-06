/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorContactByEmail]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorContactByEmail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorContactByEmail]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorContactByEmail]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorContactByEmail 
* Purpose : This PROC would be called TO get the contact details of the email
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorContactByEmail 3 , 'Mohan@acs.com'
  
**********************************************************************/ 
  
CREATE PROC [dbo].[prc_CWI_GetVendorContactByEmail]
	@VendorId	int,
	@Email varchar(100)
AS


	SELECT	
		VC.Id,
		VendorId,
		Name,
		ContactTypeLookupId,
		ISNULL(Title,'') Title,
		ISNULL(Address,'') Address,
		Email,

		dbo.fnc_FormatRemovalPhone(PhoneWork,default) as PhoneWork,
		dbo.fnc_FormatRemovalPhone(PhoneCell,default) as PhoneCell,
		dbo.fnc_FormatRemovalPhone(PhoneOther,default) as PhoneOther,
		dbo.fnc_FormatRemovalPhone(Fax,default) as Fax,
		DOB,
		ISNULL(Interests,'') Interests,
		ISNULL(Notes,'') Notes,
		LC.LookupName ContactType
	FROM	CWI_VendorContact VC
	INNER JOIN  vw_CWI_VendorContactType LC
		ON VC.ContactTypeLookupId = LC.Id
	WHERE 	VendorId = @VendorId
	AND Email = @Email
AND IsDeleted = 0

ORDER BY 	ModifiedOn DESC	

GO
