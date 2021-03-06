/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorProfile]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorProfile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorProfile]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorProfile]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorProfile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorProfile  
* Purpose : This PROC would be called TO save vendor profile
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetVendorProfile 3,1000,''www.xerox.com''
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetVendorProfile]
    @VendorId int,
    @Circulation	int,
    @MediaKitURL varchar(100)
AS
BEGIN
	BEGIN TRY

		UPDATE CWI_Vendor SET Circulation = @Circulation, MediaKitURL = @MediaKitURL
		WHERE ID = @VendorId

		
	END TRY

	BEGIN CATCH
		EXEC prc_CWI_AppRaiseError; 
		THROW;
	END CATCH

END


' 
END
GO
