/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendor]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendor]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendor]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[prc_CWI_GetVendor]
	@VendorId	int = 0
AS
BEGIN
	If @VendorId <> 0
	begin
		select 
			V.VendorCode,
			V.VendorName,
			V.VendorTypeLookUpId,
			V.VendorGroupLookupId,
			V.VendorURL,
			V.ClassificationLookupId,
			V.Note,
			V.StatusLookupId,
			V.AgencyDisc,
			isnull(V.AccountRefID,'') as AccountRefID,
			V.PayMethodLookupId,
			PA.AddressLine1 AddressLine1_Phy,
			isnull(PA.AddressLine2,'') AddressLine2_Phy,
			PA.CountryID CountryID_Phy,
			PA.StateID StateID_Phy,
			PA.City City_Phy,
			PA.Zip ZIp_Phy,
			dbo.fnc_FormatRemovalPhone(PA.WorkPhone,default) as Phone_Phy,
			PA.WorkExtn Extn_Phy,
			dbo.fnc_FormatRemovalPhone(PA.WorkFax,default) as Fax_Phy,
			BA.AddressLine1 AddressLine1_Bill,
			isnull(BA.AddressLine2,'') AddressLine2_Bill,
			BA.CountryID CountryID_Bill,
			BA.StateID StateID_Bill,
			BA.City City_Bill,
			BA.Zip ZIp_Bill,
			dbo.fnc_FormatRemovalPhone(BA.WorkPhone,default) as Phone_Bill,
			BA.WorkExtn Extn_Bill,
			dbo.fnc_FormatRemovalPhone(BA.WorkFax,default) as Fax_Bill


		 from CWI_Vendor V
		INNER JOIN vw_CWI_Address PA
			ON PA.ID = V.AddressId_Physical
		INNER JOIN vw_CWI_Address BA
			ON BA.ID = V.AddressId_Billing

		WHERE V.Id = @VendorId

		RETURN
	end
select 
			V.VendorCode,
			V.VendorName,
			V.VendorTypeLookUpId,
			V.VendorGroupLookupId,
			V.VendorURL,
			V.ClassificationLookupId,
			V.Note,
			V.StatusLookupId,
			V.AgencyDisc,
			isnull(V.AccountRefID,'') as AccountRefID,
			V.PayMethodLookupId,
			PA.AddressLine1 AddressLine1_Phy,
			isnull(PA.AddressLine2,'') AddressLine2_Phy,
			PA.CountryID CountryID_Phy,
			PA.StateID StateID_Phy,
			PA.City City_Phy,
			PA.Zip ZIp_Phy,
			dbo.fnc_FormatRemovalPhone(PA.WorkPhone,default) as Phone_Phy,
			PA.WorkExtn Extn_Phy,
			dbo.fnc_FormatRemovalPhone(PA.WorkFax,default) as Fax_Phy,
			BA.AddressLine1 AddressLine1_Bill,
			isnull(BA.AddressLine2,'') AddressLine2_Bill,
			BA.CountryID CountryID_Bill,
			BA.StateID StateID_Bill,
			BA.City City_Bill,
			BA.Zip ZIp_Bill,
			dbo.fnc_FormatRemovalPhone(BA.WorkPhone,default) as Phone_Bill,
			BA.WorkExtn Extn_Bill,
			dbo.fnc_FormatRemovalPhone(BA.WorkFax,default) as Fax_Bill

		 from CWI_Vendor V
		INNER JOIN vw_CWI_Address PA
			ON PA.ID = V.AddressId_Physical
		INNER JOIN vw_CWI_Address BA
			ON BA.ID = V.AddressId_Billing

END

GO
