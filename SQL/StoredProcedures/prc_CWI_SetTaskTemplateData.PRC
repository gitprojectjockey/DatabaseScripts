/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTaskTemplateData]    Script Date: 7/10/2014 6:55:23 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTaskTemplateData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetTaskTemplateData]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTaskTemplateData]    Script Date: 7/10/2014 6:55:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTaskTemplateData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [dbo].[prc_CWI_SetTaskTemplateData]
	@taskid bigint,
	@author int,
	@templatevalues XML
AS
BEGIN

	 declare @hasOuterTransaction bit = case when @@trancount > 0 then 1 else 0 end;
	 if @hasOuterTransaction = 0
	 begin
		BEGIN TRANSACTION 
	end

	BEGIN TRY
		DECLARE @dt datetime = getdate()
		-- temporary table to store the data from XML

		DECLARE @tbl TABLE
		(
			FieldId int,
			FieldValue varchar(max)
		)

		--Read the data from XML and store in the table variable
		INSERT INTO @tbl
		(
			FieldId,
			FieldValue
		)
		
		select 
			COLX.value(''(./FieldId)[1]'',''int'') fldid,
			COLX.value(''(./FieldValue)[1]'',''varchar(max)'') fldval
		from @templatevalues.nodes(''DocumentElement/TemplateData'') AS TABX(COLX)
			

		UPDATE 
			CWI_TaskTemplateData 
		SET 
			FieldValue = t.FieldValue
		FROM
			CWI_TaskTemplateData TTD
			INNER JOIN  @tbl t
				ON TTD.TemplateFieldId = t.FieldId AND TTD.TaskId = @taskid

		INSERT CWI_TaskTemplateData
			( TaskId, TemplateFieldId, FieldValue, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT
			@TaskId,
			FieldId,
			t.FieldValue,
			@Author,
			@dt,@Author, @dt
		FROM
		@tbl t
		LEFT OUTER JOIN CWI_TaskTemplateData TTD
		ON TTD.TemplateFieldId = t.FieldId AND TTD.TaskId = @taskid
		WHERE TTD.Id IS NULL

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
		BEGIN
			if @hasOuterTransaction = 0
			 begin
				ROLLBACK TRANSACTION ;
			end
		END	
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		if @hasOuterTransaction = 0
			 begin
				COMMIT TRANSACTION ;
			end
		

	
END


' 
END
GO


