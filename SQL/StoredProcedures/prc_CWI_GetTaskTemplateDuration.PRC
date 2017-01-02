/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskTemplateDuration]    Script Date: 9/25/2014 8:59:35 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskTemplateDuration]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskTemplateDuration]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskTemplateDuration]    Script Date: 9/25/2014 8:59:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskTemplateDuration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[prc_CWI_GetTaskTemplateDuration]
	@templateId int
AS
BEGIN
	SELECT Id, EstimatedPeriodLookupID,EstimatedPeriod  FROM CWI_TaskTemplateDuration
	WHERE TaskTemplateId = @templateId

END' 
END
GO


