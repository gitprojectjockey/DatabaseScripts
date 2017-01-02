/****** Object:  StoredProcedure [dbo].[prc_CWI_GetComments]    Script Date: 8/19/2014 3:04:39 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetComments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetComments]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetComments]    Script Date: 8/19/2014 3:04:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetComments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetComments 
* Purpose : This PROC would be called TO get all the comments associated with a module/category
* Invoked from : Comment.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  13AUG14	Mohankumar		User names retuned instead of from CWI_User table       

**********************************************************************  
Execution example :
**********************************************************************  
DECLARE 
    @inObjectLookupId int,
	@inObjectId int
exec prc_CWI_GetComments 209,1337,''209''
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetComments]    
    @inObjectLookupId int,
	@inObjectId bigint,
	@vcAssociatedLookupIds varchar(MAX)=NULL
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF ISNULL(@vcAssociatedLookupIds,'''') =''''
		BEGIN
			DECLARE @IsRoot BIT=1
			SELECT C.Id AS CommentId,Comment,C.ObjectLookupId,C.ObjectId,
			C.CreatedOn,C.ModifiedOn,
			CASE WHEN C.CreatedBy = 1 /* system*/ THEN C.CreatedByEmail
												ELSE UC.Names END Author,
			C.CreatedBy AS UserId, 
			@IsRoot IsRoot			
			FROM CWI_Comment AS C 
			INNER JOIN CWI_User UC
				ON UC.Id = C.CreatedBy
			WHERE 
				[ObjectLookupId]=@inObjectLookupId 
				AND [ObjectId]=@inObjectId
			ORDER BY ModifiedOn DESC
		END
		ELSE
		BEGIN
			DECLARE @tblAssociatedLookupId TABLE(LookupId INT, IsRoot BIT)

			INSERT INTO @tblAssociatedLookupId
			SELECT CAST(t.Items AS INT),0 FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@vcAssociatedLookupIds,'','') t
			WHERE t.Items<>''''

			INSERT INTO @tblAssociatedLookupId VALUES (@inObjectLookupId,1)

			SELECT C.Id as CommentId,Comment,C.ObjectLookupId,C.ObjectId,
			C.CreatedOn,C.ModifiedOn,
			CASE WHEN C.CreatedBy = 1 /* system*/ THEN C.CreatedByEmail
												ELSE UC.Names END Author,
			C.CreatedBy AS UserId,  
			t.IsRoot IsRoot		
			FROM CWI_Comment AS C 
			INNER JOIN @tblAssociatedLookupId t 
				ON t.LookupId=c.ObjectLookupId
			INNER JOIN CWI_User UC
				ON UC.Id = C.CreatedBy
			WHERE [ObjectId]=@inObjectId
			ORDER BY ModifiedOn DESC
		END
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
	SET NOCOUNT OFF
END





' 
END
GO


