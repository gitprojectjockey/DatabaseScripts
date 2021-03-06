/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorsByCityState]    Script Date: 5/23/2014 6:39:31 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorsByCityState]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorsByCityState]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorsByCityState]    Script Date: 5/23/2014 6:39:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorsByCityState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorsByCityState  
* Purpose : This PROC would be called TO get vendors for city/state and classification
* Invoked from : VendorLookup.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetVendorsByCityState @search=''denver'', @ClassId = 401
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetVendorsByCityState]
	@search varchar(200),
	@ClassId int
AS
declare @distance decimal(18, 10) = 0
SET @search = ''%'' + @search+  ''%''

Select distinct 
			V.Id VendorId,
			V.VendorCode,
			VendorName ,
			LastUsedOn,
			Circulation,
			SP.StateName,
			AP.City,
			AP.Zip,
			z.Latitude  ,  z.Longitude ,
			@distance Distance 
from CWI_Vendor V (NOLOCK)
	INNER JOIN CWI_Address AP (NOLOCK)
		ON V.AddressId_Physical = AP.Id  AND V.StatusLookupId=  502
	INNER JOIN [State] SP (NOLOCK)
		ON SP.ID = AP.StateID
	INNER JOIN ZipCode z (nolock)
		ON z.ZipCode = AP.Zip
WHERE SP.StateName like @search OR AP.City like @search

ORDER BY VendorCode



' 
END
GO


