/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskTemplateData]    Script Date: 7/10/2014 6:58:08 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskTemplateData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskTemplateData]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskTemplateData]    Script Date: 7/10/2014 6:58:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskTemplateData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetTaskTemplateData  
* Purpose : This PROC would be called TO get the task template values 
			for job classification related task
* Invoked from : Tasks.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetTaskTemplateData @TaskId = NULL, @TemplateId = 2
prc_CWI_GetTaskTemplateData @TaskId = 10111, @TemplateId = 0

  
**********************************************************************/ 
 
CREATE PROC [dbo].[prc_CWI_GetTaskTemplateData]
	@TaskId bigint = NULL,
	@TemplateId int  = NULL
AS
BEGIN
	SET @TaskId=  ISNULL(@TaskId,0) 
	SET @TemplateId = ISNULL(@TemplateId,0)

	select 
		distinct(TTF.Id) as TaskTemplateId, TF.FieldLabel, TF.TypeLookupId, TF.MinLength, TF.MaxLength, TF.IsRequiredCount,
		TF.RepeatCount,
		TF.ValidateMask,
		TF.ValidateFunction,
		'''' TaskTemplateName,
		ISNULL(TF.LookupTypeId,0) LookupTypeId,
		IsNULL(TF.Width,0) Width,
		TF.DefaultValue  ,
		CASE WHEN TF.LookupTypeId IS NOT NULL THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,1,''-Select-'') ELSE ISNULL(ListText,'''') END ListText,
		CASE WHEN TF.LookupTypeId IS NOT NULL THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,0,''0'') ELSE '''' END ListValue,
		TTD.FieldValue Value
	from CWI_TaskTemplate TT
	INNER JOIN 
		CWI_TaskTemplateClassification TTC
		ON	TTC.TaskTemplateId=TT.Id AND TTC.IsDeleted=0
	INNER JOIN  CWI_TaskTemplateField TTF
		ON TT.Id = TTF.TaskTemplateId AND TT.Id = @TemplateId--CASE WHEN @TemplateId=0 THEN TT.Id ELSE @TemplateId END
	INNER JOIN  CWI_TaskField TF
		ON TF.Id = TTF.TaskFieldId
	LEFT OUTER JOIN CWI_TaskTemplateData TTD
		ON TTD.TemplateFieldId = TTF.Id AND TTD.TaskId = @TaskId
	--ORDER BY TTF.DisplayOrder, TF.FieldLabel

END
' 
END
GO


