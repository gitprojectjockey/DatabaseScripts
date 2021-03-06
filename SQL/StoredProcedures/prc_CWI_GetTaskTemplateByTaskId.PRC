/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskTemplateByTaskId]    Script Date: 7/10/2014 6:58:49 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskTemplateByTaskId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskTemplateByTaskId]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskTemplateByTaskId]    Script Date: 7/10/2014 6:58:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskTemplateByTaskId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetTaskTemplateByTaskId
* Purpose : This PROC would be called TO get the task template
* Invoked from : Child/Tasks.aspx
* CREATED: Saravanan M  21 Nov 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTaskTemplateByTaskId @TaskId=10108
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetTaskTemplateByTaskId] 
@TaskId BigInt
AS
BEGIN
SELECT TOP 1 TT.Id as TaskTemplateId,
	'''' TaskTemplateName 
	FROM 
		CWI_TaskTemplate TT
INNER JOIN
		CWI_TaskTemplateField TTF
	on 
		TT.Id=TTF.TaskTemplateId
INNER JOIN
		CWI_TaskField TF
	ON
		TTF.TaskFieldId=TF.Id 
INNER JOIN	
		CWI_TaskTemplateData TTD
	ON
		TTD.TemplateFieldId=TTF.Id AND TTD.TaskId=@TaskId;
END

' 
END
GO


