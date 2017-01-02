/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceDetails]    Script Date: 9/17/2014 7:09:15 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorrespondenceDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceDetails]    Script Date: 9/17/2014 7:09:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetCorrespondenceDetails 
* Purpose : This PROC would be called TO return the correspondence delivery details
* Invoked from : CorrespondenceService
* CREATED: MohanKumar Sundaram	16SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  


**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetCorrespondenceDetails 1, 3 
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetCorrespondenceDetails]
	@corresDeliveryId bigint
AS
BEGIN
	SET NOCOUNT ON
	select 
		C.MMRPO,
		V.VendorName,
		D.ClientCode + '' - '' + D.ClientName Division,
		LS.LookupName StatusName,
		LM.LookupName MethodName,
		LC.LookupName CorrespondenceName,
		C.StatusLookupId,
		CD.DeliveryStatusLookupId,
		(CD.IsTrashed | C.IsTrashed) IsTrashed
	from CWI_Correspondence C
	INNER JOIN CWI_CorrespondenceDelivery CD
		On C.Id = CD.CorrespondenceId
	INNER JOIN CWI_Vendor V
		ON V.Id = C.VendorId
	INNER JOIN CWI_Client D
		ON D.Id = C.ClientId
	INNER JOIN Lookup LS
		ON LS.Id = CD.DeliveryStatusLookupId
	INNER JOIN Lookup LM
		ON LM.Id = CD.DeliveryMethodLookupId
	INNER JOIN Lookup LC
		ON LC.Id = C.CorrespondenceTypeLookupId
	WHERE
		CD.Id = @corresDeliveryId
	SET NOCOUNT OFF
END' 
END
GO


