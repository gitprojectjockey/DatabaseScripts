/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAdcopyToProcess]    Script Date: 7/28/2014 2:29:54 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAdcopyToProcess]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetAdcopyToProcess]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAdcopyToProcess]    Script Date: 7/28/2014 2:29:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAdcopyToProcess]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetAdcopyToProcess 
* Purpose : This PROC would be called to return the ad copies to process
* Invoked from : CorrespondenceService
* CREATED: MohanKumar 03JUN14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  28JUL14	Mohankumar		Quote is handled
**********************************************************************  
Execution example :
**********************************************************************  
  prc_CWI_GetAdcopyToProcess 

**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetAdcopyToProcess]

AS

SELECT JobId, AdCopyFileName 
FROM CWI_Job J
INNER JOIN  CWI_JobNewspaper JN
	ON J.Id = JN.JobId
WHERE 
AdCopyFileName like ''%.doc%''
AND 
(
	(IsQuote = 0 AND J.JobStatusLookupId IN (8001/*In Progress*/,8012/* Assigned */, 8002 /* Awaiting Invoice Authorization */))
	OR 
	(IsQuote = 1 AND InvoiceDate > getdate()-30)
)
ORDER BY IsQuote, J.Id
' 
END
GO


