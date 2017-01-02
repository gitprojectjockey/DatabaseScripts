/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondence]    Script Date: 10/17/2014 3:47:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorrespondence]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondence]    Script Date: 10/17/2014 3:47:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetCorrespondence 
* Purpose : This PROC would be called TO get all the initiated/failed/pending correspondences
* Invoked from : CorrespondenceService
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  02JUN14	Mohankumar		Filepath and File returned 
  16JUN14	Mohankumar		IsReadyToProcess added in where condition to process the correspondence once creadit card number got from CITI

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetCorrespondence
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetCorrespondence]
	
AS

select 
	Id,
	JobId,
	MMRPO,
	CorrespondenceTypeLookupId,
	VendorId,
	ClientId,
	InvoiceDate,
	StatusLookupId,
	CreatedBy,
	cast(1 as bit) IsFullDelivery,
	C.FilePath,
	C.[File]
	
from CWI_Correspondence C
Where (StatusLookupId = 3101 /* Pending */
	OR C.[File] IS NULL)
	AND AttemptNo<10
	AND C.IsTrashed = 0
	AND C.IsReadyToProcess = 1
UNION 
select 
	distinct
	C.Id,
	JobId,
	MMRPO,
	CorrespondenceTypeLookupId,
	VendorId,
	ClientId,
	InvoiceDate,
	StatusLookupId,
	C.CreatedBy,
	cast(0 as bit) IsFullDelivery,
	C.FilePath,
	C.[File]
from CWI_Correspondence C
INNER JOIN CWI_CorrespondenceDelivery CD
	ON C.Id = CD.CorrespondenceId
WHERE
	C.IsTrashed = 0
	AND CD.IsTrashed = 0
	AND CD.DeliveryStatusLookupId IN (3152, 3153) /* Pending, Failed */
	AND NOT (StatusLookupId = 3101 /* Pending */ OR C.[File] IS NULL)
	AND C.AttemptNo<10
	AND CD.AttemptNo<10
	AND C.IsReadyToProcess = 1
	AND CD.DeliveryMethodLookupId <> 804 /*fax*/

UNION 
select 
	distinct
	C.Id,
	JobId,
	MMRPO,
	CorrespondenceTypeLookupId,
	VendorId,
	ClientId,
	InvoiceDate,
	StatusLookupId,
	C.CreatedBy,
	cast(0 as bit) IsFullDelivery,
	C.FilePath,
	C.[File]
from CWI_Correspondence C
INNER JOIN CWI_CorrespondenceDelivery CD
	ON C.Id = CD.CorrespondenceId
WHERE
	C.IsTrashed = 0
	AND CD.IsTrashed = 0
	AND CD.DeliveryStatusLookupId IN (3152, 3153) /* Pending, Failed */
	AND NOT (StatusLookupId = 3101 /* Pending */ OR C.[File] IS NULL)
	AND C.AttemptNo<10
	AND CD.AttemptNo<10
	AND C.IsReadyToProcess = 1
	AND CD.DeliveryMethodLookupId = 804 /*fax*/
	AND CD.SentOn IS  NULL 


' 
END
GO


