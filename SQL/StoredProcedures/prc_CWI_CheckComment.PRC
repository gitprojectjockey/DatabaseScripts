/****** Object:  StoredProcedure [dbo].[prc_CWI_CheckComment]    Script Date: 4/23/2014 6:18:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_CheckComment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_CheckComment]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_CheckComment]    Script Date: 4/23/2014 6:18:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_CheckComment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_CheckComment 
* Purpose : This PROC would be called TO check the comments exists for the given 
* Invoked from : Comment.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
DECLARE 
    @inObjectLookupId int,
	@inObjectId int,
	@bitStatus BIT 
exec prc_CWI_CheckComment 201,1, @bitStatus  OUTPUT
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_CheckComment]    
    @inObjectLookupId int,
	@inObjectId bigint,
	@bitStatus bit OUTPUT
AS
BEGIN	
	BEGIN TRY
		IF (SELECT COUNT(*) FROM 	CWI_Comment			
		WHERE [ObjectLookupId]=@inObjectLookupId AND [ObjectId]=@inObjectId) <> 0
		BEGIN
			SET @bitStatus = 1
		END
		ELSE
		BEGIN
			SET @bitStatus = 0
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


