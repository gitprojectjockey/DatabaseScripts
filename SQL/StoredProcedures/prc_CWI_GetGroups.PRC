/****** Object:  StoredProcedure [dbo].[prc_CWI_GetGroups]    Script Date: 7/21/2014 7:17:24 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetGroups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetGroups]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetGroups]    Script Date: 7/21/2014 7:17:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetGroups  
* Purpose : This PROC would be called TO get all the groups
* Invoked from : Groups.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetGroups @groups=''IDC,IDC1'', @author = ''oss\msundaram'',@IsActive = 1, @IsGroupInsert = 1
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetGroups] 
	@groups varchar(max),
	@author varchar(max) = '''', --used to insert for createdby column
	@IsActive bit = 1, -- 1 means active groups
	@IsGroupInsert bit = 1 --If 1, the missed AD groups will be inserted into the database
	
AS
    DECLARE @tblGroups TABLE(Item varchar(max))
	--comma seperated groups are inserted into the temp table
	INSERT INTO @tblGroups
	select * FROM dbo.fnc_utl_Split(@groups,'','') WHERE Items <>''''


	IF( @IsGroupInsert = 1 )
	BEGIN
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
 

	END

	SELECT Id, GroupName FROM CWI_Group WHERE IsActive = @IsActive
RETURN 0 

' 
END
GO


