/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceDeliveryResubmit]    Script Date: 4/29/2014 12:15:30 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceDeliveryResubmit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceDeliveryResubmit]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceDeliveryResubmit]    Script Date: 4/29/2014 12:15:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceDeliveryResubmit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/***********************************************************************************************************************  
* PROCEDURE: [[prc_CWI_SetCorrespondenceDeliveryResubmit]]  
* Purpose : This PROC would be called TO resubmit the correspondence
* Invoked from : ManagSettlements.aspx
* CREATED: Mohankumar Sundaram   10APR14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetCorrespondenceDeliveryResubmit] @JobMediaBuyId = 1,
	@CorrespondenceTypeLookupId = 701,
	@Source varchar(50) = ''Clientwise generate insertion order'',
	@Author  = 3
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetCorrespondenceDeliveryResubmit]
	@JobMediaBuyId bigint,
	@CorrespondenceTypeLookupId int,
	@source varchar(100) = ''Clientwise Application'',
	@Author int 
AS

	DECLARE @CorresDeliveryId BIGINT =NULL,
			@CorresId BIGINT =NULL,
			@FilePath varchar(500)=NULL,
			@File varchar(100)=NULL,
			@SentLink varchar(500)=NULL

	SELECT @CorresId = Id FROM CWI_Correspondence 
	where JobMediaBuyId =@JobMediaBuyId AND CorrespondenceTypeLookupId = @CorrespondenceTypeLookupId
	SELECT @FilePath=FilePath,@File=[File], @SentLink=SentLink FROM CWI_CorrespondenceDelivery WHERE CorrespondenceId=@CorresId
	
	IF @CorresId IS NULL
	begin
		declare @message NVARCHAR(2000) = ''Previous correspondence delivery details exist'';
		THROW 50000,@message , 1; 
	end

	DECLARE 	
		@StatusLookupId int = 3102/*Pending*/, 
		@dt datetime = getdate()
	BEGIN TRANSACTION
	BEGIN TRY
		
		DECLARE @tblCorresDelivery TABLE
		(
			CD_Id bigint
		)

		INSERT INTO @tblCorresDelivery
		SELECT Id
		FROM CWI_CorrespondenceDelivery
		WHERE CorrespondenceId=@CorresId AND IsTrashed = 0

		--Update the exisitng records as thrash
		UPDATE CWI_CorrespondenceDelivery SET IsTrashed=1, LastModifiedBy =@Author, LastModifiedOn = @dt
		FROM CWI_CorrespondenceDelivery CD
		INNER JOIN @tblCorresDelivery t
			ON t.CD_Id = CD.Id

		--Insert the new records for delivery methods from existing
		INSERT CWI_CorrespondenceDelivery
		(
		CorrespondenceId, 
		DeliveryMethodLookupId, 
		DeliveryStatusLookupId, 
		FilePath,
		[File],
		SentLink,
		Fax,
		FromEmailAddress,
		FromEmailUserName,
		Email, 
		CCEmail,
		FTPServer,
		FTPPort,
		FTPUser,
		FTPPassword,
		CreatedBy,
		LastModifiedBy,
		IsResubmit
		)
		SELECT  
			@CorresId ,
			DeliveryMethodLookupId,
			3152,/*Pending*/
			@FilePath,
			@File,
			@SentLink,
			Fax,
			FromEmailAddress,
			FromEmailUserName,
			Email,
			CCEmail,
			FTPServer,
			FTPPort,
			FTPUser,
			FTPPassword,
			@author,
			@author,
			1
		FROM CWI_CorrespondenceDelivery CD
		INNER JOIN @tblCorresDelivery t
			ON t.CD_Id = CD.Id

		UPDATE CWI_Correspondence SET IsResubmit=1, LastModifiedBy =@Author, LastModifiedOn = @dt
		WHERE Id=@CorresId;

	END TRY
		
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;
		

		




' 
END
GO


