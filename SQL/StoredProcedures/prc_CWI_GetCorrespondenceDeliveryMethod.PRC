/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceDeliveryMethod]    Script Date: 10/22/2014 1:38:20 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceDeliveryMethod]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorrespondenceDeliveryMethod]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceDeliveryMethod]    Script Date: 10/22/2014 1:38:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceDeliveryMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/******************************************************************* ******************* 
* PROCEDURE: [prc_CWI_GetCorrespondenceDeliveryMethod]
* Purpose : This PROC would be called TO get delivery methods for correspondence
* Invoked from : Vendor Delivery
* CREATED:Bala 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

****************************************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetCorrespondenceDeliveryMethod] 701
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCorrespondenceDeliveryMethod]
   @CorrespondenceLookupId int

AS
BEGIN
	SELECT DeliveryMethodLookupId FROM CWI_CorrespondencedeliveryMethod WHERE CorrespondenceLookupId=@CorrespondenceLookupId AND IsActive=1 Order By DeliveryMethodLookupId
END














' 
END
GO
