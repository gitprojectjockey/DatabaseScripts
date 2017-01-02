/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorZipcodesByPolygon]    Script Date: 5/23/2014 6:47:35 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorZipcodesByPolygon]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorZipcodesByPolygon]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorZipcodesByPolygon]    Script Date: 5/23/2014 6:47:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorZipcodesByPolygon]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorZipcodesByPolygon  
* Purpose : This PROC would be called TO get the zipcodes within the polygon area
* Invoked from : VendorLookup.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorZipcodesByPolygon 
  
**********************************************************************/ 
  

CREATE PROCEDURE [dbo].[prc_CWI_GetVendorZipcodesByPolygon]
	@LngLatArray varchar(MAX)
AS


DECLARE @g geometry;
	DECLARE @h geometry;
	SET @g = geometry::STGeomFromText(''POLYGON(('' + @LngLatArray + ''))'', 0);
	SET @g = @g.MakeValid();

	

	select x.*, Latitude, Longitude, CityName, ProvinceName State, CountryName from
	(
	select distinct  ZipCode from ZipCode zips WITH (INDEX(SAD_GEOMETRY_SIDX))
	where  --@g.STContains(GeomLatLng) <>0
	GeomLatLng.STIntersects(@g) = 1 
	--GeomLatLng.Filter(@g) = 1
	) x
	inner join  ZipCode z ON z.ZipCode = x.ZipCode and CityType = ''D''

	Order by x.ZipCode

' 
END
GO


