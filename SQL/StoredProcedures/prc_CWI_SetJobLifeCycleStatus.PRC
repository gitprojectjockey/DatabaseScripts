/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobLifeCycleStatus]    Script Date: 1/28/2014 9:29:45 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobLifeCycleStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobLifeCycleStatus]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobLifeCycleStatus]    Script Date: 1/28/2014 9:29:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobLifeCycleStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobLifeCycleStatus 
* Purpose : This PROC would be called to insert actions performed against one object
* Invoked from : multiple places
* CREATED: Saravanan M 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
  prc_CWI_SetJobLifeCycleStatus @JobID=1309

**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_SetJobLifeCycleStatus]
	@JobId int
	--@ClassId Int
AS

 DECLARE @LifeCycleId INT
	SET @LifeCycleId = (Select top 1
		L.Id
	FROM CWI_ClassificationJob_LifeCycle CL
	INNER JOIN
		Lookup L ON CL.LifeCycleLookUpId=L.Id AND CL.ClassLookupId = 401
	LEFT OUTER  JOIN CWI_ClassificationJob_LifeCycle_Status CLS
		ON CLS.LifeCycleLookupId = L.Id
			and CLS.JobId = @jobid
	LEFT OUTER   JOIN 		
		Lookup LS ON LS.Id=CLS.LifeCycleStatusLookupId 
	WHERE 
		ISNULL(LS.ID,0) <> 4205 -- Completed
	ORDER BY CL.FlowOrder)
 BEGIN TRY
BEGIN



UPDATE CWI_Job SET LifeCycleID=@LifeCycleId WHERE ID=@JobId;
END
END TRY
   BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

' 
END
GO
