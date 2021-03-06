/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClassificationLifeCycleStatus]    Script Date: 2/24/2014 2:27:50 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClassificationLifeCycleStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClassificationLifeCycleStatus]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClassificationLifeCycleStatus]    Script Date: 2/24/2014 2:27:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClassificationLifeCycleStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetClassificationLifeCycleStatus  
* Purpose : This PROC would be called TO get the lifecycle of classification status
* Invoked from : 
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClassificationLifeCycleStatus @ClassId = 401,@JobId= 183
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetClassificationLifeCycleStatus] 	
	@ClassId int,
	@JobId bigInt
AS
BEGIN
/*
	SELECT 
		CLS.JobId, 
		--CLS.Status,
		l.LookupName as LifeCycleName,
		LS.LookupName as [Status] 
	FROM 
		CWI_ClassificationJob_LifeCycle_Status  CLS
	INNER JOIN 
		Lookup L ON L.Id=CLS.LifeCycleLookupId
	INNER JOIN 
		Lookup LS ON LS.Id=CLS.[Status]
	WHERE JobId=@JobId; 
	*/
--select * from (	Select L.Id LifeCycleId, Null as ClassLookupId,'''' LifCycleName,0 StatusId,'''' [Status],0 FlowOrder  FROM Lookup L where L.Id=@ClassId
--UNION All
	
	Select L.Id LifeCycleId,L.LookupName LifCycleName, ISNULL(LS.id,0) StatusId
	  FROM CWI_ClassificationJob_LifeCycle CL
	INNER JOIN
	 Lookup LP ON LP.ID=CL.ClassLookupID
	INNER JOIN
	 Lookup L ON CL.LifeCycleLookUpId=L.Id AND CL.ClassLookupId=@ClassId
	 Inner JOIN
	 LookupType LT ON LT.Id=L.LookupTypeId 

	 LEFT OUTER  JOIN CWI_ClassificationJob_LifeCycle_Status CLS
	 ON CLS.LifeCycleLookupId = L.Id
	   and CLS.JobId = @JobId and CLS.IsActive=1
	 	 LEFT OUTER   JOIN 
		Lookup LS ON LS.Id=CLS.LifeCycleStatusLookupId ORDER BY CL.FlowOrder
	
END




' 
END
GO
