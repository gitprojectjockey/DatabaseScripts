IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorCorrespondenceFTP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorCorrespondenceFTP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorCorrespondenceFTP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorCorrespondenceFTP
* Purpose : This PROC would be called to Add or Modify the contact FTP Details
* Invoked from :Vendor.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetVendorCorrespondenceFTP] 
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorCorrespondenceFTP] 
	@VendorCorrespondenceID int,
	@CorrespondenceLookupId int
AS
BEGIN
	SELECT VCF.[Id]
		  ,VCF.[Server]
		  , VCF.[Port]
		  ,VCF.[UserName]
		  ,VCF.[Password]
		  ,VCF.[VendorCorrespondenceID]
      
	FROM [dbo].[CWI_VendorCorrespondenceFTP] VCF
	INNER JOIN 
		CWI_VendorCorrespondence VC ON VCF.[VendorCorrespondenceID]=VC.Id Where VCF.[VendorCorrespondenceID]=@VendorCorrespondenceID
AND VC.CorrespondenceLookupId=@CorrespondenceLookupId;

END
' 
END
GO
