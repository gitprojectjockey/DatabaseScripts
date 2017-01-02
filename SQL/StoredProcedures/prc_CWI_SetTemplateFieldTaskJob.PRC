/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTemplateFieldTaskJob]    Script Date: 10/14/2014 6:46:56 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTemplateFieldTaskJob]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetTemplateFieldTaskJob]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTemplateFieldTaskJob]    Script Date: 10/14/2014 6:46:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTemplateFieldTaskJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [dbo].[prc_CWI_SetTemplateFieldTaskJob]
	
       @TemplateName varchar(400) ,  /*MANDATORY - template name   */
       @Classification varchar(max) , /*MANDATORY -(Newspaper,Magazine,Radio,Job Boards,Television,JiggyJobs,Digital Media,Billboard,Brochure,PrintPromo,Social Media)   */
       @Author int , /*MANDATORY - windows login without domain oss */
       @FieldName Varchar(400) , /*MANDATORY - ex: Newspaper RunDate */
       @FieldLabel Varchar(400) , /*MANDATORY - ex : RunDate1 */
       @TypeLookupId int , /*MANDATORY - Textbox, Textarea, Datecalendar, Dropdownlist, Checkbox, Number */
       @MinLength int = 0,
       @MaxLength int = 0, 
       @IsRequiredCount bit = 1,
       @RepeatCount int = 0,
       @ValidateMask Varchar(400) = NULL,
       @ValidateFunction varchar(400) = NULL,
       @FieldValuesLookupTypeId int = null,/* lookuptype table id for populating dropdownlist,for example 33 - AdType   */
       @ListText Varchar(max) = NULL,/*  If dropdown values are not from lookup table, values can be given seperated by comma. For example, Select,  LineAd, Display AD   */
       @Width int = 0,
       @DefaultValue varchar(max) = '''',
       @DisplayOrder int = 0,
	   @ForJobOrTask  char(1)=''T'', /*MANDATORY - 1- task template and 0 =  job template */
	   @MappingLookupId int = NULL, /* lookup values for type id 40 */
	   @Assignee XML = NULL,
	   @EstimatedPeriodLookupID int  = NULL,
	   @EstimatedPeriod numeric(9,2) = NULL

AS


DECLARE @tblClass TABLE
(
	ClassId int
)

INSERT INTO @tblClass
SELECT cast(Items as int) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@Classification,'','')

DECLARE 
@TaskTemplateId int = NULL,
@TaskFieldId int = NULL


declare @messageClass NVARCHAR(2000) = '''', @dt datetime = getdate()

Select @TaskTemplateId = Id from [CWI_TaskTemplate] WHERE Name = @TemplateName

