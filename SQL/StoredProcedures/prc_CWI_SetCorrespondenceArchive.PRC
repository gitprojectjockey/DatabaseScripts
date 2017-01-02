/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceArchive]    Script Date: 9/17/2014 7:05:02 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceArchive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceArchive]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceArchive]    Script Date: 9/17/2014 7:05:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceArchive]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetCorrespondenceArchive 
* Purpose : This PROC would be called TO set the correspondence delivery as archive
* Invoked from : Correspondence.aspx
* CREATED: MohanKumar Sundaram	17SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  


**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetCorrespondenceArchive 1, 3 
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetCorrespondenceArchive]
	@corresDeliveryId bigint,
	@author int,
	@comment varchar(max)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Email varchar(200), @authorName varchar(200), @MediaBuyId bigint, @corresType varchar(100), @delivery varchar(100)
	SELECT TOP 1 @Email = Email, @authorName = Names FROM CWI_User WHERE Id = @author

	SELECT 
		@MediaBuyId=  C.JobMediaBuyId ,
		@corresType = LC.LookupName,
		@delivery = LM.LookupName
	FROM CWI_Correspondence C
	INNER JOIN CWI_CorrespondenceDelivery CD
		ON C.Id = CD.CorrespondenceId
	INNER JOIN Lookup LC
		ON LC.Id  = C.CorrespondenceTypeLookupId
	INNER JOIN Lookup LM
		ON LM.Id  = CD.DeliveryMethodLookupId
	WHERE
		CD.Id = @corresDeliveryId

	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE CWI_CorrespondenceDelivery SET IsTrashed = 1, LastModifiedOn= getdate(), LastModifiedBy = @author
		WHERE Id = @corresDeliveryId

		SET @comment = @corresType + '' delivered through '' + @delivery + '' is archived  with the comments: '' + @comment

		EXEC prc_CWI_SetComment @inUserId = @author,
			@inObjectLookupId = 211, /*MediaBuy*/
			@inObjectId= @MediaBuyId,
			@inCommentId = NULL,
			@vcComment= @comment,
			@inRowCount = NULL,
			@vcUserName = @authorName,
			@vcUserEmail = @Email
	
	END TRY
		
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION ;
		
	SET NOCOUNT OFF
END' 
END
GO


