/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteJobAssignee]    Script Date: 5/29/2014 2:31:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteJobAssignee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteJobAssignee]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteJobAssignee]    Script Date: 5/29/2014 2:31:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteJobAssignee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteJobAssignee
* Purpose : This PROC would be called TO Insert And Update assigness for Job
* Invoked from : Jobs.aspx
* CREATED: Vijesh Mahi 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_DeleteJobAssignee @JobID=1553,@Author=7,@UserID=NULL,@GroupID=1,@IsCopied=0,@IsRemoved=1
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_DeleteJobAssignee] 
	@JobID BIGINT,
	@Author int,
	@UserId INT=NULL,
	@GroupId INT=NULL,
	@IsCopied BIT,
	@IsRemoved BIT
AS
BEGIN
	BEGIN TRANSACTION Trans1
		BEGIN TRY
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
			   ,[ModifiedOn] from [CWI_JobAssignee]
			WHERE JobID=@JobID AND [UserID]=@UserId AND [GroupID]=@GroupId;

			DECLARE @tblJobAssignee TABLE
			(
			comment varchar(max),
			userid int,
			groupid int
			) 

			DECLARE @delimiter CHAR(1) = CHAR(225);

			DECLARE @tblAction TABLE
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
		DECLARE @dt varchar(50);
		SET @dt  =FORMAT( getdate(), ''MM/dd/yyyy hh:mm tt'');
						 
			UPDATE 
			CWI_JobAssignee 
			SET 
				IsRemoved = @IsRemoved,ModifiedBy=@Author,ModifiedOn=GETDATE()
				OUTPUT
				   CASE WHEN INSERTED.IsRemoved<>DELETED.IsRemoved 
					THEN
						CASE WHEN INSERTED.IsRemoved=1 THEN (CASE WHEN inserted.IsCopied=1 THEN ''Copied '' ELSE '''' END) +  ''Assignee {0} Removed'' ELSE ''Assignee selected'' END
						 ELSE '''' end 
				    ,INSERTED.UserID, INSERTED.GroupID
				   INTO @tblJobAssignee 
			FROM
				CWI_JobAssignee
			WHERE JobID = @JobID AND  (UserId=@UserId OR UserID IS NULL) AND GroupId=@GroupId AND IsCopied=@IsCopied;


			--Inserting into Action table to track History			
			DECLARE @AuthorName varchar(1000)
			SELECT @AuthorName = Names FROM CWI_User WHERE Id = @Author;
			INSERT INTO @tblTemp select REPLACE(comment,''{0}'',CASE WHEN ISNULL(groupid,0)=0 THEN U.Names ELSE G.GroupName END ) + '' by '' + @AuthorName + '' on '' + @dt as commentNew,comment 
			from @tblJobAssignee tJA
			LEFT OUTER JOIN CWI_Group G
				ON tJA.groupid = g.Id
			LEFT OUTER JOIN CWI_User U
				ON tJA.userid = U.Id where LTRIM(RTRIM(comment))<>''''

			INSERT INTO @tblAction SELECT  205,@JobId,10007,commentNew FROM @tblTemp WHERE LTRIM(RTRIM(comment)) <> '''';
		
			INSERT INTO CWI_Action Select TA.ObjLookupId,TA.ObjectId,TA.ActionLookupId,TA.ActionVal,TA.ActionVal,@Author,GETDATE() from @tblAction TA where TA.ActionVal <>'''';


		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION Trans1;
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;
END

' 
END
GO
