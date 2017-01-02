

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetGroup]    Script Date: 4/25/2013 2:38:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetGroup')
DROP PROCEDURE [dbo].[prc_CWI_SetGroup]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetGroup]    Script Date: 4/25/2013 2:38:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_SetGroup  
* Purpose : This PROC would be called TO insert the group in to the group table
* Invoked from : Groups.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
declare @gid int
exec prc_CWI_SetGroup @group='IDC', @author = 'oss\msundaram', @groupid =@gid output
select @gid
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetGroup] 
	@group varchar(max),
	@author varchar(max) = '', --used to insert for createdby column
	@groupId int = NULL OUTPUT
	
AS

	SELECT @groupId = Id From CWI_Group WHERE GroupName = @group

	IF @groupId IS NULL
	BEGIN
		INSERT INTO [dbo].[CWI_Group]
					([GroupName]
					,[IsActive]
					,[CreatedBy]
					,[CreatedOn]
					,[ModifiedBy]
					,[ModifiedOn])
		VALUES
		(
			@group,
			1,
			@author,
			GETDATE(),
			@author,
			GETDATE()
		)
		SET @groupId = SCOPE_IDENTITY()
	END
	
GO

