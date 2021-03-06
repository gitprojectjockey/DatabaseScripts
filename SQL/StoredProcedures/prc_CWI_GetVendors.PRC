IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendors]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendors]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendors 
* Purpose : This PROC would be called TO get all the active and pending vendors 
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendors
  
**********************************************************************/ 
  
CREATE PROC [dbo].[prc_CWI_GetVendors]
AS
BEGIN
	
	select 
		V.Id,
		VendorCode, 
		VendorName,
		A.StateName,
		A.City,
		A.StateName+''/''+A.City PhysicalAddress,
		ISNULL(LKT.LookupName,'''') VendorType,
		ISNULL(LKG.LookupName,'''') VendorGroup,
		LKC.LookupName Classification, 
		LKS.LookupName [Status], 
		U.Names,
		V.CreatedOn,
		LastUsedOn
	from CWI_Vendor V (NOLOCK)
	INNER JOIN vw_CWI_Address A (NOLOCK) ON A.ID = V.AddressId_Physical
	INNER JOIN Lookup LKS (NOLOCK) ON LKS.ID = V.StatusLookupId
	INNER JOIN Lookup LKC (NOLOCK) ON LKC.ID = V.ClassificationLookupId
	INNER JOIN CWI_User U (NOLOCK) ON u.Id = V.CreatedBy
	LEFT OUTER JOIN Lookup LKT (NOLOCK) ON LKT.ID = V.VendorTypeLookUpId
	LEFT OUTER JOIN Lookup LKG (NOLOCK) ON LKG.ID = V.VendorGroupLookupId
	WHERE  V.IsDeleted = 0 -- other tahn deleted
	ORDER BY
		
		A.StateName,A.City, LKC.LookupName --Classification
	
		
END





' 
END
GO


