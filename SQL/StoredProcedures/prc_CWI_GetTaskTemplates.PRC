/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskTemplates]    Script Date: 11/21/2013 3:30:24 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskTemplates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskTemplates]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskTemplates]    Script Date: 11/21/2013 3:30:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskTemplates]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetTaskTemplates
* Purpose : This PROC would be called TO get the task template
* Invoked from : Child/Tasks.aspx
* CREATED: Saravanan M  11 Nov 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTaskTemplates @ClassificationLookupId=401
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetTaskTemplates] 
@ClassificationLookupId Int
AS
BEGIN
	Select 
		distinct(TT.ID) as TaskTemplateId,
		TT.Name as TaskTemplateName
	From 
		CWI_TaskTemplate TT
	INNER JOIN
		CWI_TaskTemplateClassification TTC
	ON 
		TT.Id=TTC.TaskTemplateId WHERE TTC.ClassificationLookupId=@ClassificationLookupId AND TTC.IsDeleted=0;
END
' 
END
GO
