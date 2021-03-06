/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceEmailAttachment]    Script Date: 9/17/2014 7:03:13 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceEmailAttachment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceEmailAttachment]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceEmailAttachment]    Script Date: 9/17/2014 7:03:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceEmailAttachment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*********************************************************************************
* PROCEDURE: [prc_CWI_SetCorrespondenceEmailAttachment]
* Purpose : This PROC would be called TO Insert Correspondence Email attachements 
* Invoked from : Task.aspx
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              
**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetCorrespondenceEmailAttachment 8351, 
	3,
	''<DocumentElement><CorrespondenceDeliveryEmails><Id>0</Id><Name>\\dcvwin2k12d02\FileServerDev\CorrespondenceAttachment\deliverytab_091620140644330.png</Name></CorrespondenceDeliveryEmails><CorrespondenceDeliveryEmails><Id>0</Id><Name>\\dcvwin2k12d02\FileServerDev\CorrespondenceAttachment\ftr_xeroxlogo_091620140644401.png</Name></CorrespondenceDeliveryEmails></DocumentElement>'',
	''\\dcvwin2k12d02\FileServerDev''
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetCorrespondenceEmailAttachment]
    @CorresDeliveryId bigint,
	@Author int,
	@Attachments XML,
	@AttachmentFilePath varchar(500)
	
AS
 declare @hasOuterTransaction bit = case when @@trancount > 0 then 1 else 0 end;
 if @hasOuterTransaction = 0
 begin
	BEGIN TRANSACTION 
end
BEGIN TRY
	-- temporary table to store the data from XML
	DECLARE @tbl TABLE
	(
		Id1 int  NULL,
		FileName1 varchar(max)
		
	)

	--Read the data from XML and store in the table variable
		INSERT INTO @tbl
		(
			Id1,
			FileName1
			
		)
		SELECT
			Id,
			FileNames
			
		FROM
		(
		SELECT 
			COLX.value(''(./Id)[1]'',''int'') Id,
			COLX.value(''(./Name)[1]'',''varchar(max)'') FileNames
		FROM @Attachments.nodes(''DocumentElement/CorrespondenceDeliveryEmails'') AS TABX(COLX)
		) x	
			
		INSERT CWI_CorrespondenceEmailAttachment
		(CorrespondenceDeliveryId, FileName, FilePath,CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT
			@CorresDeliveryId,
			FileName1,
			@AttachmentFilePath,
			@Author,
			getdate(),@Author, getdate()
		FROM
		@tbl t
 
		
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
		




' 
END
GO


