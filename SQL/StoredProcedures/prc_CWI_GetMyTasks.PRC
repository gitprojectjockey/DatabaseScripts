/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMyTasks]    Script Date: 7/7/2014 5:20:10 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMyTasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetMyTasks]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMyTasks]    Script Date: 7/7/2014 5:20:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMyTasks]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetMyTasks
* Purpose : This PROC would be called TO get the logged in user task details for task
* Invoked from : Dashboard.aspx
* CREATED: Saravanan  23 Jun 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION             

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetMyTasks 3,1,1,1  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetMyTasks]
	@Author int = 0,
	@IsCreated bit =0,
	@IsAssigned bit=0,
	@IsGroup bit=0
AS

Declare @tblTask table
(
	Id bigint,
	ObjectLookupId Int,
	ObjectId bigint,
	Subject varchar(max),
	StatusLookupId int,
	PriorityLookupId int,
	DueDate datetime,
	IsNotificationRequired bit,
	CreatedBy INT,
	CreatedOn Datetime,
	ModifiedBy INT,
	ModifiedOn Datetime
)


IF( @IsAssigned=0 AND @IsGroup=0 AND @IsCreated=0)/* Default Tasks - user''s tasks and user''s group''s tasks*/
BEGIN

	INSERT INTO @tblTask
	SELECT * FROM
	(
	SELECT DISTINCT(T.Id),T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn
	FROM CWI_Task T

	WHERE 
		T.CreatedBy=@Author

	UNION 

	SELECT DISTINCT(T.Id),T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn
	FROM CWI_Task t
	INNER JOIN CWI_TaskAssignee TA
			ON T.Id = TA.TaskId
	WHERE 
		( tA.UserId=@Author
			OR
			TA.GroupId IN
			( SELECT GroupId FROM CWI_UserGroup WHERE UserId = @Author)
		)
		AND TA.IsRemoved = 0
		) t
          
