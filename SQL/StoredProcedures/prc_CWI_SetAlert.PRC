/****** Object:  StoredProcedure [dbo].[prc_CWI_SetAlert]    Script Date: 3/12/2014 7:12:45 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetAlert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetAlert]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetAlert]    Script Date: 3/12/2014 7:12:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetAlert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************  
* PROCEDURE: [prc_CWI_SetAlert]  
* Purpose : This PROC would be called To set alert
* Invoked from : Different pages
* CREATED: Mohan
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetAlert] 
**********************************************************************/
CREATE PROC [dbo].[prc_CWI_SetAlert]
	@Id bigint=null out,
	@ObjectLookupId int,
	@ObjectId int,
	@Title varchar(100),
	@Summary varchar(8000) = NULL,
	@QueryStringValue varchar(8000),
	@AlertOn datetime,
	@RepeatLookupId int,
	@EndDate datetime = NULL,
	@Author int
AS

DECLARE @dt datetime
DECLARE @OriginURL varchar(8000)
SET @dt = getdate()
IF @ObjectLookupId=205 -- Job
			SET @OriginURL='' ../jobs.aspx?jobid='' + Convert(varchar,@QueryStringValue)  
	ELSE -- Settlement i.e. 212
			SET @OriginURL='' ../settlement.aspx?MMRPO='' + Convert(varchar,@QueryStringValue) 

IF @Id IS NULL OR @Id=0
BEGIN
	INSERT CWI_Alert
	(ObjectLookupId, ObjectId, Title, Summary, OriginURL, 
	AlertOn, RepeatLookupId, EndDate, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
	VALUES (@ObjectLookupId, @ObjectId, @Title, @Summary, @OriginURL, @AlertOn, 
	@RepeatLookupId, @EndDate, @Author, @dt, @Author, @dt)

	SET @Id = SCOPE_IDENTITY()
END
ELSE
BEGIN
	UPDATE	CWI_Alert
	SET	ObjectLookupId = @ObjectLookupId,
		ObjectId = @ObjectId,
		Title = @Title,
		Summary = @Summary,
		OriginURL = @OriginURL,
		AlertOn = @AlertOn,
		RepeatLookupId = @RepeatLookupId,
		EndDate = @EndDate,
		ModifiedBy = @Author,
		ModifiedOn = @dt
	WHERE 	Id = @Id
END






' 
END
GO
