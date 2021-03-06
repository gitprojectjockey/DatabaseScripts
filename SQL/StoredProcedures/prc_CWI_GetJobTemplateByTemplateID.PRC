/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobTemplateByTemplateID]    Script Date: 2/12/2014 7:52:32 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobTemplateByTemplateID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobTemplateByTemplateID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobTemplateByTemplateID]    Script Date: 2/12/2014 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobTemplateByTemplateID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobTemplateByTemplateID  
* Purpose : This PROC would be called TO get the job template values 
			
* Invoked from : Jobs.aspx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

prc_CWI_GetJobTemplateByTemplateID @TemplateId=9
  
**********************************************************************/ 
 
CREATE PROC [dbo].[prc_CWI_GetJobTemplateByTemplateID]
	
	@TemplateId int
AS
BEGIN	


	select 
		TTF.Id TaskTemplateId, TF.FieldLabel, TF.TypeLookupId, TF.MinLength, TF.MaxLength, TF.IsRequiredCount,
		TF.RepeatCount,
		TF.ValidateMask,
		TF.ValidateFunction,
		ISNULL(TF.LookupTypeId,0) LookupTypeId,
		IsNULL(TF.Width,0) Width,
		TF.DefaultValue  ,
		'''' TaskTemplateName,
		CASE WHEN TF.LookupTypeId IS NOT NULL THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,1,''-Select-'') ELSE ListText END ListText,
		CASE WHEN TF.LookupTypeId IS NOT NULL THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,0,''0'') ELSE ListText END ListValue,
		'''' Value
	from CWI_TaskTemplate TT
	INNER JOIN  CWI_TaskTemplateField TTF
		ON TT.Id = TTF.TaskTemplateId --AND TT.ClassLookupId = @ClassLookupId
	INNER JOIN  CWI_TaskField TF
		ON TF.Id = TTF.TaskFieldId where TT.Id=@TemplateId
	 --AND TTD.TaskId = @TaskId
	ORDER BY TTF.DisplayOrder, TF.FieldLabel 

END



' 
END
GO
