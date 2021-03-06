/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobAssignee]    Script Date: 7/10/2014 7:03:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobAssignee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobAssignee]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobAssignee]    Script Date: 7/10/2014 7:03:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobAssignee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobAssignee
* Purpose : This PROC would be called TO get assigness for Job
* Invoked from : Add Assignee.ascx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetJobAssignee @JobID=1331
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetJobAssignee] 
	@JobID bigint 
AS
BEGIN

	SELECT 
		
		isnull(UserId,0) as UserId,
		GroupId,
		isnull(U.Names,'''') as UserName,
		isnull(G.GroupName,'''') as GroupName,
		IsCopied,
		IsRemoved,
		JA.CreatedBy,
		JA.CreatedOn,
		JA.ModifiedBy,
		JA.ModifiedOn 
	FROM  CWI_JobAssignee JA
	LEFT OUTER JOIN CWI_User U ON U.id = JA.UserId
	LEFT OUTER JOIN CWI_Group G ON G.id = JA.GroupId
	WHERE JobId = @JobID AND IsRemoved = 0
	--SELECT 
	--	distinct ISNULL(G.Id,0) as GroupId,
	--	JA.ID,
	--	ISNULL(U.Id,0) as UserId,
	--	U.Names as UserName,
	--	G.GroupName,
	--	JA.IsCC
	--FROM 
	--	CWI_JobAssignee JA
	--	INNER JOIN
	--	CWI_Job J ON J.ID=JA.JobID 
	--LEFT JOIN
	--	CWI_UserGroup UG ON UG.ID=JA.GroupID
	--LEFT JOIN
	--	CWI_Group G ON G.Id=JA.GroupID
	--left outer JOIN
	--	CWI_User U ON U.Id=JA.UserID	
	--Where JobID=@JobID and JA.IsAssigned=1 ;--and JA.isCC=0;
	
END




' 
END
GO


