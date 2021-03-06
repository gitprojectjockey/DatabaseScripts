/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTasksBySearch]    Script Date: 10/13/2014 7:24:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTasksBySearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTasksBySearch]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTasksBySearch]    Script Date: 10/13/2014 7:24:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTasksBySearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetTasksBySearch
* Purpose : This PROC would be called TO get the task details based on search
* Invoked from : Child/Tasks.aspx
* CREATED: Mohankumar Sundaram  23 OCT 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetTasksBySearch] @ObjectLookupId = 205,
@objectid = 21,
@StatusLookupId =NULL,
@PriorityLookupId =NULL,
@Author = Null
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetTasksBySearch]
	@ObjectLookupId int,
	@objectid bigint = NULL,
	@StatusLookupId int= NULL,
	@PriorityLookupId int = NULL,
	@Author int  = NULL 


AS
	SELECT 
		t.* ,
		UA.Names CreatedUser,
		UA.Email AuthorEmail,
		UM.Names ModifiedUser,
		LS.LookupName [Status],
		LP.LookupName [Priority],
		ISNULL(tt.Name,''NA'') Name
	FROM CWI_Task t
	LEFT OUTER JOIN CWI_TaskTemplate tt
	ON tt.Id=t.templateID
	INNER JOIN Lookup LS
	ON LS.Id = t.StatusLookupId
	INNER JOIN Lookup LP
	ON LP.Id = t.PriorityLookupId
	INNER JOIN CWI_User UA
	ON UA.Id = t.CreatedBy
	INNER JOIN CWI_User UM
	ON UM.Id = t.ModifiedBy
	WHERE 
		t.ObjectLookupId = @ObjectLookupId AND
		t.Objectid = CASE WHEN @objectid IS NULL THEN t.Objectid ELSE @objectid END AND
		t.StatusLookupId = CASE WHEN @StatusLookupId IS NULL THEN t.StatusLookupId ELSE @StatusLookupId END AND
		t.PriorityLookupId = CASE WHEN @PriorityLookupId IS NULL THEN t.PriorityLookupId ELSE @PriorityLookupId END AND
		t.CreatedBy = CASE WHEN @Author IS NULL THEN t.CreatedBy ELSE @Author END
		AND t.ModifiedBy=CASE WHEN @Author IS NULL THEN t.ModifiedBy ELSE @Author END
		
' 
END
GO
