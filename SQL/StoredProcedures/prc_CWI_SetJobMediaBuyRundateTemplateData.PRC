/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobMediaBuyRundateTemplateData]    Script Date: 5/27/2014 5:59:59 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobMediaBuyRundateTemplateData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobMediaBuyRundateTemplateData]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobMediaBuyRundateTemplateData]    Script Date: 5/27/2014 5:59:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobMediaBuyRundateTemplateData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobMediaBuyRundateTemplateData  
* Purpose : This PROC would be called TO get the rundates template field values for the selected media buy
* Invoked from : JobMediaBuyRundate.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE        AUTHOR          DESCRIPTION             
  6-Dec-2013  Vijesh 
  27-May-2014  Vijesh		Modified for capturing the run date changes in media buy history
**********************************************************************  
Execution example :
**********************************************************************  

**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetJobMediaBuyRundateTemplateData]
	@inMediaBuyId bigint,
	@inUserId int,
	@templatevalues XML
AS
BEGIN

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
			COALESCE(NULLIF(COLX.value(''(./FieldValue)[1]'',''varchar(max)''),''''),NULL) fldval
		from @templatevalues.nodes(''DocumentElement/TemplateData'') AS TABX(COLX)
			
		DECLARE @isCancelled bit=0,
			 @invoiceId bigint = NULL

		DECLARE @tblMBAttr [tt_CWI_MediabuyActionAttribute]
		INSERT  INTO @tblMBAttr SELECT * from [fnc_CWI_GetJobMediaBuyAttributes]( @inMediaBuyId)

		

		declare @message NVARCHAR(2000) = ''''
		select @message = ActionComment FROM @tblMBAttr

		IF ltrim(rtrim(@message)) <> ''''
		begin
			SET @message  = @message;
			THROW 50000,@message , 1; 
		end 
		

	END TRY
	BEGIN CATCH
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH

	 declare @hasOuterTransaction bit = case when @@trancount > 0 then 1 else 0 end;
	 if @hasOuterTransaction = 0
	 begin
		BEGIN TRANSACTION TRAN1
	end

	BEGIN TRY		

		DECLARE @delimiter CHAR(1) = CHAR(225);
		DECLARE @vcUserName varchar(max)
		DECLARE @dtModifiedBy varchar(50)

		SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')

		SET @vcUserName = (SELECT Names FROM CWI_User WHERE Id=@inUserId)
		
		DECLARE @tblMediaBuyRundate TABLE
		(
			comment varchar(max)
		)		
		
		UPDATE [dbo].[CWI_JobMediaBuyRundateTemplateData]
		SET ModifiedBy=@inUserId,ModifiedOn=GETDATE(), FieldValue = t.FieldValue
		--below part added for inserting into action table----
		OUTPUT
			CASE WHEN deleted.FieldValue IS NULL and inserted.FieldValue IS Not Null
					THEN ''Media buy run date modified to ''+ ISNULL(INSERTED.FieldValue,'''') +'' by ''+@vcUserName + '' on ''+@dtModifiedBy +@delimiter
				 WHEN INSERTED.FieldValue<>DELETED.FieldValue 
					THEN ''Media buy run date modified from ''+ISNULL(DELETED.FieldValue,'''')+ '' to '' +ISNULL(INSERTED.FieldValue,'''') +'' by ''+ @vcUserName + '' on ''+ @dtModifiedBy + @delimiter  
				ELSE '''' END 
			INTO @tblMediaBuyRundate -----end-----
		FROM [dbo].[CWI_JobMediaBuyRundateTemplateData] TTD
		INNER JOIN  @tbl t
		ON TTD.TemplateFieldId = t.FieldId AND TTD.[MediaBuyId] = @inMediaBuyId

		---below part added for adding into history------
		DECLARE @updHistory varchar(max),@ActionVal varchar(max);
		SET @updHistory=(SELECT SUBSTRING((SELECT '','' + comment FROM @tblMediaBuyRundate FOR XML PATH('''')), 2,200000))			
		------------end-------------	
		
		INSERT [dbo].[CWI_JobMediaBuyRundateTemplateData]
			( [MediaBuyId], TemplateFieldId, FieldValue, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		OUTPUT CASE WHEN INSERTED.FieldValue IS NOT NULL THEN
				''Media buy run date modified to ''+ ISNULL(INSERTED.FieldValue,'''')+'' by ''+@vcUserName + '' on ''+@dtModifiedBy +@delimiter END
			INTO @tblMediaBuyRundate
		SELECT
			@inMediaBuyId,
			FieldId,
			t.FieldValue,
			@inUserId,
			@dt,@inUserId, @dt
		FROM
		@tbl t
		LEFT OUTER JOIN [dbo].[CWI_JobMediaBuyRundateTemplateData] TTD
		ON TTD.TemplateFieldId = t.FieldId AND TTD.[MediaBuyId] = @inMediaBuyId
		WHERE TTD.Id IS NULL	
		
		---below part added for adding into history------
		DECLARE @insHistory varchar(max)
		SET @insHistory=(SELECT SUBSTRING((SELECT '','' + comment FROM @tblMediaBuyRundate FOR XML PATH('''')), 2,200000))		
		
		DECLARE @tblInsertAction TABLE
		(
			ObjLookupId INt,
			ObjectId INT,
			ActionLookupId INT,
			ActionVal Varchar(max)	   
		)
		INSERT INTO @tblInsertAction SELECT  211,@inMediaBuyId,10019,Items
			FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@insHistory,@delimiter) WHERE LTRIM(RTRIM(ISNULL(items,''''))) <> '''';	
					
		UPDATE @tblInsertAction SET ActionVal= REPLACE( ActionVal,'','','''')---this line added for removing all leading & trailing commas---
		
		INSERT INTO CWI_Action 
			Select TA.ObjLookupId,TA.ObjectId,TA.ActionLookupId,TA.ActionVal,TA.ActionVal,@inUserId,GETDATE() from @tblInsertAction TA where TA.ActionVal <>'''' ;			
		------------end-------------------	
			

	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION TRAN1;
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION TRAN1;
	
		
END








' 
END
GO
