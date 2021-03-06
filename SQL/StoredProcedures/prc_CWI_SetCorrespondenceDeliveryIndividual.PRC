/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceDeliveryIndividual]    Script Date: 9/17/2014 7:12:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceDeliveryIndividual]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceDeliveryIndividual]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceDeliveryIndividual]    Script Date: 9/17/2014 7:12:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceDeliveryIndividual]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/***********************************************************************************************************************  
* PROCEDURE: [prc_CWI_SetCorrespondenceDeliveryIndividual]  
* Purpose : This PROC would be called TO insert Email correspondence into DB
* Invoked from : Correspondence.aspx
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetEmailCorrespondence @JobId = NULL,
	@MMRPO  = 12345,
	@CorrespondenceTypeLookupId = 701,
	@Source varchar(50) = ''Clientwise generate insertion order'',
	@Author  = 3
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetCorrespondenceDeliveryIndividual]
	@CorresId bigint,
	@DeliveryMethodLookupId int,
	@Source varchar(50) = NULL,
	@Fax varchar(50) = NULL,
	@FromEmailAddress varchar(100)=null,
	@FromEmailUserName varchar(100)=null,
	@Email varchar(500)=null,
	@CCEmail	varchar	(	500) = NULL,
	@FTPServer	varchar(200)	= NULL,
	@FTPPort	int	,
	@FTPUser	varchar	(	200),
	@FTPPassword	varchar	(	200),
	@Attachments XML=null,
	@AttachFilePath varchar(500)=null,
	@Author int 
AS

	DECLARE @JobMediaBuyId BIGINT, @CorrespondenceTypeLookupId INT, 
			@IsTrashed bit, @File varchar(200) = NULL, @EmailTemplateId int  = NULL,
			@authorName varchar(200) = '''', @authorEmail varchar(200) = ''''

	SELECT top 1 @authorName = Names, @authorEmail = Email FROM CWI_User WHERE Id = @Author

	DECLARE @CorresDeliveryId BIGINT

	SELECT @JobMediabuyid=JobMediaBuyId , @CorrespondenceTypeLookupId=CorrespondenceTypeLookupId, 
			@IsTrashed=IsTrashed, @File = [File]
	FROM CWI_Correspondence
	WHERE Id = @CorresId

	
	select top 1 @EmailTemplateId = EmailTemplateId 
	from CWI_CorrespodenceDeliveryEmailTemplate  DE
	INNER JOIN CWI_EmailTemplate ET
		ON DE.EmailTemplateId = ET.Id
	WHERE
		CorrespodenceLookupId = @CorrespondenceTypeLookupId
		AND DE.IsActive = 1 AND ET.IsActive = 1
		AND  DE.DeliveryMethodLookupId = @DeliveryMethodLookupId

	-- select * from lookup where LookupTypeId = 44
	IF @IsTrashed = 1 
	BEGIN
		--ERRIR RETURN
		print 1
	END
	
	DECLARE 	
		@VendorId int = NULL,
		@ClientId int = NULL,
		@InvoiceDate datetime = NULL,
		@StatusLookupId int = 3101/*Pending*/,
		@dt datetime = getdate(),
		@MediaBuyId bigint,
		@CorresDelId bigint
	BEGIN TRANSACTION
	BEGIN TRY
		--IF @File IS NULL
		--BEGIN
		--	SELECT * FROM CWI_Correspondence
		--	WHERE Id = @CorresId
		--END
		--ELSE
		

		UPDATE CWI_CorrespondenceDelivery SET IsTrashed = 1,   LastModifiedBy = @Author, LastModifiedOn = @dt
		WHERE CorrespondenceId = @CorresId AND DeliveryMethodLookupId = @DeliveryMethodLookupId

		INSERT CWI_CorrespondenceDelivery
			(
				CorrespondenceId, 
				DeliveryMethodLookupId, 
				DeliveryStatusLookupId, 
				Fax,
				FromEmailAddress,
				FromEmailUserName,
				Email,
				CCEmail,
				FTPServer,
				FTPPort,
				FTPUser,
				FTPPassword ,
				CreatedBy,
				LastModifiedBy,
				IsResubmit,
				EmailTemplateId
			)
			
			SELECT  
				@CorresId ,
				@DeliveryMethodLookupId,
				3152,/*Pending*/
				@Fax,
				ISNULL(@FromEmailAddress,@authorEmail),
				ISNULL(@FromEmailUserName,@authorName),
				@Email,
				@CCEmail,
				@FTPServer,
				@FTPPort,
				@FTPUser,
				@FTPPassword ,
				@author,
				@author,
				1,
				@EmailTemplateId

		SET @CorresDeliveryId = SCOPE_IDENTITY()

		--Insert into Correspondence Email Attachments table if attachment is available
		IF @Attachments IS NOT NULL 
			EXEC prc_CWI_SetCorrespondenceEmailAttachment  @CorresDeliveryId,@author,@Attachments,@AttachFilePath
	END TRY
		
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION ;
		

		





' 
END
GO


