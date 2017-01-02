/****** Object:  StoredProcedure [dbo].[prc_RF_SetFaxStatus]    Script Date: 10/17/2014 3:39:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_RF_SetFaxStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_RF_SetFaxStatus]
GO

/****** Object:  StoredProcedure [dbo].[prc_RF_SetFaxStatus]    Script Date: 10/17/2014 3:39:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_RF_SetFaxStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************************
Author: Ajay Thacker
Date: 1Apr2010
Description: This proc would be called from C#.net Console Application RFInterOp
			 It would update the faxstatus after sending fax
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  06OCT14	Mohankumar		New tables are referred   
exec prc_RF_SetFaxStatus

select top 1 * from tblfaxserver
select top 1 * from tblfaximage

select distinct faxstatus from tblfaxserver
*******************************************************************************/

CREATE Procedure [dbo].[prc_RF_SetFaxStatus]
(
@ImageID int,
@FaxStatus varchar(15),
@FaxResponse varchar(255)

)
as
BEGIN
	DECLARE @deliveryStatusLookupId int = 3153/*Failed*/

	BEGIN TRANSACTION
	BEGIN TRY

		if upper(@FaxStatus) = ''COMPLETED''
		Begin
			Update	CWI_FaxServer 
			set FaxStatus = @FaxStatus,
				FaxResponse = @FaxResponse,
				TimeFaxed = getdate()
			where CorrespondenceDeliveryId = @ImageID

			SET  @deliveryStatusLookupId = 3154/*Acknowledged*/

			EXEC prc_APAS_SetCorrespondenceACKStatus @ImageID
		End
		else
		Begin
			Update	CWI_FaxServer 
			set FaxStatus = @FaxStatus,
				FaxResponse = @FaxResponse
			where CorrespondenceDeliveryId = @ImageID

			if upper(@FaxStatus) = ''SENDING'' OR upper(@FaxStatus) = ''PENDING''
			begin
				SET  @deliveryStatusLookupId = 3152/*Pending*/
			end
		End

		UPDATE CWI_CorrespondenceDelivery 
			SET DeliveryStatusLookupId = @deliveryStatusLookupId , ErrorMsg = @FaxResponse
			WHERE Id  = @ImageID

		DECLARE @corresId bigint
		SELECT @corresId = CorrespondenceId FROM CWI_CorrespondenceDelivery WHERE Id  = @ImageID
		EXEC prc_CWI_SetCorrespondenceConsolidatedStatus  @corresId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION ;

END

' 
END
GO


