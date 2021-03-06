/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskStatusByJob]    Script Date: 7/30/2014 3:25:26 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskStatusByJob]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskStatusByJob]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskStatusByJob]    Script Date: 7/30/2014 3:25:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskStatusByJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*********************************************************************************************  
* PROCEDURE: prc_CWI_GetTaskStatusByJob
* Purpose : This PROC would be called TO get Task Status for the JobId passed)
* Invoked from : Jobs.aspx
* CREATED: Bala
* CREATED ON : 23AJUL2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetTaskStatusByJob @inJobID=1853
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetTaskStatusByJob]    
    @inJobID BIGINT
	
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		SELECT StatusLookupId,l.LookupName as Status,COUNT(statuslookupid) AS StatusCount 
		FROM CWI_Task t 
		INNER JOIN Lookup l 
		ON l.Id=t.StatusLookupId 
		WHERE t.ObjectId=@inJobID and ObjectLookupId=205 --Job
		GROUP BY t.StatusLookupId,l.LookupName
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
	SET NOCOUNT OFF
END
	
' 
END
GO
