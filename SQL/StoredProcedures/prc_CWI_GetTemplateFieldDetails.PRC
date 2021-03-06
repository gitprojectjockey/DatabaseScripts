/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTemplateFieldDetails]    Script Date: 9/25/2014 9:01:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTemplateFieldDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTemplateFieldDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTemplateFieldDetails]    Script Date: 9/25/2014 9:01:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTemplateFieldDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[prc_CWI_GetTemplateFieldDetails]
	@FieldId int,
	@templateId int = -1
AS
select 
		Id, TF.FieldLabel, TF.TypeLookupId, TF.MinLength, TF.MaxLength, TF.IsRequiredCount,
		TF.RepeatCount,
		TF.ValidateMask,
		TF.ValidateFunction,
		'''' TaskTemplateName,
		ISNULL(TF.LookupTypeId,0) LookupTypeId,
		IsNULL(TF.Width,0) Width,
		TF.DefaultValue  ,
		TF.MappingLookupId,
		DisplayOrder= (select top 1 DisplayOrder from CWI_TaskTemplateField  WHERE Id = @templateId),
		CASE WHEN TF.LookupTypeId IS NOT NULL 
			THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,1,''-Select-'') 
			ELSE ISNULL(ListText,'''') END ListText,
		CASE WHEN TF.LookupTypeId IS NOT NULL 
			THEN dbo.fnc_CWI_GetCommaSeperatedLookup(TF.LookupTypeId,0,''0'') 
			ELSE '''' END ListValue
	from 
	CWI_TaskField TF
WHERE
	Id = @FieldId		




' 
END
GO


