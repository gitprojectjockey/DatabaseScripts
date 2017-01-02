IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetAction]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetAction 
* Purpose : This PROC would be called to return the actions of object
* Invoked from : multiple pages
* CREATED: MohanKumar 05SEP13
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
  prc_CWI_GetAction   11, 401, 1

**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_GetAction]
	@ObjectLookupId int,
	@ObjectId int,
	@IsActionWithLink bit = 1
AS
BEGIN

	SELECT CASE @IsActionWithLink WHEN 1 THEN ActionWithLink ELSE [Action] END AS [Action],CreatedOn
	FROM CWI_Action
	WHERE ObjectLookupId = @ObjectLookupId
		AND ObjectId = @ObjectId
	ORDER BY ID DESC
END' 
END
GO


