/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceDelivery]    Script Date: 5/1/2014 9:35:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceDelivery]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorrespondenceDelivery]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceDelivery]    Script Date: 5/1/2014 9:35:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceDelivery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetCorrespondenceDelivery 
* Purpose : This PROC would be called TO get all correspondence delivery
* Invoked from : CorrespondenceService
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetCorrespondenceDelivery 1
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetCorrespondenceDelivery]
	@CorrespondenceId bigint
AS

	SELECT D.*, T.TemplateFile, T.TemplateSubject FROM
	(
		SELECT *
		FROM CWI_CorrespondenceDelivery CD
		WHERE CorrespondenceId = @CorrespondenceId
		AND CD.DeliveryStatusLookupId IN (3155, 3153, 3152) /* Queued, Error, Pending */ 
		AND IsTrashed = 0
		AND AttemptNo<10
	)  D
	LEFT OUTER JOIN
			CWI_EmailTemplate T
				ON D.EmailTemplateId = T.Id


' 
END
GO


