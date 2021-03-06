/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUserGroup]    Script Date: 10/15/2013 3:53:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetUserGroup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetUserGroup]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUserGroup]    Script Date: 10/15/2013 3:53:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetUserGroup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetUserGroup 
* Purpose : This PROC would be called TO Insert & Update groupwise Users
* Invoked from : Add Assignee.ascx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetUserGroup @ID=,@GroupID=,@UserID,@Author=8
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetUserGroup] 
		 @ID INT out
        ,@GroupID INT
        ,@UserID INT
        ,@Author INT
       
AS
BEGIN
BEGIN TRY
IF( @ID=0)
BEGIN

 INSERT INTO [dbo].[CWI_UserGroup]          
			([GroupID]
           ,[UserID]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
			(@GroupID,
			@UserID,
			@Author,
			GETDATE(),
			@Author,
			GETDATE())
			SET @ID=SCOPE_IDENTITY();

END
ELSE	
BEGIN
	UPDATE [dbo].[CWI_UserGroup]
	SET
		GroupID=@GroupID,
		UserID=@UserID,
		ModifiedBy=@Author,
		ModifiedOn=GETDATE()
		WHERE ID=@ID;
END		

END TRY
BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END
' 
END
GO
