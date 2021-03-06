/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTemplateClass]    Script Date: 2/19/2014 6:08:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTemplateClass]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTemplateClass]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTemplateClass]    Script Date: 2/19/2014 6:08:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTemplateClass]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[prc_CWI_GetTemplateClass]
	@TemplateId int
AS
select ClassificationLookupId, ''T'' TemplateType from CWI_TaskTemplateClassification
where TaskTemplateId = @TemplateId  AND ISDeleted=0
UNION
select ClassificationLookupId, ''J'' from CWI_JobTemplateClassification
where JobTemplateId = @TemplateId AND ISDeleted=0;


' 
END
GO
