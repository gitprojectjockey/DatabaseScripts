IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorContactClient]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorContactClient]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorContactClient]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorContactClient 
* Purpose : This PROC would be called to Get the customer(client) details 
* Invoked from :AssignCustomerToContact.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetVendorContactClient] @VendorContactId=11879
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorContactClient] 
	-- Add the parameters for the stored procedure here
	@VendorContactId int
	
AS
BEGIN
	
	SELECT VCC.[Id] AS ID
      ,VCC.[VendorContactId]
      ,C.ID as [ClientId]  
	  ,C.ClientCode
	  ,C.ClientName
      ,VCC.[IsDeleted]
      ,VCC.[CreatedBy]
	  ,U.Names as AssignedBy
      ,VCC.[CreatedOn]
      ,VCC.[ModifiedBy]
      ,VCC.[ModifiedOn]
  FROM [dbo].[CWI_VendorContactClient]  VCC
  
	INNER JOIN 
			CWI_VENDORCONTACT VC on VC.ID=VCC.[VendorContactId] and  VCC.VendorContactId=@VendorContactId and VCC.[IsDeleted]=0
	INNER JOIN
			CWI_VENDOR V ON V.Id=VC.VendorId
	INNER JOIN
 			CWI_Client C ON C.ID=VCC.ClientId
	INNER JOIN
			CWI_User U ON U.Id=VCC.CreatedBy;
	
END
' 
END
GO
