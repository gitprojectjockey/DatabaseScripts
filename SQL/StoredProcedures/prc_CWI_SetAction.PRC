IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetAction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetAction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetAction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetAction 
* Purpose : This PROC would be called to insert actions performed against one object
* Invoked from : multiple places
* CREATED: MohanKumar 14JUL13
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
  prc_CWI_SetAction   
	@ObjectLookupId = 204,
	@ObjectId = 11,
	@ActionLookupId = 1,
	@Action = ''Plan Updated By Mohankumar on 07-04-2013 12:12'',
	@ActionWithLink = ''Plan Updated By Mohankumar on 07-04-2013 12:12'',,
	@CreatedBy = 2

**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_SetAction]
	@ObjectLookupId int,
	@ObjectId bigint,
	@ActionLookupId int,
	@Action varchar(8000),
	@ActionWithLink varchar(8000),
	@CreatedBy int
AS

INSERT CWI_Action(ObjectLookupId,ObjectId, ActionLookupId, Action, ActionWithLink, CreatedBy, CreatedOn)
VALUES (@ObjectLookupId,@ObjectId, @ActionLookupId, @Action, @ActionWithLink, @CreatedBy,  getdate())

RETURN SCOPE_IDENTITY()
' 
END
GO
