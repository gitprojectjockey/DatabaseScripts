/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskNotes]    Script Date: 7/10/2014 7:00:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskNotes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskNotes]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskNotes]    Script Date: 7/10/2014 7:00:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskNotes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetTaskNotes
* Purpose : This PROC would be called TO get the note and summary of task
* Invoked from : Child/Tasks.aspx
* CREATED: Mohankumar Sundaram  23 OCT 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTaskNotes 1
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetTaskNotes] 
	@TaskId bigint 
AS
	SET NOCOUNT ON
	DECLARE @tbl TABLE
	(
		Note varchar(max),
		IsSummary bit

	)

	declare @summary varchar(max), @note varchar(max)
	INSERT INTO @tbl
	 
	SELECT ''<b>Enterd on '' + FORMAT ( TN.CreatedOn, ''MM/dd/yyyy HH:mm tt'', ''en-US'' ) + '' By '' + U.Names + '':</b><BR/>'' + REPLACE(TN.Note,CHAR(10),''<BR/>''),
	IsSummary 
	FROM CWI_TaskNote TN
		INNER JOIN CWI_User U
			ON TN.CreatedBy = U.Id
	WHERE
		TN.TaskId = @TaskId
	ORDER BY TN.CreatedOn DESC

	SELECT @summary =  SUBSTRING
		(
			(
			SELECT ''<BR/>'' + Note 
			FROM @tbl
			WHERE IsSummary = 1
			FOR XML PATH('''')),
		12,200000
		) 

	SELECT @note=
		SUBSTRING
		(
			(
			SELECT ''<BR/>'' + Note 
			FROM @tbl
			WHERE IsSummary = 0
			FOR XML PATH('''')),
		12,200000
		) 
	SELECT Summary = @summary, Note = @note


	SET NOCOUNT OFF


' 
END
GO


