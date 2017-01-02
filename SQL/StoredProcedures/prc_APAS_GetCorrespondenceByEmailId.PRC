/****** Object:  StoredProcedure [dbo].[prc_APAS_GetCorrespondenceByEmailId]    Script Date: 8/21/2014 2:36:32 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetCorrespondenceByEmailId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_GetCorrespondenceByEmailId]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_GetCorrespondenceByEmailId]    Script Date: 8/21/2014 2:36:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetCorrespondenceByEmailId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_APAS_GetCorrespondenceByEmailId  
* Purpose : This PROC would be called TO get the correspondence details by correspondence email id
* Invoked from : PaperCostWizard.aspx
* CREATED: MohanKumar Sundaram 31JUL14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

prc_APAS_GetCorrespondenceByEmailId 821
  
**********************************************************************/ 
--
CREATE PROC [dbo].[prc_APAS_GetCorrespondenceByEmailId]
	@corresDeliveryId bigint
AS

SELECT C.JobMediaBuyId, C.MMRPO, V.VendorCode, V.VendorName,
	C.CorrespondenceTypeLookupId, C.StatusLookupId, CD.DeliveryStatusLookupId , CD.DeliveryMethodLookupId,
	U.Names SubmitterName,
	U.Email SubmitterEmail
FROM CWI_Correspondence C
INNER JOIN CWI_CorrespondenceDelivery CD
ON C.Id = CD.CorrespondenceId
INNER JOIN CWI_Vendor V
	ON V.Id = C.VendorId
INNER JOIN CWI_User U
	ON U.Id = CD.CreatedBy
WHERE
	CD.Id = @corresDeliveryId


' 
END
GO


