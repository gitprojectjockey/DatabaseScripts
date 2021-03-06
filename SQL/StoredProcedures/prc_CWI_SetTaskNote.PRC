/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTaskNote]    Script Date: 10/29/2013 1:47:47 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTaskNote]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetTaskNote]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTaskNote]    Script Date: 10/29/2013 1:47:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTaskNote]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetTaskNote
* Purpose : This PROC would be called TO insert the summary/notefor task
* Invoked from : Child/Tasks.aspx
* CREATED: Mohankumar Sundaram  23 OCT 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetTaskNote 1, 1,''Test SUmmary'',3
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetTaskNote]
	@IsSummary bit,
	@TaskId bigint,
	@Note varchar(max),
	@Author int
AS

INSERT CWI_TaskNote
(
	IsSummary, TaskId, 
	Note, CreatedBy, CreatedOn
)
VALUES 
( @IsSummary, @TaskId, @Note, @Author, getdate())
' 
END
GO
