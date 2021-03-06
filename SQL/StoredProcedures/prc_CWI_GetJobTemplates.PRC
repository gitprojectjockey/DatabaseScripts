/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobTemplates]    Script Date: 2/12/2014 7:52:32 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobTemplates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobTemplates]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobTemplates]    Script Date: 2/12/2014 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobTemplates]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobTemplates
* Purpose : This PROC would be called TO get the Job template
* Invoked from : Child/Tasks.aspx
* CREATED: Saravanan M  11 Nov 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetJobTemplates @ClassificationLookupId=401
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetJobTemplates] 
@ClassificationLookupId Int
AS
BEGIN
	Select 
		distinct(TT.ID) as TaskTemplateId,
		TT.Name as TaskTemplateName
	From 
		CWI_TaskTemplate TT
	INNER JOIN
		CWI_JobTemplateClassification TTC
	ON 
		TT.Id=TTC.JobTemplateId WHERE TTC.ClassificationLookupId=@ClassificationLookupId AND TTC.IsDeleted=0;
END

' 
END
GO
