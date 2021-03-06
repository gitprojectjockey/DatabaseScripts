/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorsByZipCodes]    Script Date: 5/23/2014 6:36:44 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorsByZipCodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorsByZipCodes]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorsByZipCodes]    Script Date: 5/23/2014 6:36:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorsByZipCodes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorsByZipCodes  
* Purpose : This PROC would be called TO get vendors for the zipcode and classification
* Invoked from : VendorLookup.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetVendorsByZipCodes @ZipCode=''37027'', @ClassId = 401
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetVendorsByZipCodes]
	@ZipCode varchar(MAX),
	@ClassId int
AS

declare @distance decimal(18, 10) = 0
Select distinct 
			V.Id VendorId,
			V.VendorCode,
			VendorName ,
			LastUsedOn,
			Circulation,
			SP.StateName,
			AP.City,
			AP.Zip,
			z.Latitude  ,  z.Longitude  ,
			@distance Distance
from CWI_Vendor V (NOLOCK)
	INNER JOIN CWI_Address AP (NOLOCK)
		ON V.AddressId_Physical = AP.Id AND V.StatusLookupId=  502
	INNER JOIN [State] SP (NOLOCK)
		ON SP.ID = AP.StateID
	INNER JOIN ZipCode z (nolock)
		ON z.ZipCode = AP.Zip
	WHERE AP.Zip in (select * from dbo.fnc_utl_Split(@ZipCode,'',''))
		AND V.ClassificationLookupId = @ClassId
ORDER BY VendorCode


' 
END
GO


