/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceDeliveryEmails]    Script Date: 4/10/2014 2:40:50 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceDeliveryEmails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorrespondenceDeliveryEmails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceDeliveryEmails]    Script Date: 4/10/2014 2:40:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceDeliveryEmails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetCorrespondenceDeliveryEmails
* Purpose : This PROC would be called TO get all the emails related to Vendor
* Invoked from : Manage Correspondence - Email Popup
* CREATED:Bala 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetCorrespondenceDeliveryEmails 5990,801(Email),701(Insertion Order)
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCorrespondenceDeliveryEmails]
    @JobMediaBuyId int,  
	@DeliveryMethodLookupId int,
	@CorrespondenceLookupId int

AS
BEGIN
	DECLARE @VendorId int
	SELECT @VendorId=VendorId FROM CWI_JobMediaBuy WHERE ID=@JobMediaBuyId

	SELECT distinct VC.Id ,Email [Name]  FROM CWI_VendorContact VC
	INNER JOIN  Lookup  L ON L.Id = VC.ContactTypeLookupId
	LEFT  JOIN  CWI_VendorCorrespondencedelivery VCD on VCD.VendorContactID=VC.ID
	WHERE VendorId = @VendorId 
	AND LTRIM(RTRIM(ISNULL(Email,''''))) <> '''' AND IsDeleted = 0 
	UNION
	SELECT 0,EMAILID FROM CWI_VendorCorrespondenceDelivery VCD
	 Inner Join
		CWI_VendorCorrespondence VC ON VCD.VendorCorrespondenceID=vc.Id and vcd.VendorContactID is null and  VendorId=@VendorId AND LTRIM(RTRIM(ISNULL(EmailID,''''))) <> '''' --AND VCD.IsAssociatedClients=0
			 and VC.CorrespondenceLookupId =@CorrespondenceLookupId order by id desc;
			 --and VC.DeliveryMethodLookupId=@DeliveryMethodLookupId

END













' 
END
GO
