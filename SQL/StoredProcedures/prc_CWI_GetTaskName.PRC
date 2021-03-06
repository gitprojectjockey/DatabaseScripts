/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskName]    Script Date: 10/15/2014 7:29:11 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskName]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskName]    Script Date: 10/15/2014 7:29:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Saravanan
-- Create date: <Create Date,,>
-- Description:	Getting task Name
-- =============================================
CREATE PROCEDURE [dbo].[prc_CWI_GetTaskName]
@TaskId bigint
AS
BEGIN
	SELECT 
		TT.Id TemplateID,TT.Name TemplateName
	FROM CWI_TaskTemplate TT 
	INNER JOIN	CWI_Task T ON T.TemplateID=TT.Id AND T.id=@TaskId;
END
' 
END
GO
