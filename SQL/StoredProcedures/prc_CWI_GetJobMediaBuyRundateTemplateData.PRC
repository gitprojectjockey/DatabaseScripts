/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediaBuyRundateTemplateData]    Script Date: 5/13/2014 10:15:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediaBuyRundateTemplateData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobMediaBuyRundateTemplateData]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediaBuyRundateTemplateData]    Script Date: 5/13/2014 10:15:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediaBuyRundateTemplateData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobMediaBuyRundateTemplateData  
* Purpose : This PROC would be called TO get the rundate template values 
			for job classification related to the media buy
* Invoked from : UC_JobMediaBuyRundate.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetJobMediaBuyRundateTemplateData @inMediaBuyId = 3001, @inClassificationLookupId = 0 
**********************************************************************/  
CREATE PROC [dbo].[prc_CWI_GetJobMediaBuyRundateTemplateData]
	@inMediaBuyId bigint = NULL,
	@inClassificationLookupId int  = NULL
AS
BEGIN
	SET @inMediaBuyId=  ISNULL(@inMediaBuyId,0) 
	
	DECLARE @inJobId BIGINT
	SET @inJobId= (SELECT JobId FROM CWI_JobMediaBuy WHERE ID=@inMediaBuyId)

	DECLARE @tblJMB TABLE 
	(
		Id bigint,
		TaskTemplateId int,
		TaskFieldId int,
		FieldValue varchar(max),
		DisplayOrder int

	)

	INSERT INTO @tblJMB
	SELECT 
		TD.Id,
		TTF.Id ,
		TF.Id TaskFieldId, 
		TD.FieldValue ,
		DisplayOrder
	FROM CWI_JobMediaBuyRundateTemplateData TD
	INNER JOIN CWI_TaskTemplateField TTF
		ON TTF.Id = TD.TemplateFieldId
	INNER JOIN CWI_TaskField TF
		ON TTF.TaskFieldId = TF.Id
	WHERE TD.MediaBuyId = @inMediaBuyId 
	AND TF.MappingLookupId IN (20201) /* Ad Rundate */


	IF EXISTS (SELECT TOP 1 1 FROM @tblJMB) /* If rundates available for media buy, ignore job level run dates */
	BEGIN
		
		SELECT 
			TF.Id TaskFieldId,
			t.FieldValue,
			t.TaskTemplateId, 
			TF.FieldLabel, 
			TF.TypeLookupId, TF.MinLength, TF.MaxLength, TF.IsRequiredCount,
			TF.RepeatCount,
			TF.ValidateMask,
			TF.ValidateFunction,
			'''' TemplateName,
			ISNULL(TF.LookupTypeId,0) LookupTypeId,
			IsNULL(TF.Width,0) Width,
			TF.DefaultValue  ,
			CASE WHEN TF.LookupTypeId IS NOT NULL 
				THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,1,''-Select-'') 
				ELSE ISNULL(ListText,'''') END ListText,
			CASE WHEN TF.LookupTypeId IS NOT NULL 
				THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,0,''0'') 
				ELSE '''' END ListValue,
			t.DisplayOrder,
			t.FieldValue value
		FROM @tblJMB t
		INNER JOIN CWI_TaskField TF
			ON t.TaskFieldId = TF.Id
		
		
		
		
		
		ORDER BY t.DisplayOrder, TF.FieldLabel
		
		RETURN		
	END

	SELECT 
		TF.Id TaskFieldId,
		TD.FieldValue,
		TTF.Id TaskTemplateId, 
		TF.FieldLabel, 
		TF.TypeLookupId, TF.MinLength, TF.MaxLength, TF.IsRequiredCount,
		TF.RepeatCount,
		TF.ValidateMask,
		TF.ValidateFunction,
		'''' TemplateName,
		ISNULL(TF.LookupTypeId,0) LookupTypeId,
		IsNULL(TF.Width,0) Width,
		TF.DefaultValue  ,
		CASE WHEN TF.LookupTypeId IS NOT NULL THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,1,''-Select-'') ELSE ISNULL(ListText,'''') END ListText,
		CASE WHEN TF.LookupTypeId IS NOT NULL THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,0,''0'') ELSE '''' END ListValue,
		TTF.DisplayOrder,
		td.FieldValue value
		FROM CWI_JOBSUMMARYTemplateData TD
		INNER JOIN CWI_TaskTemplateField TTF
			ON TTF.Id = TD.TemplateFieldId
		INNER JOIN CWI_TaskField TF
			ON TTF.TaskFieldId = TF.Id
		WHERE JOBID = @inJobId 
		AND TF.MappingLookupId IN (20201) /* Ad Rundate */
	
	
		
	ORDER BY TTF.DisplayOrder, TF.FieldLabel
END



' 
END
GO


