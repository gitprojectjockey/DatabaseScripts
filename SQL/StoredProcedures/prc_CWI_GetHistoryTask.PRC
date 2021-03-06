/****** Object:  StoredProcedure [dbo].[prc_CWI_GetHistoryTask]    Script Date: 7/10/2014 7:02:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetHistoryTask]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetHistoryTask]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetHistoryTask]    Script Date: 7/10/2014 7:02:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetHistoryTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetHistoryTask 
* Purpose : This PROC would be called to return the task history details
* Invoked from : multiple pages
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
 prc_CWI_GetHistoryTask  10237
 **********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetHistoryTask]
	@TaskId bigint
	
AS
BEGIN
SELECT * FROM
(		
	SELECT 
	2 [order],
	--Task details for First Set
	t.Oldsubject,
	t.Newsubject,
	ls.LookupName as OldStatusLookupName,
	l.LookupName as NewStatusLookupName,
	lp.LookupName as OldPriorityName,
	p.LookupName as NewPriorityName,
	t.OldDueDate,t.NewDueDate,
	t.OldIsNotificationRequired,
	t.NewIsNotificationRequired,
	UM.Names ModifiedBy,
	t.Modifiedon,
	--Task assignee details for First Set
	null as OldUserName,
	null as NewUserName,
	null as OldGroupName,
	null as NewGroupName, 
	null as Oldisremoved,
	null as Newisremoved,
	null as Iscopied,

	--task attachment details
	--attachment details
	 null as TaskAttachmentId,
	 null as OldFileName,
	 null as NewFileName,
	 null as OldFilePath,
	 null as NewFilePath,
	 null as OldAttachtomail,
	 null as NewAttachtomail,
	 null as AttachmentOldIsRemoved,
	 null as AttachmentNewIsRemoved,
	 null as AuditAction,
	 null as Name

	FROM CWI_History_Task t INNER JOIN
	CWI_Task tas ON tas.Id=t.Taskid 
	LEFT OUTER JOIN lookup ls ON ls.id=t.OldStatusLookupID 
	LEFT OUTER JOIN  lookup l ON l.id=t.NewStatusLookupID
	LEFT OUTER JOIN  lookup lp ON lp.Id = t.OldPriorityLookupId 
	LEFT OUTER JOIN  lookup p	ON p.Id=t.NewPriorityLookupId
	INNER JOIN CWI_User UM ON UM.Id=t.ModifiedBy
	WHERE t.TaskId = @TaskId
UNION ALL 
	
	--Task Details for Second Set
	select 
	2 [order],null as Oldsubject,
	null as Newsubject,
	null OldStatusLookupId,
	null as NewStatusLookupId, 
	null as OldPriorityLookupId, 
	null as NewPriorityLookupId, 
	NULL as OldDueDate,
	null as NewDueDate,
	null as OldIsNotificationRequired,
	null as NewIsNotificationRequired,
	--null as modifiedby,
	--null as modifiedon,
	UM.Names as ModifiedBy,
	s.ModifiedOn,
	--Task assignee details for second set
	 Us.Names as OldUserName,
	 U.Names as NewUserName, 
	 Gr.GroupName as OldGroupName, 
	 G.GroupName as NewGroupName,
	 OldIsRemoved,
	 newisremoved,
	 s.IsCopied,
	 --attachment details
	 null as TaskAttachmentId,
	 null as OldFileName,
	 null as NewFileName,
	 null as OldFilePath,
	 null as NewFilePath,
	 null as OldAttachtomail,
	 null as NewAttachtomail,
	 null as AttachmentOldIsRemoved,
	 null as AttachmentNewIsRemoved,
	 null as AuditAction,
	 null as Name

from CWI_History_TaskAssignee s
INNER JOIN CWI_TaskAssignee ta ON ta.Id=s.TaskAssigneeId 
	  INNER JOIN CWI_User UM ON UM.Id=s.ModifiedBy
	  LEFT OUTER JOIN CWI_User Us ON Us.id = s.OldUserId
	  LEFT OUTER JOIN CWI_User U ON U.id = s.NewUserId
	  LEFT OUTER JOIN CWI_Group Gr ON Gr.id = s.OldGroupId
	  LEFT OUTER JOIN CWI_Group G ON G.id = s.NewGroupId
	  WHERE ta.TaskId = @TaskId
     --order by t.ModifiedOn desc
	--Task Attachment history details goes here
   union all
	select 
	2 [order],
	null as Oldsubject,
	null as Newsubject,
	null OldStatusLookupId,
	null as NewStatusLookupId, 
	null as OldPriorityLookupId, 
	null as NewPriorityLookupId, 
	NULL as OldDueDate,
	null as NewDueDate,
	null as OldIsNotificationRequired,
	null as NewIsNotificationRequired,
	UM.Names as ModifiedBy,
	tat.ModifiedOn, 
	--assignee details
	null as OldUserName,
	null as NewUserName,
	null as OldGroupName,
	null as NewGroupName, 
	null as Oldisremoved,
	null as Newisremoved,
	null as Iscopied,
	--attachment details
	 TaskAttachmentId,
	 OldFileName,
	 NewFileName,
	 OldFilePath,
	 NewFilePath,
	 OldAttachtomail,
	 NewAttachtomail,
	 tat.OldIsRemoved as AttachmentOldIsRemoved,
	 tat.NewIsRemoved as AttachmentNewIsRemoved,
	 AuditAction,
	 null as Name

	 FROM CWI_History_TaskAttachment tat INNER JOIN CWI_TaskAttachment tast ON tast.id=tat.TaskAttachmentId
	 INNER JOIN CWI_User UM ON UM.Id=tat.ModifiedBy
	 WHERE tast.TaskId=@TaskId 
	 --order by t.ModifiedOn desc
	  --,isnull(Task.Newisremoved,0) desc

	   --Template details goes here
	  union all
	  select top 1
	2 [order],
	null as Oldsubject,
	null as Newsubject,
	null OldStatusLookupId,
	null as NewStatusLookupId, 
	null as OldPriorityLookupId, 
	null as NewPriorityLookupId, 
	NULL as OldDueDate,
	null as NewDueDate,
	null as OldIsNotificationRequired,
	null as NewIsNotificationRequired,
	UM.Names ModifiedBy,
	TTD.Modifiedon, 
	--assignee details
	null as OldUserName,
	null as NewUserName,
	null as OldGroupName,
	null as NewGroupName, 
	null as Oldisremoved,
	null as Newisremoved,
	null as Iscopied,
	--attachment details
	 null as TaskAttachmentId,
	 null as OldFileName,
	 null as NewFileName,
	 null as OldFilePath,
	 null as NewFilePath,
	 null as OldAttachtomail,
	 null as NewAttachtomail,
	 null as AttachmentOldIsRemoved,
	 null as AttachmentNewIsRemoved,
	 null as AuditAction,
	 TT.Name
	 FROM  CWI_TaskTemplate TT 
	INNER JOIN 
        CWI_TaskTemplateField TTF 
	ON 
        TT.id=TTF.TaskTemplateId 
	INNER JOIN 
        CWI_TaskField TF 
	ON 
        TTF.TaskFieldId=TF.id 
	INNER JOIN 
        CWI_TaskTemplateData TTD 
	ON 
        TTD.TemplateFieldId=TTF.Id 
		INNER JOIN CWI_User UM ON UM.Id=TTD.ModifiedBy
		AND TTD.taskId=@TaskId  
) x
	ORDER BY [Order] DESC, ModifiedOn DESC
END
' 
END
GO