--IF NOT Exists(Select * from [CWI_TaskTemplate] where Name=@TemplateName AND ClassLookupId=@ClassificationLookupId) 
IF @TaskTemplateId IS NULL
BEGIN
       INSERT [dbo].[CWI_TaskTemplate] ( [Name],  [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) 
       VALUES 
       ( @TemplateName, @Author, @dt,@Author, @dt)
       set @TaskTemplateId=SCOPE_IDENTITY();
END
--ELSE
--BEGIN
--		UPDATE CWI_TaskTemplate 
--		SET 
			
--			[ModifiedBy]=@Author,
--			 [ModifiedOn]=@dt 
--		WHERE Id=@TaskTemplateId;
--END

IF @FieldName <> ''''
BEGIN

	Select @TaskFieldId = Id from [CWI_TaskField] WHERE FieldName = @FieldName
	IF @TaskFieldId IS NULL
	BEGIN
		   INSERT [dbo].[CWI_TaskField] 
			( [FieldName], [FieldLabel], [TypeLookupId], [MinLength], [MaxLength], [IsRequiredCount], [RepeatCount], [ValidateMask], [ValidateFunction], [LookupTypeId], [ListText], [Width], [DefaultValue], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn],

	MappingLookupId) VALUES
		   ( @FieldName, @FieldLabel, @TypeLookupId,@MinLength,@MaxLength,@IsRequiredCount, @RepeatCount,@ValidateMask , @ValidateFunction, @FieldValuesLookupTypeId, @ListText, @Width, @DefaultValue, @Author, @dt,  @Author, @dt,@MappingLookupId)
		   SET @TaskFieldId =SCOPE_IDENTITY();
	END
	else
	begin
		UPDATE [CWI_TaskField] 
		SET 
			[FieldName] = @FieldName,
			[FieldLabel] = @FieldLabel, 
			[TypeLookupId] = @TypeLookupId, 
			[MinLength] = @MinLength, 
			[MaxLength]= @MaxLength, 
			[IsRequiredCount] = @IsRequiredCount, 
			[RepeatCount]= @RepeatCount, 
			[ValidateMask] = @ValidateMask, 
			[ValidateFunction] = @ValidateFunction, 
			[LookupTypeId] = @FieldValuesLookupTypeId, 
			[ListText] = @ListText, 
			[Width] = @Width, 
			[DefaultValue] = @DefaultValue, 
			 [ModifiedBy] = @Author, 
			 [ModifiedOn] = @dt,
			 MappingLookupId = @MappingLookupId
		  WHERE
			Id = @TaskFieldId
	end

	IF NOT EXISTS (SELECT top 1 1 FROM [CWI_TaskTemplateField] WHERE [TaskTemplateId] = @TaskTemplateId AND TaskFieldId = @TaskFieldId)
	BEGIN
		   INSERT [dbo].[CWI_TaskTemplateField] ( [TaskTemplateId], [TaskFieldId], [DisplayOrder], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES
			 (@TaskTemplateId, @TaskFieldId, @DisplayOrder, 1, @Author, @dt,@Author, @dt)
	END
	ELSE
	BEGIN
		UPDATE [CWI_TaskTemplateField] 
		SET
			 [TaskTemplateId] = @TaskTemplateId, 
			 [TaskFieldId] = @TaskFieldId, 
			 [DisplayOrder] = @DisplayOrder, 
			 [IsActive] = 1, 
			  [ModifiedBy] = @Author,
			  [ModifiedOn] = @dt
		WHERE
			ID = (SELECT top 1 Id FROM [CWI_TaskTemplateField] WHERE [TaskTemplateId] = @TaskTemplateId AND TaskFieldId = @TaskFieldId)

	END
END
IF @ForJobOrTask = ''B'' OR @ForJobOrTask = ''T'' --if it is for task
begin
	INSERT INTO [CWI_TaskTemplateClassification] 
		   (TaskTemplateId,ClassificationLookupId,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
	SELECT @TaskTemplateId, t.ClassId, @Author, @dt, @Author, @dt FROM [CWI_TaskTemplateClassification] TTC
	RIGHT OUTER JOIN @tblClass t
		ON t.ClassId = TTC.ClassificationLookupId AND TTC.TaskTemplateId = @TaskTemplateId
		WHERE TTC.Id IS NULL

	
	UPDATE CWI_TaskTemplateClassification SET IsDeleted = (CASE WHEN t.ClassId IS NULL THEN 1 ELSE 0 END)
	FROM [CWI_TaskTemplateClassification] TTC
		LEFT OUTER JOIN @tblClass t
			ON t.ClassId = TTC.ClassificationLookupId 
	WHERE  
		TTC.TaskTemplateId = @TaskTemplateId

	IF @ForJobOrTask = ''T''
	begin
		UPDATE [CWI_JobTemplateClassification] SET IsDeleted = 1
		WHERE  
			JobTemplateId = @TaskTemplateId

		
	end
end
IF @ForJobOrTask = ''B'' OR @ForJobOrTask = ''J'' -- for jobs
begin
	INSERT INTO [CWI_JobTemplateClassification] 
		   (JobTemplateId,ClassificationLookupId,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
	SELECT @TaskTemplateId, t.ClassId, @Author, @dt, @Author, @dt FROM [CWI_JobTemplateClassification] TTC
	RIGHT OUTER JOIN @tblClass t
		ON t.ClassId = TTC.ClassificationLookupId AND TTC.JobTemplateId = @TaskTemplateId
		WHERE TTC.Id IS NULL

	
	
	UPDATE [CWI_JobTemplateClassification] SET IsDeleted = (CASE WHEN t.ClassId IS NULL THEN 1 ELSE 0 END)
	FROM [CWI_JobTemplateClassification] TTC
		LEFT OUTER JOIN @tblClass t
			ON t.ClassId = TTC.ClassificationLookupId 
	WHERE  
		TTC.JobTemplateId = @TaskTemplateId

	IF @ForJobOrTask = ''J''
	begin
		UPDATE CWI_TaskTemplateClassification SET IsDeleted = 1
		WHERE  
			TaskTemplateId = @TaskTemplateId
	end
end


IF @Assignee IS NOT NULL
BEGIN
	-- temporary table to store the data from assignee XML

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
			case when grpid = 0 then NULL else grpid end  ,
					
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

		INSERT CWI_TemplateAssignee
		( TemplateId, UserId, GroupId, IsCopied, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT
			@TaskTemplateId,
			UserId1,
			GroupId1,
			IsCopied1,
			@Author,
			dateadd(ss,1,@dt),@Author, @dt
		FROM
		@tbl t
		LEFT OUTER JOIN CWI_TemplateAssignee TA
		ON TA.TemplateId = @TaskTemplateId AND  ISNULL(t.UserId1,'''') = ISNULL(TA.UserId,'''') AND ISNULL(t.GroupId1,'''') = ISNULL(TA.GroupId,'''')
		AND TA.IsCopied = t.IsCopied1
		WHERE TA.Id IS NULL

		UPDATE 
			CWI_TemplateAssignee 
		SET 
			IsRemoved = IsRemoved1,
			ModifiedOn=@dt,
			ModifiedBy=@Author
		FROM
			CWI_TemplateAssignee TA
			INNER JOIN  @tbl t
				ON TA.TemplateId = @TaskTemplateId AND  ISNULL(t.UserId1,'''') = ISNULL(TA.UserId,'''') AND ISNULL(t.GroupId1,'''') = ISNULL(TA.GroupId,'''')
				AND TA.IsCopied = t.IsCopied1
		
		
END




DECLARE @templateDurationId int = NULL
SELECT @templateDurationId = Id FROM CWI_TaskTemplateDuration
WHERE TaskTemplateId = @TaskTemplateId

IF @templateDurationId IS NULL
Begin
	INSERT INTO CWI_TaskTemplateDuration
	(
		TaskTemplateId,
		EstimatedPeriodLookupID,
		EstimatedPeriod,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn
	)
	VALUES
	(
		@TaskTemplateId,
		@EstimatedPeriodLookupID,
		@EstimatedPeriod,
		@Author,
		@dt,
		@Author,
		@dt
	)
End
ELSE
Begin
	UPDATE CWI_TaskTemplateDuration
	SET
		EstimatedPeriodLookupID = @EstimatedPeriodLookupID,
		EstimatedPeriod = @EstimatedPeriod,
		ModifiedBy = @Author,
		ModifiedOn = @dt
	WHERE
		Id = @templateDurationId
End



' 
END
GO
