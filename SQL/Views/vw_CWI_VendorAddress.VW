/****** Object:  View [dbo].[vw_CWI_VendorAddress]    Script Date: 3/19/2014 8:52:57 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_VendorAddress]'))
DROP VIEW [dbo].[vw_CWI_VendorAddress]
GO
/****** Object:  View [dbo].[vw_CWI_VendorAddress]    Script Date: 3/19/2014 8:52:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_VendorAddress]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vw_CWI_VendorAddress]
AS
	SELECT 
		V.Id VendorId,
		VendorCode,
		VendorName,
		AddressId_Billing,
		AddressId_Physical,
		IsDeleted,
		V.LastUsedOn,
		V.Circulation,
		AP.StateID Physical_StateId, 
		SP.StateName Physical_StateName,
		AB.StateID Billing_StateId,    
		SB.StateName Billing_StateName,
		AP.City Physical_City,
		AB.City Billing_City,
		AP.Zip Physical_Zip,
		AB.Zip Billing_Zip,
		V.ClassificationLookupId,
		V.StatusLookupId,
		AP.WorkPhone Physical_WorkPhone,
		AB.WorkPhone Billing_WorkPhone
	from CWI_Vendor V (NOLOCK)
	INNER JOIN CWI_Address AP (NOLOCK)
		ON V.AddressId_Physical = AP.Id
	INNER JOIN [State] SP (NOLOCK)
		ON SP.ID = AP.StateID
	INNER JOIN CWI_Address AB (NOLOCK)
		ON V.AddressId_Billing = AB.Id
	INNER JOIN [State] SB (NOLOCK)
		ON SB.ID = AB.StateID' 
GO
