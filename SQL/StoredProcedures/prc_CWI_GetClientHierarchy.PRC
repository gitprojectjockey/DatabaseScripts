IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientHierarchy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientHierarchy]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientHierarchy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientHierarchy  
* Purpose : This PROC would be called TO get client/division hierarchy 
* Invoked from : Client.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClientHierarchy 13958,1
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetClientHierarchy]
	@ClientId int,
	@IsAllDivisions bit = 0
AS

DECLARE @tbl TABLE
(
	ClientId int,
	ClientCode varchar(10),
	ClientName varchar(300),
	ParentId int
)

INSERT INTO @tbl
SELECT Id, ClientCode, ClientName, ParentID FROM CWI_Client WHERE Id = @ClientId
 
DECLARE @ParentId int
SET @ParentId = NULL
SELECT top 1 @ParentId = ParentId FROM @tbl

IF @ParentId IS NULL -- Client passed
begin
	INSERT INTO @tbl
	SELECT Id, ClientCode, ClientName, ParentID 
	FROM dbo.CWI_Client AS C			
		WHERE C.ParentID=@ClientId

	
end
ELSE
begin -- Division passed
	INSERT INTO @tbl
	SELECT Id, ClientCode, ClientName, ParentID  from CWI_Client
	WHERE Id = @ParentId

	IF @IsAllDivisions =1 
	BEGIN
		INSERT INTO @tbl
		SELECT Id, ClientCode, ClientName, ParentID 
		FROM dbo.CWI_Client AS C			
		WHERE C.ParentID=@ParentId
			AND Id <> @ClientId
	END
end

SELECT * FROM @tbl

' 
END
GO


