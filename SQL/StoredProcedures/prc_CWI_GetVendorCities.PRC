/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorCities]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorCities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorCities]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorCities]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorCities]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorCities
* Purpose : This PROC would be called TO fetch List of cities from Vendro table
* Invoked from : VendorLookup.aspx  
* CREATED: MohanKumar SUndaram
* CREATED ON : 27May2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
[prc_CWI_GetVendorCities]
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorCities]    
AS
BEGIN
	SELECT distinct AP.City from CWI_Vendor V
	INNER JOIN CWI_Address AP
	ON V.AddressId_Physical = AP.Id
END
	
' 
END
GO