SELECT
		T.* ,
		(SELECT STUFF((SELECT '',''+CONVERT(VARCHAR(100),ISNULL(Names,G.GroupName)) FROM CWI_TaskAssignee TA 
		LEFT OUTER JOIN [CWI_User] U
		ON TA.UserId=U.Id AND TA.TaskId=T.Id AND TA.IsRemoved=0
		LEFT OUTER JOIN [CWI_Group] G
		ON TA.GroupId=G.Id AND TA.TaskId=T.Id AND TA.IsRemoved=0
		FOR XML PATH('''')),1,1,'''')) Assignee,
		LT.LookupName ObjectType,		
		UA.Names CreatedUser,
		UA.Email AuthorEmail,
		UM.Names ModifiedUser,
		LS.LookupName [Status],
		LP.LookupName [Priority],
		D.ClientCode  + '' - '' + D.ClientName DivisionCode,
		D.ClientName DivisionName
       
	FROM
		@tblTask T
		
		INNER JOIN Lookup LT
		ON LT.Id=T.ObjectLookupId
		INNER JOIN Lookup LS
		ON LS.Id = T.StatusLookupId AND LS.Id<>20125
		INNER JOIN Lookup LP
		ON LP.Id = T.PriorityLookupId
		INNER JOIN CWI_User UA
		ON UA.Id = T.CreatedBy
		INNER JOIN CWI_User UM
		ON UM.Id = T.ModifiedBy
		LEFT JOIN CWI_JOB J
		ON J.ID=T.ObjectId AND T.ObjectLookupId = 205 /* JOB */
		LEFT JOIN CWI_MarketingPlan MP
		ON MP.ID=T.ObjectId AND T.ObjectLookupId = 204 /* Marketing Plan */	
		LEFT Join CWI_Client D
		ON D.ID=J.DivisionId OR D.Id = MP.DivisionID
		ORDER BY T.DueDate ASC;
		RETURN;

	END
ELSE IF(@IsCreated = 1 and @IsGroup=0 AND @IsAssigned=0)/*Created user - User''s Tasks*/
	BEGIN
		INSERT INTO @tblTask 
		SELECT DISTINCT(T.Id),T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn
		FROM CWI_Task T
		WHERE 
			   T.CreatedBy=@Author;
	END
ELSE IF(@IsAssigned=1 and @IsGroup=0 AND @IsCreated=0)/* assigned to user - My Assigned Tasks*/
	BEGIN
		Insert Into @tblTask 
		SELECT DISTINCT(T.Id),T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn
		FROM CWI_Task t
		INNER JOIN CWI_TaskAssignee TA
		ON T.Id = TA.TaskId AND TA.UserId=@Author  
			AND TA.IsRemoved = 0;
	END
ELSE IF(@IsCreated = 1 and @IsGroup=0 AND @IsAssigned=1)/*Created user/Assigned - User''s Tasks*/
	BEGIN
		INSERT INTO @tblTask 
		SELECT DISTINCT(T.Id),T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn		
		FROM CWI_Task T
		WHERE 
			   T.CreatedBy=@Author
		UNION
		SELECT T.Id,T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn
		
		FROM CWI_Task t
		INNER JOIN CWI_TaskAssignee TA
		ON T.Id = TA.TaskId AND TA.UserId=@Author  
			AND TA.IsRemoved = 0;
	END
ELSE IF(@IsAssigned=1 AND @IsGroup=1 AND @IsCreated=0)/* assigned group - My Assigned Group''s Tasks*/
	BEGIN
		INSERT INTO @tblTask
		SELECT  DISTINCT(T.Id),T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn		
		FROM CWI_Task t
		INNER JOIN CWI_TaskAssignee TA
		ON T.Id = TA.TaskId
		WHERE 
				( TA.UserId=@Author
					OR
					TA.GroupId IN
					( SELECT GroupId FROM CWI_UserGroup WHERE UserId = @Author)
				)							 
				AND TA.IsRemoved = 0;
	END
ELSE IF(@IsCreated=1 AND @IsGroup=1 AND @IsAssigned=0)/*created by User - My Tasks and My Group''s tasks*/
	BEGIN
		INSERT INTO @tblTask
		SELECT  DISTINCT(T.Id),T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn		
		FROM CWI_Task t
		INNER JOIN CWI_TaskAssignee TA
		ON T.Id = TA.TaskId
		WHERE 
			( T.CreatedBy=@Author
				AND
				TA.GroupId IN
				( SELECT GroupId FROM CWI_UserGroup WHERE UserId = @Author)
			)							 
			AND TA.IsRemoved = 0;
	END
ELSE IF(@IsCreated=1 AND @IsGroup=1 AND @IsAssigned=1)
	BEGIN
		INSERT INTO @tblTask
		SELECT  DISTINCT(T.Id),T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn		
		FROM CWI_Task t
		INNER JOIN CWI_TaskAssignee TA
		ON T.Id = TA.TaskId
		WHERE 
			( T.CreatedBy=@Author
				OR
				TA.GroupId IN
				( SELECT GroupId FROM CWI_UserGroup WHERE UserId = @Author)
			)							 
			AND TA.IsRemoved = 0
		UNION
		SELECT  T.Id,T.ObjectLookupId,T.ObjectId,T.Subject,T.StatusLookupId,T.PriorityLookupId,T.DueDate,T.IsNotificationRequired,T.CreatedBy,T.CreatedOn,T.ModifiedBy,T.ModifiedOn		
		FROM CWI_Task t
		INNER JOIN CWI_TaskAssignee TA
		ON T.Id = TA.TaskId
		WHERE 
				( TA.UserId=@Author
					OR
					TA.GroupId IN
					( SELECT GroupId FROM CWI_UserGroup WHERE UserId = @Author)
				)							 
				AND TA.IsRemoved = 0;
		SELECT
		T.* ,
		(SELECT STUFF((SELECT '',''+CONVERT(VARCHAR(100),G.GroupName) FROM CWI_TaskAssignee TA 
		LEFT OUTER JOIN [CWI_User] U
		ON TA.UserId=U.Id AND TA.TaskId=T.Id AND TA.IsRemoved=0
		LEFT OUTER JOIN [CWI_Group] G
		ON TA.GroupId=G.Id AND TA.TaskId=T.Id AND TA.IsRemoved=0
		FOR XML PATH('''')),1,1,'''')) Assignee,
		LT.LookupName ObjectType,		
		UA.Names CreatedUser,
		UA.Email AuthorEmail,
		UM.Names ModifiedUser,
		LS.LookupName [Status],
		LP.LookupName [Priority],
		D.ClientCode  + '' - '' + D.ClientName DivisionCode,
		D.ClientName DivisionName
       
	FROM
		@tblTask T
		
		INNER JOIN Lookup LT
		ON LT.Id=T.ObjectLookupId
		INNER JOIN Lookup LS
		ON LS.Id = T.StatusLookupId --AND LS.Id<>20125
		INNER JOIN Lookup LP
		ON LP.Id = T.PriorityLookupId
		INNER JOIN CWI_User UA
		ON UA.Id = T.CreatedBy
		INNER JOIN CWI_User UM
		ON UM.Id = T.ModifiedBy
		LEFT JOIN CWI_JOB J
		ON J.ID=T.ObjectId AND T.ObjectLookupId = 205 /* JOB */
		LEFT JOIN CWI_MarketingPlan MP
		ON MP.ID=T.ObjectId AND T.ObjectLookupId = 204 /* Marketing Plan */	
		LEFT Join CWI_Client D
		ON D.ID=J.DivisionId OR D.Id = MP.DivisionID
		ORDER BY T.DueDate ASC;
		Return;
	END
	SELECT
		T.* ,
		(SELECT STUFF((SELECT '',''+CONVERT(VARCHAR(100),ISNULL(Names,G.GroupName)) FROM CWI_TaskAssignee TA 
		LEFT OUTER JOIN [CWI_User] U
		ON TA.UserId=U.Id AND TA.TaskId=T.Id AND TA.IsRemoved=0
		LEFT OUTER JOIN [CWI_Group] G
		ON TA.GroupId=G.Id AND TA.TaskId=T.Id AND TA.IsRemoved=0
		FOR XML PATH('''')),1,1,'''')) Assignee,
		LT.LookupName ObjectType,		
		UA.Names CreatedUser,
		UA.Email AuthorEmail,
		UM.Names ModifiedUser,
		LS.LookupName [Status],
		LP.LookupName [Priority],
		D.ClientCode  + '' - '' + D.ClientName DivisionCode,
		D.ClientName DivisionName
       
	FROM
		@tblTask T
		
		INNER JOIN Lookup LT
		ON LT.Id=T.ObjectLookupId
		INNER JOIN Lookup LS
		ON LS.Id = T.StatusLookupId --AND LS.Id<>20125
		INNER JOIN Lookup LP
		ON LP.Id = T.PriorityLookupId
		INNER JOIN CWI_User UA
		ON UA.Id = T.CreatedBy
		INNER JOIN CWI_User UM
		ON UM.Id = T.ModifiedBy
		LEFT JOIN CWI_JOB J
		ON J.ID=T.ObjectId AND T.ObjectLookupId = 205 /* JOB */
		LEFT JOIN CWI_MarketingPlan MP
		ON MP.ID=T.ObjectId AND T.ObjectLookupId = 204 /* Marketing Plan */	
		LEFT Join CWI_Client D
		ON D.ID=J.DivisionId OR D.Id = MP.DivisionID
		ORDER BY T.DueDate ASC






' 
END
GO
