/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTaskAttachment]    Script Date: 7/10/2014 6:56:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTaskAttachment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetTaskAttachment]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTaskAttachment]    Script Date: 7/10/2014 6:56:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTaskAttachment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*********************************************************************************
* PROCEDURE: prc_CWI_SetTaskAttachment
* Purpose : This PROC would be called TO Insert Task attachements for a task
* Invoked from : Task.aspx
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              
**********************************************************************  
Execution example :
**********************************************************************  
--exec prc_CWI_SetTaskAttachments @ID=0, 
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetTaskAttachment]
    @TaskId bigint,
	@Author int,
	@Attachments XML,
	@FilePath varchar(500)
	
AS
 declare @hasOuterTransaction bit = case when @@trancount > 0 then 1 else 0 end;
 if @hasOuterTransaction = 0
 begin
	BEGIN TRANSACTION 
end
BEGIN TRY
	-- temporary table to store the data from XML
	DECLARE @tbl TABLE
	(
		Id1 int  NULL,
		FileName1 varchar(max),
		IsEmail bit default 0
		
	)

	--Read the data from XML and store in the table variable
		INSERT INTO @tbl
		(
			Id1,
			FileName1,
			IsEmail
		)
		SELECT
			Id,
			FileNames,
			IsEmail
		FROM
		(
		SELECT 
			COLX.value(''(./Id)[1]'',''int'') Id,
			COLX.value(''(./FileName)[1]'',''varchar(max)'') FileNames,
			COLX.value(''(./Attachtomail)[1]'',''bit'') IsEmail
			
		FROM @Attachments.nodes(''DocumentElement/TaskAttachment'') AS TABX(COLX)
		) x	
			
		INSERT CWI_TaskAttachment
		(TaskId, FileName, FilePath,Attachtomail,CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT
			@TaskId,
			FileName1,
			@FilePath,
			IsEmail,
			@Author,
			getdate(),@Author, getdate()
		FROM
		@tbl t
		/*LEFT OUTER JOIN CWI_TaskAttachment JA
		ON JA.Id = t.Id1*/ --AND ISNULL(t.FileName1,'''') = ISNULL(JA.FileName,'''') 
		WHERE t.Id1 < 0
		
		UPDATE 
			CWI_TaskAttachment 
		SET 
			--FileName=FileName1,
			FilePath=@FilePath,
			Attachtomail=t.IsEmail,
			ModifiedBy = @Author
			--ModifiedOn = getdate()
		FROM
			CWI_TaskAttachment JA
			INNER JOIN  @tbl t
				ON JA.Id = t.Id1 --AND  ISNULL(t.FileName1,'''') <> '''' 

		
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
		BEGIN
			if @hasOuterTransaction = 0
			 begin
				ROLLBACK TRANSACTION ;
			end
		END	
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		if @hasOuterTransaction = 0
			 begin
				COMMIT TRANSACTION ;
			end
		




' 
END
GO


