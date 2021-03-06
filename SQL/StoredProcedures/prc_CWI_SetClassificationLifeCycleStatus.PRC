/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClassificationLifeCycleStatus]    Script Date: 2/24/2014 2:27:50 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClassificationLifeCycleStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClassificationLifeCycleStatus]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClassificationLifeCycleStatus]    Script Date: 2/24/2014 2:27:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClassificationLifeCycleStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetClassificationLifeCycleStatus  
* Purpose : This PROC would be called TO Insert/Update the lifecycle of classification status
* Invoked from : 
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClassificationLifeCycleStatus @JobId= 183,@LifeCycleLookupId=4001,@LifeCycleStatusLookupId=4205,@DueDate=null,@Author=8
**********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetClassificationLifeCycleStatus]
	@JobId Int,
	@LifeCycleLookupId Int,
	@LifeCycleStatusLookupId INT,
	@DueDate Datetime,
	@IsActive BIT,
	@Author Int
AS
BEGIN
Declare @ID Int=0, @count int=0;

SET @count=(select count(*) from [CWI_ClassificationJob_LifeCycle_Status] where JobId=@JobId and LifeCycleLookupId=@LifeCycleLookupId and LifeCycleStatusLookupId=@LifeCycleStatusLookupId);
IF(@count=0)
BEGIN

 INSERT INTO [dbo].[CWI_ClassificationJob_LifeCycle_Status]
           ([JobId]
           ,[LifeCycleLookupId]
           ,[LifeCycleStatusLookupId]
           ,[DueDate]
		   ,[IsActive]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
	VALUES
			(
			@JobId
			,@LifeCycleLookupId
			,@LifeCycleStatusLookupId
			,@DueDate
			,@IsActive
			,@Author
			,GetDATE()
			,@Author
			,GETDATE()
			)
SET @ID=SCOPE_IDENTITY();
IF( @ID>0 )
BEGIN
EXEC prc_CWI_SetJobLifeCycleStatus @JobId
END			
END
ELSE
BEGIN
SET @ID=(select ID from [CWI_ClassificationJob_LifeCycle_Status] where JobId=@JobId and LifeCycleLookupId=@LifeCycleLookupId and LifeCycleStatusLookupId=@LifeCycleStatusLookupId);
	UPDATE [dbo].[CWI_ClassificationJob_LifeCycle_Status]
	SET
			[JobId]=@JobId
           ,[LifeCycleLookupId]=@LifeCycleLookupId
           ,[LifeCycleStatusLookupId]=@LifeCycleStatusLookupId
           ,[DueDate]=@DueDate 
		   ,[IsActive]=@IsActive         
           ,[ModifiedBy]=@Author
           ,[ModifiedOn]=GETDATE() where id=@ID;

IF( @ID>0 )
BEGIN
EXEC prc_CWI_SetJobLifeCycleStatus @JobId
END	
END
	
END

' 
END
GO
