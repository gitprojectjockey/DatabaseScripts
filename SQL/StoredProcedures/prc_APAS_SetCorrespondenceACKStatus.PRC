/****** Object:  StoredProcedure [dbo].[prc_APAS_SetCorrespondenceACKStatus]    Script Date: 10/17/2014 3:43:56 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_SetCorrespondenceACKStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_SetCorrespondenceACKStatus]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_SetCorrespondenceACKStatus]    Script Date: 10/17/2014 3:43:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_SetCorrespondenceACKStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_APAS_SetCorrespondenceACKStatus  
* Purpose : This PROC would be called TO update the correspondence delivery as Acknowledged
* Invoked from : PaperCostWizard.aspx, cancellation.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_APAS_SetCorrespondenceACKStatus 12
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_APAS_SetCorrespondenceACKStatus]
 @CorresDeliveryId bigint
AS
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @CorresId bigint, @DeliveryStatusLookupId int = NULL

	SELECT @CorresId = CorrespondenceId, @DeliveryStatusLookupId = DeliveryStatusLookupId  
	FROM CWI_CorrespondenceDelivery WHERE Id = @CorresDeliveryId

	IF @DeliveryStatusLookupId <> 3154 /*3154 - Acknowledged - If already acknowledged, do not update the status- */
	BEGIN
		/* Updating all delivery methods of correspondence type as trashed*/
		UPDATE CWI_CorrespondenceDelivery SET IsTrashed = 1
		WHERE CorrespondenceId = @CorresId 

		/* Updating individual correspondence delivery status as acked and removed trashed */
		UPDATE CWI_CorrespondenceDelivery SET DeliveryStatusLookupId = 3154 /* Acknowledged */, AckOn = getdate(), IsTrashed = 0
		WHERE Id = @CorresDeliveryId 

		/* Updating correspondence status */
		EXEC prc_CWI_SetCorrespondenceConsolidatedStatus @CorresId
	END
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


