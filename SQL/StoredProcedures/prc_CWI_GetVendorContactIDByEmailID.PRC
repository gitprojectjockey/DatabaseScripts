IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorContactIDByEmailID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorContactIDByEmailID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorContactIDByEmailID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorContactIDByEmailID 
* Purpose : This PROC would be called to Get the VendorContactID
* Invoked from :AssignCustomerToContact.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetVendorContactIDByEmailID] @Email=''''
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorContactIDByEmailID]
	@Email varchar(200)
AS
BEGIN
	SELECT TOP 1 VC.ID as VendorContactId from CWI_VendorContact VC
INNER JOIN
	CWI_VendorContactClient VCC ON VC.Id=VCC.VendorContactId and VC.Email=@Email and VC.IsDeleted=0 and VCC.IsDeleted=0;
END
' 
END
GO
