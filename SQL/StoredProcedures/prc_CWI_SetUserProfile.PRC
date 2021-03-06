/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUserProfile]    Script Date: 10/16/2014 9:16:59 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetUserProfile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetUserProfile]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUserProfile]    Script Date: 10/16/2014 9:16:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetUserProfile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetUserProfile
* Purpose : This PROC would be called to update the user profile details
* Invoked from : ClientWise.master
* CREATED: Vijesh Mahi - 15/Oct/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_SetUserProfile]
	7,	
	''Vijesh'',	
	''vijesh.kattil@xerox.com,
	''oss\vmahi'',
	@inRowCount int OUTPUT

**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetUserProfile]
	@inUserId int,	
	@vcUserName varchar(200),	
	@vcEmail varchar(100)
	
AS
	BEGIN 
		
		BEGIN TRY
			declare @author varchar(200)
			select @author= Domain+''\''+Login from CWI_User where Id=@inUserId

			update [dbo].[CWI_User] set
				Names=@vcUserName,
				Email=@vcEmail,
				ModifiedBy=@author,
				ModifiedOn=getdate()
			where Id=@inUserId
			
		END TRY
		BEGIN CATCH			
			EXEC prc_CWI_AppRaiseError;
			THROW;
		END CATCH		

	END



' 
END
GO
