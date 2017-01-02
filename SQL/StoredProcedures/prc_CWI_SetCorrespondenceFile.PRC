/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceFile]    Script Date: 4/24/2014 8:08:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceFile]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceFile]    Script Date: 4/24/2014 8:08:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetCorrespondenceFile 
* Purpose : This PROC would be called TO set correspondence file details
* Invoked from : CorrespondenceService
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetCorrespondenceFile 1, ''\\fileserver\folder\'', ''1.pdf''
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetCorrespondenceFile]
	@CorrespondenceId bigint,
	@FilePath varchar(1000),
	@File varchar(500)
AS

	UPDATE CWI_Correspondence SET FilePath = @FilePath, [File] = @File
	WHERE Id = @CorrespondenceId' 
END
GO


