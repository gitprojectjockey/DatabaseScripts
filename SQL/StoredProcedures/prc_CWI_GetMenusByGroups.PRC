/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMenusByGroups]    Script Date: 6/4/2014 6:49:59 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMenusByGroups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetMenusByGroups]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMenusByGroups]    Script Date: 6/4/2014 6:49:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMenusByGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetMenusByGroups  
* Purpose : This PROC would be called TO get all the menu details for the passed groups
* Invoked from : ClientWise.master
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  04JUN14	Mohankumar		Root menu with page url is returned            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetMenusByGroups @groups=''IDC,IDC1'', @author = ''oss\msundaram'', @IsGroupInsert = 1,@IsAllMenu=1
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetMenusByGroups]
	@groups varchar(max),
	@author varchar(max) = '''', --used to insert for createdby column
	@IsGroupInsert bit = 1, --If 1, the missed AD groups will be inserted into the database
	@IsAllMenu bit =0 -- --If 1, all the menu will be returned with full rights "D"

AS

DECLARE @tbl TABLE
(
	MenuId int, 
	MenuCaption varchar(max),
	MenuLocation varchar(max),
	MenuPage varchar(max),
	SortOrder int,
	ParentId int,
	MenuRights varchar(2),
	IsHidden bit
)

DECLARE @tblGroups TABLE(Item varchar(max))
--comma seperated groups are inserted into the temp table
INSERT INTO @tblGroups
select * FROM dbo.fnc_utl_Split(@groups,'','')
where ltrim(rtrim(Items)) <> ''''


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

IF @IsAllMenu = 1
BEGIN
	INSERT INTO @tbl
	SELECT
		M.Id MenuId, 
		M.MenuCaption,
		M.MenuLocation,
		M.MenuPage,
		M.SortOrder,
		ParentId,
		''D'' MenuRights,
		IsHidden
	FROM
	
		CWI_Menu M 

	WHERE
		((M.ParentId IS NOT NULL OR ISNULL(M.MenuPage,'''') <> '''') AND M.IsActive = 1)
	
END
ELSE
BEGIN
	/* Getting all the menus with rights for the groups .
	Inner query aggregates the rights of different groups
	*/ 
	INSERT INTO @tbl
	SELECT
		M.Id MenuId, 
		M.MenuCaption,
		M.MenuLocation,
		M.MenuPage,
		M.SortOrder,
		ParentId,
		CASE WHEN IsDelete >0 THEN ''D'' WHEN IsReadWrite > 0 THEN ''RW'' WHEN IsRead > 0 THEN ''R'' ELSE '''' END MenuRights,
		IsHidden
	FROM
		(
			SELECT 
				MenuId,  sum(cast(IsRead as int)) IsRead, sum(cast(IsReadWrite as int)) IsReadWrite, sum(cast(IsDelete as int)) IsDelete
			FROM 
				CWI_GroupFeature GF 
				INNER JOIN CWI_Group G ON GF.GroupId = G.Id  and G.IsActive = 1 
					AND GroupName in (select * FROM @tblGroups)
			GROUP BY 
				MenuId
		) t

		INNER JOIN CWI_Menu M ON t.MenuId = M.Id and M.IsActive = 1

	WHERE
		((M.ParentId IS NULL  ) OR (t.IsDelete + t.IsReadWrite + IsRead) >0)

END


/*
INSERT INTO @tbl
select M.Id, M.MenuCaption, M.MenuLocation, M.MenuPage, M.SortOrder, M.ParentId
	,CASE WHEN IsDelete >0 THEN ''D'' WHEN IsReadWrite > 0 THEN ''RW'' WHEN IsRead > 0 THEN ''R'' ELSE '''' END MenuRights 
FROM @tbl t
INNER JOIN CWI_Menu m ON t.ParentId = M.Id*/

--Eliminate the parent menus that do not have any child menus
DELETE @tbl
FROM @tbl t
WHERE
t.Menuid not in
(
SELECT  t1.MenuId FROM @tbl t1  LEFT OUTER JOIN @tbl t2 ON t2.ParentId = t1.MenuId
WHERE (t1.ParentId is NOT NULL  OR ISNULL(t1.MenuPage,'''') <> '''' OR t2.MenuId is not null)
)

--Add the missing parent menus for the child menus
INSERT INTO @tbl
SELECT M.Id, M.MenuCaption, M.MenuLocation, M.MenuPage, M.SortOrder, M.ParentId ,'''',IsHidden
FROM
(
SELECT t1.ParentId FROM @tbl t1  LEFT OUTER JOIN @tbl t2 ON t1.ParentId = t2.MenuId
WHERE (t1.ParentId is NOT NULL AND  ISNULL(t1.MenuPage,'''') <> '''' AND t2.MenuId is null)
) x
INNER JOIN CWI_Menu M ON M.Id = x.ParentId

select distinct * from @tbl
ORDER BY SortOrder


' 
END
GO


