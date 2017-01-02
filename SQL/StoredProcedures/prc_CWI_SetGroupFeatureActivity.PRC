IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetGroupFeatureActivity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetGroupFeatureActivity]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetGroupFeatureActivity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetGroupFeatureActivity
* Purpose : This PROC would be called TO set rights of group features and activities
* Invoked from : Groups.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetGroupFeatureActivity @Features=''<DocumentElement>
  <GroupFeature>
    <ItemId>1</ItemId>
    <Caption>Manage</Caption>
    <IsRead>false</IsRead>
    <IsReadWrite>false</IsReadWrite>
    <IsDelete>false</IsDelete>
    <GroupId>8</GroupId>
    <Type>Feature</Type>
  </GroupFeature>
  <GroupFeature>
    <ItemId>2</ItemId>
    <ParentId>1</ParentId>
    <Caption>Services</Caption>
    <IsRead>true</IsRead>
    <IsReadWrite>false</IsReadWrite>
    <IsDelete>false</IsDelete>
    <GroupId>8</GroupId>
    <Type>Activity</Type>
  </GroupFeature></DocumentElement>'', @UserId = 3
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetGroupFeatureActivity] 
    @Features XML,
	@UserId	int
AS

BEGIN


	-- temporary table to store the data from XML

	DECLARE @tbl TABLE
	(
		ItemId int,
		ItemIdString varchar(10),
		IsRead bit,
		IsReadWrite bit,
		IsDelete bit,
		GroupId1 int,
		Type varchar(100)
	)

	BEGIN TRANSACTION Trans1

	BEGIN TRY
		--Read the data from XML and store in the table variable
		INSERT INTO @tbl
		(
			ItemIdString ,
			IsRead ,
			IsReadWrite ,
			IsDelete ,
			GroupId1 ,
			Type 
		)
		select 
		COLX.value(''(./ItemId)[1]'',''varchar(10)''),
		COLX.value(''(./IsRead)[1]'',''bit''),
		COLX.value(''(./IsReadWrite)[1]'',''bit''),
		COLX.value(''(./IsDelete)[1]'',''bit''),
		COLX.value(''(./GroupId)[1]'',''int''),
		COLX.value(''(./Type)[1]'',''varchar(100)'')
		--,TABX.COLX.query(''.'')
		from @Features.nodes(''DocumentElement/GroupFeature'') AS TABX(COLX)

		UPDATE @tbl SET ItemId = CAST(SUBSTRING( ItemIdString,2, 20) as int)

		--Update the feature rights for the existing group features
		Update CWI_GroupFeature SET IsRead = t.IsRead, IsReadWrite = t.IsReadWrite, IsDelete = t.IsDelete
			, ModifiedBy = @UserId, ModifiedOn = GETDATE()
		FROM 
		 @tbl t
		 WHERE GroupId = t.GroupId1 AND MenuId = t.ItemId AND t.Type = ''Feature''

		--Insert the feature rights for the non-existing group features
		INSERT INTO CWI_GroupFeature
		(
		GroupId,
		MenuId,
		IsRead,
		IsReadWrite,
		IsDelete,
		CreatedBy,
		ModifiedBy
		)
		SELECT
		t.GroupId1,
		ItemId,
		t.IsRead,
		t.IsReadWrite,
		t.IsDelete,
		@UserId,
		@UserId
		FROM
		@tbl t
		LEFT OUTER JOIN CWI_GroupFeature GF
		ON t.GroupId1 = GF.GroupId AND t.ItemId = GF.MenuId
		WHERE t.Type = ''Feature''
		and GF.Id IS NULL

		--Update the activity rights for the existing group activities
		Update CWI_GroupActivity SET IsRead = t.IsRead, IsReadWrite = t.IsReadWrite, IsDelete = t.IsDelete
			, ModifiedBy = @UserId, ModifiedOn = GETDATE()
		FROM 
		 @tbl t
		 WHERE GroupId = t.GroupId1 AND ActivityId = t.ItemId AND (t.Type = ''Activity'' OR t.Type = ''Area'')

		--Insert the activity rights for the non-existing group activities
		INSERT INTO CWI_GroupActivity
		(
		GroupId,
		ActivityId,
		IsRead,
		IsReadWrite,
		IsDelete,
		CreatedBy,
		ModifiedBy
		)
		SELECT
		t.GroupId1,
		ItemId,
		t.IsRead,
		t.IsReadWrite,
		t.IsDelete,
		@UserId,
		@UserId
		FROM
		@tbl t
		LEFT OUTER JOIN CWI_GroupActivity GA
		ON t.GroupId1 = GA.GroupId AND t.ItemId = GA.ActivityId
		WHERE (t.Type = ''Activity'' OR t.Type = ''Area'')
		and GA.Id IS NULL 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;
END

' 
END
GO
