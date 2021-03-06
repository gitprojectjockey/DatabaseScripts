/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobStatus]    Script Date: 10/10/2013 7:52:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobStatus]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobStatus]    Script Date: 10/10/2013 7:52:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobStatus 
* Purpose : This PROC would be called to get the status of a job
* Invoked from : AdCopy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE            AUTHOR          DESCRIPTION              
  10/10/2013
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetJobStatus 98
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetJobStatus]
@inJobId Bigint
AS
BEGIN

	BEGIN TRY
		SELECT J.JobStatusLookupId, L.[LookupName] AS StatusName		
		FROM [dbo].[CWI_Job] AS J		
		INNER JOIN [dbo].[Lookup] AS L ON L.Id=J.JobStatusLookupId
		WHERE J.ID=@inJobId 
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	' 
END
GO
