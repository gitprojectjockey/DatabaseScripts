/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceEmailAttachments]    Script Date: 9/17/2014 7:05:43 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceEmailAttachments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorrespondenceEmailAttachments]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceEmailAttachments]    Script Date: 9/17/2014 7:05:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceEmailAttachments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCorrespondenceEmailAttachments
* Purpose : This PROC would be called TO get the emails attachemnts of correspondence email delivery
* Invoked from : CorrespondeceService
* CREATED: MohanKumar Sundaram 16SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetCorrespondenceEmailAttachments 8351
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCorrespondenceEmailAttachments]
    @corresDeliveryId bigint
AS

SELECT * FROM  CWI_CorrespondenceEmailAttachment
WHERE CorrespondenceDeliveryId = @corresDeliveryId' 
END
GO


