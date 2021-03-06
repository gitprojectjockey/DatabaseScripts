/****** Object:  StoredProcedure [dbo].[prc_CWI_UpdateTaskAttachment]    Script Date: 11/26/2013 3:28:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_UpdateTaskAttachment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_UpdateTaskAttachment]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_UpdateTaskAttachment]    Script Date: 11/26/2013 3:28:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_UpdateTaskAttachment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*********************************************************************************
* PROCEDURE: prc_CWI_UpdateTaskAttachment
* Purpose : This PROC would be called TO update Task attachement for a task
* Invoked from : Task.aspx
* CREATED: Mohankumar Sundaram
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              
**********************************************************************  
Execution example :
**********************************************************************  
--exec prc_CWI_SetTaskAttachments @ID=0, 
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_UpdateTaskAttachment]
    @TaskAttachId int,
	@FileName varchar(200),
	@Author int,
	@FilePath varchar(500)
	
AS
BEGIN TRANSACTION Trans1
BEGIN TRY
		UPDATE 
			CWI_TaskAttachment 
		SET 
			FileName=@FileName,
			FilePath=@FilePath,
			ModifiedBy = @Author,
			ModifiedOn = getdate()
		
		WHERE
			Id = @TaskAttachId
		
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
