IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetGroupDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetGroupDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetGroupDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetGroupDocument
* Purpose : This PROC would be called TO set rights of group document types
* Invoked from : Groups.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetGroupDocument @DocType = ''<DocumentElement>
  <GroupDocType>
    <DocTypeId>1</DocTypeId>
    <DocName></DocName>
    <IsRead>false</IsRead>
    <IsReadWrite>false</IsReadWrite>
    <IsDelete>false</IsDelete>
  </GroupDocType>
  <GroupDocType>
    <DocTypeId>2</DocTypeId>
    <DocName></DocName>
    <IsRead>true</IsRead>
    <IsReadWrite>false</IsReadWrite>
    <IsDelete>false</IsDelete>

  </GroupDocType></DocumentElement>'', @GroupId=1, @UserId=1
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetGroupDocument] 
    @DocType XML,
	@GroupId int,
	@UserId	int
AS

BEGIN


	-- temporary table to store the data from XML

	DECLARE @tbl TABLE
	(
		DocTypeId int,
		GroupId1 int,
		IsRead bit,
		IsReadWrite bit,
		IsDelete bit
	)

	BEGIN TRANSACTION Trans1

	BEGIN TRY
		--Read the data from XML and store in the table variable
		INSERT INTO @tbl
		(
			DocTypeId ,
			IsRead ,
			IsReadWrite ,
			IsDelete 
		)
		select 
		SUBSTRING(COLX.value(''(./DocTypeId)[1]'',''varchar(20)''),2,20),
		COLX.value(''(./IsRead)[1]'',''bit''),
		COLX.value(''(./IsReadWrite)[1]'',''bit''),
		COLX.value(''(./IsDelete)[1]'',''bit'')
		--,TABX.COLX.query(''.'')
		from @DocType.nodes(''DocumentElement/GroupDocType'') AS TABX(COLX)

		--Update the document rights for the existing group documents
		Update CWI_GroupDocument SET IsRead = t.IsRead, IsReadWrite = t.IsReadWrite, IsDelete = t.IsDelete, 
			ModifiedBy = @UserId, ModifiedOn=GETDATE()
		FROM 
		 @tbl t
		 WHERE GroupId = @GroupId AND DocCategoryId = t.DocTypeId 

		--Insert the document rights for the non-existing group documents
		INSERT INTO CWI_GroupDocument
		(
		GroupId,
		DocCategoryId,
		IsRead,
		IsReadWrite,
		IsDelete,
		CreatedBy,
		ModifiedBy
		)
		SELECT
		@GroupId,
		DocTypeId,
		t.IsRead,
		t.IsReadWrite,
		t.IsDelete,
		@UserId,
		@UserId
		FROM
		@tbl t
		LEFT OUTER JOIN CWI_GroupDocument GD
		ON GD.GroupId = @GroupId AND t.DocTypeId = GD.DocCategoryId
		WHERE GD.Id IS NULL
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
