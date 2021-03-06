/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobSummaryTemplateData]    Script Date: 2/12/2014 7:52:32 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobSummaryTemplateData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobSummaryTemplateData]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobSummaryTemplateData]    Script Date: 2/12/2014 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobSummaryTemplateData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobSummaryTemplateData  
* Purpose : This PROC would be called TO get the rundate template values 
			for job classification related to the jobsummary 
* Invoked from : jobs.aspx
* CREATED: Saravanan M
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetJobSummaryTemplateData @JobId = 13343, @ClassificationLookupId = 401 
**********************************************************************/  
CREATE PROC [dbo].[prc_CWI_GetJobSummaryTemplateData]
	@JobId bigint = NULL,
	@ClassificationLookupId int  = NULL
AS
BEGIN
	SET @JobId=  ISNULL(@JobId,0) 
	SET @ClassificationLookupId = ISNULL(@ClassificationLookupId,0)

	SELECT 
		TTF.Id TaskTemplateId, TF.FieldLabel, TF.TypeLookupId, TF.MinLength, TF.MaxLength, TF.IsRequiredCount,
		TF.RepeatCount,
		TF.ValidateMask,
		TF.ValidateFunction,
		'''' TaskTemplateName,
		ISNULL(TF.LookupTypeId,0) LookupTypeId,
		IsNULL(TF.Width,0) Width,
		TF.DefaultValue  ,
		CASE WHEN TF.LookupTypeId IS NOT NULL THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,1,''-Select-'') ELSE ISNULL(ListText,'''') END ListText,
		CASE WHEN TF.LookupTypeId IS NOT NULL THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,0,''0'') ELSE ISNULL(ListText,'''') END ListValue,
		TTD.FieldValue Value
	FROM CWI_TaskTemplate TT
	INNER JOIN 
		CWI_JobTemplateClassification TTC
		ON	TTC.JobTemplateId=TT.Id AND TTC.ClassificationLookupId = @ClassificationLookupId AND TTC.IsDeleted=0
	INNER JOIN  CWI_TaskTemplateField TTF
		ON TT.Id = TTF.TaskTemplateId --AND TT.Id = @inTemplateId
	INNER JOIN  CWI_TaskField TF
		ON TF.Id = TTF.TaskFieldId
	Inner JOIN CWI_JobSummaryTemplateData TTD
		ON TTD.TemplateFieldId = TTF.Id AND TTD.JobId = @JobId		
	ORDER BY TTF.DisplayOrder, TF.FieldLabel

END
' 
END
GO
