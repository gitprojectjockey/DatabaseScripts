/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskAttachment]    Script Date: 7/10/2014 7:00:40 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskAttachment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskAttachment]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskAttachment]    Script Date: 7/10/2014 7:00:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskAttachment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetTaskAttachment
* Purpose : This PROC would be called TO get Task Assignments for a task
* Invoked from : Task.aspx 
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTaskAttachment @TaskId=10130
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetTaskAttachment] 
	@TaskId bigint 
AS
BEGIN
	SELECT 
		JA.Id,
	    [FileName],
		FilePath,
		Attachtomail,
		U.Names as CreatedBy,
		JA.CreatedOn,
		JA.ModifiedOn 
	FROM  CWI_TaskAttachment JA
	LEFT OUTER JOIN CWI_User U ON U.id = JA.CreatedBy
	WHERE TaskId = @TaskId 
	AND JA.IsRemoved = 0
		
END


' 
END
GO


