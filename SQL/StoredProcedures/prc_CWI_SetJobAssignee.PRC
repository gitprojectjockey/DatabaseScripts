/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobAssignee]    Script Date: 5/29/2014 2:31:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobAssignee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobAssignee]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobAssignee]    Script Date: 5/29/2014 2:31:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobAssignee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobAssignee
* Purpose : This PROC would be called TO Insert And Update assigness for Job
* Invoked from : Add Assignee.ascx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetJobAssignee @ID=0, @JobID=80, @UserID=0,@GroupID=1,@IsCC=0,@Author=8
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobAssignee] 
	@JobID bigint,
	@Author int,
	@Assignee XML
AS

BEGIN TRANSACTION Trans1
BEGIN TRY
	DECLARE @dt varchar(50);
	SET @dt  =FORMAT( getdate(), ''MM/dd/yyyy hh:mm tt'');
	
-- temporary table to store the data from XML

	DECLARE @tbl TABLE
	(
		UserId1 int,
		GroupId1 int,
		IsCopied1 bit,
			IsRemoved1 bit
	)

	--Read the data from XML and store in the table variable
		INSERT INTO @tbl
		(
			UserId1 ,
			GroupId1,
			IsCopied1,
			IsRemoved1
		)
		select
			distinct
			case when usrid = 0 then NULL else usrid end,
			grpid ,
			iscopied,
			IsRemoved
		from
		(
		select 
			COLX.value(''(./UserId)[1]'',''varchar(20)'') usrid,
			COLX.value(''(./GroupId)[1]'',''varchar(20)'') grpid,
			COLX.value(''(./IsCopied)[1]'',''bit'') iscopied,
			COLX.value(''(./IsRemoved)[1]'',''bit'') IsRemoved
		from @Assignee.nodes(''DocumentElement/Assignee'') AS TABX(COLX)
		) x		

		INSERT INTO [dbo].[CWI_History_JobAssignee]
           (
           [JobAssigneeID]
           ,[JobID]
           ,[UserID]
           ,[GroupID]
           ,[IsCopied]
           ,[IsRemoved]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])     
		Select	ID,
			[JobID]
           ,[UserID]
		   ,[GroupID]
		   ,[IsCopied]
		   ,[IsRemoved]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn] from [CWI_JobAssignee] JA
		  INNER JOIN @tbl t
			ON JA.JobId = @JobID AND  ISNULL(t.UserId1,'''') = ISNULL(JA.UserId,'''') AND ISNULL(t.GroupId1,'''') = ISNULL(JA.GroupId,'''')
			
		DECLARE @tblJobAssignee TABLE
		(
		comment varchar(max),
		userid int,
		groupid int
		) 

		DECLARE @delimiter CHAR(1) = CHAR(225);

		INSERT CWI_JobAssignee
		(JobId, UserId, GroupId, IsCopied, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		OUTPUT				   
		(CASE WHEN inserted.IsCopied=1 THEN ''Copied '' ELSE '''' END) +  ''Assignee {0} Selected''						  
		,INSERTED.UserID, INSERTED.GroupID
		INTO @tblJobAssignee 
		SELECT
			@JobID,
			UserId1,
			GroupId1,
			IsCopied1,
			@Author,
			@dt,@Author, @dt
		FROM
		@tbl t
		LEFT OUTER JOIN CWI_JobAssignee JA
		ON JA.JobId = @JobID AND  ISNULL(t.UserId1,'''') = ISNULL(JA.UserId,'''') 
			AND ISNULL(t.GroupId1,'''') = ISNULL(JA.GroupId,'''')
			AND t.IsCopied1 = JA.IsCopied
		WHERE JA.Id IS NULL;

		DECLARE @tblAction TABLE
		(
				ObjLookupId INt,
				ObjectId INT,
				ActionLookupId INT,
				ActionVal Varchar(max)
		)
		DECLARE @tblActionUpdate TABLE
		(
				ObjLookupId INt,
				ObjectId INT,
				ActionLookupId INT,
				ActionVal Varchar(max)
		)
	   
		DECLARE @tblTemp TABLE
		(
			commentNew Varchar(max),
			comment Varchar(max)
	   
		)
		DECLARE @tblTempUpdate TABLE
		(
			commentNew Varchar(max),
			comment Varchar(max)
	   
		)
				
		
		DECLARE @AuthorName varchar(1000)
		SELECT @AuthorName = Names FROM CWI_User WHERE Id = @Author
		INSERT INTO @tblTemp select REPLACE(comment,''{0}'',CASE WHEN ISNULL(groupid,0)=0 THEN U.Names ELSE G.GroupName END ) + '' by '' + @AuthorName + '' on '' +@dt as commentNew,comment 
		from @tblJobAssignee tJA
		LEFT OUTER JOIN CWI_Group G
			ON tJA.groupid = g.Id
		LEFT OUTER JOIN CWI_User U
			ON tJA.userid = U.Id where LTRIM(RTRIM(comment))<>''''

		INSERT INTO @tblAction SELECT  205,@JobId,10007,commentNew FROM @tblTemp WHERE LTRIM(RTRIM(comment)) <> '''';
	
		
		INSERT INTO CWI_Action Select TA.ObjLookupId,TA.ObjectId,TA.ActionLookupId,TA.ActionVal,TA.ActionVal,@Author,GETDATE() from @tblAction TA where TA.ActionVal <>'''';


		delete from  @tblJobAssignee;

		UPDATE 
			CWI_JobAssignee 
		SET 
			IsRemoved = IsRemoved1,ModifiedBy=@Author,ModifiedOn=@dt
			OUTPUT
				   CASE WHEN INSERTED.IsRemoved<>DELETED.IsRemoved 
					THEN
						CASE WHEN INSERTED.IsRemoved=1 THEN (CASE WHEN inserted.IsCopied=1 THEN ''Copied '' ELSE '''' END) +  ''Assignee {0} Removed'' ELSE ''Assignee selected'' END
						 ELSE '''' end 
				    ,INSERTED.UserID, INSERTED.GroupID
				   INTO @tblJobAssignee 
		FROM
			CWI_JobAssignee JA
			INNER JOIN  @tbl t
				ON JA.JobID = @JobID AND  ISNULL(t.UserId1,'''') = ISNULL(JA.UserId,'''') 
					AND ISNULL(t.GroupId1,'''') = ISNULL(JA.GroupId,'''')
					AND t.IsCopied1 = JA.IsCopied;
				
								
		INSERT INTO @tblTempUpdate select REPLACE(comment,''{0}'',CASE WHEN ISNULL(groupid,0)=0 THEN U.Names ELSE G.GroupName END ) + '' by '' + @AuthorName + '' on '' + @dt as commentNew,comment 
		from @tblJobAssignee tJA
		LEFT OUTER JOIN CWI_Group G
			ON tJA.groupid = g.Id
		LEFT OUTER JOIN CWI_User U
			ON tJA.userid = U.Id where LTRIM(RTRIM(comment))<>''''
			Select * from @tblTempUpdate

		INSERT INTO @tblActionUpdate SELECT  205,@JobId,10007,commentNew FROM @tblTempUpdate WHERE LTRIM(RTRIM(comment)) <> '''';
	
		
		INSERT INTO CWI_Action Select TA.ObjLookupId,TA.ObjectId,TA.ActionLookupId,TA.ActionVal,TA.ActionVal,@Author,GETDATE() from @tblActionUpdate TA where TA.ActionVal <>'''';


		
			--Inserting into Action table to track History
			--Job 135 created by Kevin on 10/16/2013 09:07 AM
			--Job# <a href="../jobs.aspx?jobid=135">135</a> created by Kevin on 10/16/2013 09:07 AM
			
			--DECLARE @InsertAction varchar(8000)
			--DECLARE @InsertActionLink varchar(8000)
			--DECLARE @dat varchar(50)
			--DECLARE @JobCount int
			--SET @dat = FORMAT( getdate(), ''MM/dd/yyyy hh:mm tt'')

			
			--SET @InsertAction = ''Job#''+ Convert(varchar,@JobID) + '' Assignee updated by '' + @AuthorName + '' on '' + @dat
			--SET @InsertActionLink=''Job#'' + Convert(varchar,@JobID) + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@JobID) + ''>'' + ''</a>'' + '' Assignee updated by '' + @AuthorName + '' on '' + @dat
			
			--EXEC prc_CWI_SetAction @ObjectLookupId = 401, @ObjectId = @JobID,
			--	@ActionLookupId = 10006,
			--	@Action = @InsertAction,
			--	@ActionWithLink= @InsertActionLink,
			--	@CreatedBy = @Author
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;




' 
END
GO
