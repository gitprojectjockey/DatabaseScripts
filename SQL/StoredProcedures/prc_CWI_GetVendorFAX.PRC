IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorFAX]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorFAX]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorFAX]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorFAX
* Purpose : This PROC would be called TO get all the Fax related to Vendor
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorFAX 7072,803,701
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorFAX]
    @VendorId int  ,
	@DeliveryMethodLookupId int,
	@CorrespondenceLookupId int

AS

SELECT distinct dbo.fnc_FormatRemovalPhone(Fax,default) as Fax, ''Fax'' NameType ,'''' ContactType,0 Id  FROM CWI_VendorContact VC
WHERE VendorId = @VendorId
AND LTRIM(RTRIM(ISNULL(Fax,''''))) <> '''' AND IsDeleted = 0
UNION 
SELECT dbo.fnc_FormatRemovalPhone(WorkFax,default) as WorkFax, ''Fax'' NameType, '''' ContactType,0 Id FROM CWI_Vendor V INNER JOIN  CWI_Address BA ON V.AddressId_Billing = BA.ID
WHERE V.Id = @VendorId
AND LTRIM(RTRIM(ISNULL(WorkFax,''''))) <> ''''
UNION 
SELECT dbo.fnc_FormatRemovalPhone(WorkFax,default) as WorkFax, ''Fax'' NameType, '''' ContactType,0 Id FROM CWI_Vendor V INNER JOIN  CWI_Address PA ON V.AddressId_Physical = PA.ID
WHERE V.Id = @VendorId
AND LTRIM(RTRIM(ISNULL(WorkFax,''''))) <> '''' 

UNION
SELECT VC.Fax,''Fax'' NameType,'''' ContactType, 0 Id FROM CWI_VendorCorrespondence VC
 Inner Join
	CWI_Vendor V ON V.id=vc.VendorId and VendorId=@VendorId and VC.Fax is not null  AND LTRIM(RTRIM(ISNULL(Fax,''''))) <> ''''
		AND VC.DeliveryMethodLookupId=@DeliveryMethodLookupId and VC.CorrespondenceLookupId =@CorrespondenceLookupId; --order by VC.id desc;

' 
END
GO
