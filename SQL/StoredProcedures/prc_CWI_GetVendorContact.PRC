/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorContact]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorContact]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorContact]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorContact]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorContact  
* Purpose : This PROC would be called TO get the contact details to edit
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorContact @ContactId=1
  
**********************************************************************/ 
  
CREATE PROC [dbo].[prc_CWI_GetVendorContact]
	@ContactId int = NULL
AS

IF @ContactId IS NOT NULL
BEGIN
	SELECT	
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

	WHERE 	VC.Id = @ContactId
		
	RETURN
END

	SELECT	
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
GO
