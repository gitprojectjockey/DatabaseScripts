/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUserGroups]    Script Date: 11/21/2013 4:30:56 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetUserGroups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetUserGroups]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetUserGroups]    Script Date: 11/21/2013 4:30:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetUserGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetUserGroups  
* Purpose : This PROC would be called TO inert/update all the groups of a user
* Invoked from : ClientWise.master
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetUserGroups @groups=''IDC,IDC1'', @userid= 3, @authorid = 3
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetUserGroups] 
	@groups varchar(max),
	@userid int ,
	@authorid int  --used to insert for createdby column
	
	
AS
    
    DECLARE @tblGroups TABLE(gid int null,Item varchar(max))
	--comma seperated groups are inserted into the temp table
	INSERT INTO @tblGroups (item)
	select * FROM dbo.fnc_utl_Split(@groups,'','')

	DECLARE @author varchar(1000) = NULL
	declare @message NVARCHAR(2000) = ''''

	SELECT @author = Domain + ''\'' + [Login] FROM CWI_User 
	WHERE Id = @authorid

	IF @author IS NULL
	BEGIN
		SET @message = ''Invalid author ''  ;
		THROW 50000, @message , 1;  
	END

	
	-- missed AD groups will be inserted into the database
	INSERT INTO [dbo].[CWI_Group]
				([GroupName]
				,[IsActive]
				,[CreatedBy]
				,[CreatedOn]
				,[ModifiedBy]
				,[ModifiedOn])
	SELECT t.Item,1,@Author, getdate(),@Author, getdate()  FROM @tblGroups t 
	LEFT OUTER JOIN CWI_Group G ON t.Item = G.GroupName
	WHERE G.Id is NULL
 
	UPDATE @tblGroups SET GId = G.Id
	FROM CWI_Group G
	WHERE G.GroupName = Item


	DELETE CWI_UserGroup
	FROM CWI_UserGroup UG
	LEFT OUTER JOIN @tblGroups G
		ON UG.GroupID = G.GId 
	WHERE G.gid is NULL AND UG.UserID = @userid;
	
	INSERT INTO CWI_UserGroup
	(
		GroupID,
		UserID,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn
	)
    SELECT G.gid,
		@userid,
		@authorid,
		getdate(),
		@authorid,
		getdate()
	FROM CWI_UserGroup UG
	RIGHT OUTER JOIN @tblGroups G
		ON UG.GroupID = G.GId AND UG.UserID = @userid
	WHERE UG.id is NULL	
RETURN 0 

' 
END
GO


