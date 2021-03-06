/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorProfile]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorProfile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorProfile]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorProfile]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorProfile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorProfile  
* Purpose : This PROC would be called TO get the vendor profile data
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorProfile 10
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorProfile]
    @VendorId int
AS
    SELECT Circulation, isnull(MediaKitURL,'''') MediaKitURL, LC.IsActive IsClassActive   from CWI_Vendor V
	INNER JOIN vw_CWI_Classification LC ON V.ClassificationLookupId = LC.Id
	WHERE V.Id = @VendorId

' 
END
GO
