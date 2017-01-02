/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceResubmit]    Script Date: 9/17/2014 7:02:22 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceResubmit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceResubmit]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceResubmit]    Script Date: 9/17/2014 7:02:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceResubmit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/***********************************************************************************************************************  
* PROCEDURE: prc_CWI_SetCorrespondenceResubmit  
* Purpose : This PROC would be called TO insert resubmitted correspondence 
* Invoked from : Correspondence.aspx
* CREATED: MohanKumar 11SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetCorrespondenceResubmit @JobId = NULL,
	@MMRPO  = 12345,
	@CorrespondenceTypeLookupId = 701,
	@Source varchar(50) = ''Clientwise generate insertion order'',
	@Author  = 3
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetCorrespondenceResubmit]
	@CorresDeliveryId bigint,
	@CorrespondenceId bigint,
	@Author int 
AS

	DECLARE @MediaBuyCount INT, @dt DATETIME= getdate(), @authorName varchar(200) = '''', @authorEmail varchar(200) = ''''

	SELECT top 1 @authorName = Names, @authorEmail = Email FROM CWI_User WHERE Id = @Author

	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE CWI_CorrespondenceDelivery SET IsTrashed = 1,   LastModifiedBy = @Author, LastModifiedOn = @dt
		WHERE Id = @CorresDeliveryId

		INSERT CWI_CorrespondenceDelivery
			(
				CorrespondenceId, 
				DeliveryMethodLookupId, 
				DeliveryStatusLookupId, 
				FilePath,
				[File],
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
			
			SELECT DISTINCT 
				CorrespondenceId ,
				DeliveryMethodLookupId,
				3152,/*Pending*/
				FilePath,
				[File],
				Fax,
				@authorEmail,
				@authorName,
				Email,
				CCEmail,
				FTPServer,
				FTPPort,
				FTPUser,
				FTPPassword ,
				@author,
				@author,
				1,
				EmailTemplateId
			FROM CWI_CorrespondenceDelivery
			WHERE
				Id = @CorresDeliveryId
		
		
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


