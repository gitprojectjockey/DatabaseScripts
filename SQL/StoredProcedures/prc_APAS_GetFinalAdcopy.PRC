/****** Object:  StoredProcedure [dbo].[prc_APAS_GetFinalAdcopy]    Script Date: 8/19/2014 3:17:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetFinalAdcopy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_GetFinalAdcopy]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_GetFinalAdcopy]    Script Date: 8/19/2014 3:17:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetFinalAdcopy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_APAS_GetFinalAdcopy
* Purpose : This PROC would be called TO get final ad copy
* Invoked from : PaperCostWizard.aspx
* CREATED: MohanKumar Sundaram 12AUG14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_APAS_GetFinalAdcopy 3336
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_APAS_GetFinalAdcopy] 
    @mediaBuyId bigint,
    @FinalAdCopyFileName varchar(max) OUTPUT 
AS
   SELECT @FinalAdCopyFileName = FinalAdCopyFileName FROM CWI_JobMediaBuy WHERE Id = @mediaBuyId' 
END
GO


