/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobSummary]    Script Date: 2/10/2014 8:35:21 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobSummary]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobSummary]    Script Date: 2/10/2014 8:35:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_CWI_GetJobSummary]
	@inJobId bigint
As
	
select * from CWI_Job
Where Id = @inJobId

' 
END
GO


