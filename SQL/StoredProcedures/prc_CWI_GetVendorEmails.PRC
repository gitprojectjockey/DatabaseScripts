IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorEmails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorEmails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorEmails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorEmails
* Purpose : This PROC would be called TO get all the emails related to Vendor
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorEmails 5990,0,708
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorEmails]
    @VendorId int,  
	@DeliveryMethodLookupId int,
	@CorrespondenceLookupId int

AS


BEGIN

 SELECT distinct VC.Id ,Email [Name], ''EMail'' NameType, L.LookupName ContactType,'''' as IsAssociatedClients FROM CWI_VendorContact VC
INNER JOIN  Lookup  L ON L.Id = VC.ContactTypeLookupId
LEFT  JOIN  CWI_VendorCorrespondencedelivery VCD on VCD.VendorContactID=VC.ID
WHERE VendorId = @VendorId 
AND LTRIM(RTRIM(ISNULL(Email,''''))) <> '''' AND IsDeleted = 0 
UNION
SELECT 0,EMAILID,''EMail'','''', VCD.IsAssociatedClients FROM CWI_VendorCorrespondenceDelivery VCD
 Inner Join
	CWI_VendorCorrespondence VC ON VCD.VendorCorrespondenceID=vc.Id and vcd.VendorContactID is null and  VendorId=@VendorId AND LTRIM(RTRIM(ISNULL(EmailID,''''))) <> '''' --AND VCD.IsAssociatedClients=0
		 and VC.CorrespondenceLookupId =@CorrespondenceLookupId order by id desc;
		 --and VC.DeliveryMethodLookupId=@DeliveryMethodLookupId




END












' 
END
GO
