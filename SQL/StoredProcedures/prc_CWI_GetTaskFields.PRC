/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskFields]    Script Date: 2/19/2014 6:08:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskFields]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskFields]    Script Date: 2/19/2014 6:08:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskFields]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[prc_CWI_GetTaskFields]
AS

SELECT Id , FieldName FROM CWI_TaskField
order by FieldName
' 
END
GO
