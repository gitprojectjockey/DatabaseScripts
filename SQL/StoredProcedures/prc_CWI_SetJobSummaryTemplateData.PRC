/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobSummaryTemplateData]    Script Date: 5/29/2014 2:31:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobSummaryTemplateData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobSummaryTemplateData]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobSummaryTemplateData]    Script Date: 5/29/2014 2:31:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobSummaryTemplateData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobSummaryTemplateData  
* Purpose : This PROC would be called TO get the rundates template field values for the selected jobs
* Invoked from : JobSummary.aspx
* CREATED: Saravanan M
* MODIFICATION HISTORY  
* DATE        AUTHOR          DESCRIPTION             
  19-Dec-2013  Saravanan 
**********************************************************************  
Execution example :
**********************************************************************  

**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetJobSummaryTemplateData]
	@JobId int,
	@inUserId int,
	@templatevalues XML
AS
BEGIN
	DECLARE @AuthorName varchar(500);
	SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId;
	 declare @hasOuterTransaction bit = case when @@trancount > 0 then 1 else 0 end;
	 if @hasOuterTransaction = 0
	 begin
		BEGIN TRANSACTION 
	end

	BEGIN TRY
		DECLARE @dt varchar(50);
		SET @dt  =FORMAT( getdate(), ''MM/dd/yyyy hh:mm tt'');
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
			COALESCE(NULLIF(COLX.value(''(./FieldValue)[1]'',''varchar(max)''),''''),NULL) fldval
		from @templatevalues.nodes(''DocumentElement/TemplateData'') AS TABX(COLX)
			
		DECLARE @delimiter CHAR(1) = CHAR(225);
		
	DECLARE @tblJobSummary TABLE
		(
			   comment varchar(max),
			   oldValue varchar(max),
			   newValue varchar(max),
			   fieldName Varchar(MAX)
		)
		
		UPDATE [dbo].[CWI_JobSummaryTemplateData]
		SET FieldValue = t.FieldValue
		OUTPUT
		CASE WHEN DELETED.FieldValue<>INSERTED.FieldValue THEN 
			case when tf.TypeLookupId = 9104 and tf.LookupTypeId is not null then 
				''''+TF.FieldLabel+''''+'' modified from {DELETED.FieldValue} to {INSERTED.FieldValue}''+@delimiter  
			else
				''''+TF.FieldLabel+''''+'' modified from ''+DELETED.FieldValue+ '' to '' +INSERTED.FieldValue+@delimiter
			end
		ELSE '''' end ,
		DELETED.FieldValue, inserted.FieldValue,TF.FieldLabel
		INTO @tblJobSummary
		FROM [dbo].[CWI_JobSummaryTemplateData] TTD
		INNER JOIN  @tbl t
		ON TTD.TemplateFieldId = t.FieldId 
		Inner Join CWI_TaskTemplateField TTF
		ON TTd.TemplateFieldId=TTF.Id
		INNER JOIN CWI_TaskField TF
		ON TTf.TaskFieldId = tF.Id  
		where TTD.JobId = @JobId;

		
		UPDATE @tblJobSummary
		SET
			comment=REPLACE(fieldName+'' modified from ''+ LO.LookupName+'' to ''++ LN.LookupName+@delimiter ,comment,'''')
		from @tblJobSummary TJS		
		right Join Lookup LN ON CONVERT(varchar, LN.Id)=TJS.newValue
		right JOIN Lookup LO ON CONVERT(varchar,LO.id)=TJS.oldValue
		 where ISNULL(comment,'''')<>''''
		

		DECLARE @updHistory varchar(max),@ActionVal varchar(max);
					SET @updHistory=(SELECT SUBSTRING((SELECT '','' + comment FROM @tblJobSummary FOR XML PATH('''')), 2,200000))		
				
				DECLARE @tblAction TABLE
				(
					   ObjLookupId INt,
					   ObjectId INT,
					   ActionLookupId INT,
					   ActionVal Varchar(max)
	   
				)
		INSERT INTO @tblAction SELECT  205,@JobId,10007,Items FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@updHistory,@delimiter) WHERE LTRIM(RTRIM(items)) <> '''';
		UPDATE @tblAction SET ActionVal= REPLACE( ActionVal,'','','''')---this line added for removing all leading & trailing commas---
		
		INSERT INTO CWI_Action Select TA.ObjLookupId,TA.ObjectId,TA.ActionLookupId,TA.ActionVal + '' by '' + @AuthorName + '' on '' +convert(varchar,@dt),TA.ActionVal,@inUserId,@dt from @tblAction TA where TA.ActionVal <>'''';
	
		INSERT [dbo].[CWI_JobSummaryTemplateData]
			( [JobId], TemplateFieldId, FieldValue, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT
			@JobId,
			FieldId,
			t.FieldValue,
			@inUserId,
			@dt,@inUserId, @dt
		FROM
		@tbl t
		LEFT OUTER JOIN [dbo].[CWI_JobSummaryTemplateData] TTD
		ON TTD.TemplateFieldId = t.FieldId AND TTD.[JobId] = @JobId
		WHERE TTD.Id IS NULL;
		DECLARE @InsertId int=0;
		SET @InsertId =SCOPE_IDENTITY();

	IF( @InsertId>0 )
		
			DECLARE @UpdateAction varchar(max), @TemplateFieldId int=0,@TemplateName varchar(500);
			Select @TemplateFieldId=TemplateFieldId from CWI_JobSummaryTemplateData where id=@InsertId;

			SELECT top 1 @TemplateName=TT.Name from CWI_TaskTemplate TT
			INNER JOIN
				CWI_TaskTemplateField TTF on TT.Id=TTF.TaskTemplateId 
			INNER JOIN
				CWI_JobSummaryTemplateData JTD ON JTD.TemplateFieldId=TTF.Id
			WHERE TTF.Id=@TemplateFieldId AND JTD.JobId=@JobId; 
			--SET @UpdateAction = ''''Job updated by '''' + @AuthorName + '''' on '''' + @dt
			DECLARE @UpdateActionLink varchar(max);
			SET @UpdateAction = ''Job Template ''+ @TemplateName +'' Created''+'' by '' + @AuthorName + '' on '' + convert(varchar,@dt);
			SET @UpdateActionLink=''Job template '' + @TemplateName ;--+ '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@JobId) + ''>'' + ''</a>'' + ''created by '' + @AuthorName + '' on '' + @dt
			
		IF( LTRIM(RTRIM(@TemplateName))<>'''' )
			
		
				EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @JobId,
				@ActionLookupId = 10007,
				@Action = @UpdateAction,
				@ActionWithLink = @UpdateActionLink,
				@CreatedBy = @inUserId

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
END' 
END
GO
