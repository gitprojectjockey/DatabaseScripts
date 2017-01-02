/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorsByPoints]    Script Date: 5/23/2014 6:44:02 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorsByPoints]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorsByPoints]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorsByPoints]    Script Date: 5/23/2014 6:44:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorsByPoints]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorsByPoints  
* Purpose : This PROC would be called TO get vendors for classification within the distance
* Invoked from : VendorLookup.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetVendorsByPoints @Latitude=39.818029,@Longitude=-104.779357,@Distance=32,@unit=''Miles'',@ClassId=401
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetVendorsByPoints]
	@Latitude decimal(9,6),
	@Longitude decimal(9,6),
	@Distance float = 50,
	@unit varchar(20) = ''Kilometers'',
	@ClassId int
AS


SELECT 
	distinct 
	V.VendorId VendorId,
	V.VendorCode,
	VendorName ,
	LastUsedOn,
	Circulation,
	v.Physical_StateName StateName,
	v.Physical_City City,
	v.Physical_Zip Zip,
	zips.Latitude  ,  
	zips.Longitude ,
	dbo.CalculateDistance(@Latitude, @Longitude, [zips].[Latitude], [zips].[Longitude], @unit) AS Distance
FROM dbo.zipcode AS [zips]
	INNER JOIN vw_CWI_VendorAddress AS v ON [zips].[ZIPCode] = v.Physical_Zip AND V.ClassificationLookupId = @ClassId AND V.StatusLookupId=  502
	INNER JOIN [dbo].[Calculateboundary](@Latitude, @Longitude, @Distance, @unit) AS [bounds]
		ON 1=1
WHERE 
	[zips].[Latitude] BETWEEN [bounds].[South] AND [bounds].[North]
	AND [zips].[Longitude] BETWEEN [bounds].[West] AND [bounds].[East]
	AND [zips].[CityType] = ''D'' -- only one result per ZIP
	AND [zips].[Latitude] <> 0
	AND [zips].[Longitude] <> 0
	AND [dbo].[CalculateDistance](@Latitude, @Longitude,[zips].[Latitude], [zips].[Longitude], @unit) <= @Distance
	AND v.Physical_Zip = [zips].[ZIPCode]
	--and [Papers].Activate = 1
ORDER BY Distance, VendorCode

' 
END
GO


