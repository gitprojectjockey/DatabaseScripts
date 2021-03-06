/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobAssigneeDetails]    Script Date: 5/5/2014 1:25:38 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobAssigneeDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobAssigneeDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobAssigneeDetails]    Script Date: 5/5/2014 1:25:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobAssigneeDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetJobAssigneeDetails]
* Purpose : This PROC would be called TO retrieve assignee details while creating a new job
* Invoked from : Jobs.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetJobAssigneeDetails] 
@Assignee=''
<DocumentElement>
  <Assignee>
    <UserId>8</UserId>
    <GroupId>0</GroupId>
    <UserName />
    <GroupName />
    <IsCopied>false</IsCopied>
    <IsRemoved>false</IsRemoved>
    <CreatedBy>7</CreatedBy>
    <CreatedOn>2014-04-29T19:58:34.3209805+05:30</CreatedOn>
    <ModifiedBy>7</ModifiedBy>
    <ModifiedOn>2014-04-29T19:58:34.3209805+05:30</ModifiedOn>
  </Assignee>
  <Assignee>
    <UserId>7</UserId>
    <GroupId>0</GroupId>
    <UserName />
    <GroupName />
    <IsCopied>false</IsCopied>
    <IsRemoved>false</IsRemoved>
    <CreatedBy>7</CreatedBy>
    <CreatedOn>2014-04-29T19:58:34.3219575+05:30</CreatedOn>
    <ModifiedBy>7</ModifiedBy>
    <ModifiedOn>2014-04-29T19:58:34.3219575+05:30</ModifiedOn>
  </Assignee>
  <Assignee>
    <UserId>16</UserId>
    <GroupId>0</GroupId>
    <UserName />
    <GroupName />
    <IsCopied>true</IsCopied>
    <IsRemoved>false</IsRemoved>
    <CreatedBy>7</CreatedBy>
    <CreatedOn>2014-04-29T19:58:34.3219575+05:30</CreatedOn>
    <ModifiedBy>7</ModifiedBy>
    <ModifiedOn>2014-04-29T19:58:34.3219575+05:30</ModifiedOn>
  </Assignee>
</DocumentElement>''
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetJobAssigneeDetails] 		
	@Assignee XML
AS

BEGIN TRY
	
	DECLARE @tbl TABLE
	(
		UserId1 int,
		GroupId1 int,
		IsCopied1 bit,
		IsRemoved1 bit
	)

	--Read the data from XML and store in the table variable
		INSERT INTO @tbl
		(
			UserId1 ,
			GroupId1,
			IsCopied1,
			IsRemoved1
		)
		select
			distinct
			case when usrid = 0 then NULL else usrid end,
			grpid ,
			iscopied,
			IsRemoved
		from
		(
		select 
			COLX.value(''(./UserId)[1]'',''varchar(20)'') usrid,
			COLX.value(''(./GroupId)[1]'',''varchar(20)'') grpid,
			COLX.value(''(./IsCopied)[1]'',''bit'') iscopied,
			COLX.value(''(./IsRemoved)[1]'',''bit'') IsRemoved
		from @Assignee.nodes(''DocumentElement/Assignee'') AS TABX(COLX)
		) x		

		
		SELECT 		
		ISNULL(UserId1,'''') as UserId,
		ISNULL(GroupId1,'''') as GroupId,
		ISNULL(U.Names,'''') UserName,
		ISNULL(G.GroupName,'''') AS GroupName,
		IsCopied1 as IsCopied,
		IsRemoved1 as IsRemoved		
	FROM  @tbl t 
	LEFT OUTER JOIN CWI_User U ON U.id = t.UserId1
	LEFT OUTER JOIN CWI_Group G ON G.id = t.GroupId1


		
	END TRY
	BEGIN CATCH
		
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	




' 
END
GO
