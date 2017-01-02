/****** Object:  StoredProcedure [dbo].[prc_CWI_SetFaxServer]    Script Date: 10/17/2014 3:49:28 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetFaxServer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetFaxServer]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetFaxServer]    Script Date: 10/17/2014 3:49:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetFaxServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_CWI_SetFaxServer]
	@CorrespondenceDeliveryId bigint,
	@CorrespondenceId bigint,
	@fax varchar(100)
AS
BEGIN
	SET NOCOUNT ON
	IF EXISTS (SELECT top 1 1 FROM CWI_CorrespondenceDelivery 
				WHERE Id = @CorrespondenceDeliveryId AND IsTrashed = 0 AND DeliveryMethodLookupId=804/*fax*/ AND DeliveryStatusLookupId <> 3152/*Pending*/)
	BEGIN
		UPDATE CWI_CorrespondenceDelivery 
		SET 
			AttemptNo = ISNULL(AttemptNo,0) + 1
		WHERE Id = @CorrespondenceDeliveryId

		RETURN
	END
	Declare @deliverystatus int
	
	--Inserting records into tblFaxServer table.
	if @fax = ''999-999-9999'' OR ltrim(rtrim(@fax)) = ''''
	begin
		insert into dbo.CWI_FaxServer
		(CorrespondenceDeliveryId,FaxStatus,FaxResponse) 
		VALUES (@CorrespondenceDeliveryId ,''Failed'',''Auto Failed due to Invalid Fax Number'')

		SET @deliverystatus = 3153 /*failed*/

	end
	else
	begin
		INSERT INTO CWI_FaxServer
		(CorrespondenceDeliveryId,FaxStatus) 
		VALUES (@CorrespondenceDeliveryId ,''Send'')
		SET @deliverystatus = 3152 /*Pending*/
		
	end
	UPDATE CWI_CorrespondenceDelivery 
	SET DeliveryStatusLookupId = @deliverystatus,
		SentOn = GETDATE(),
		AttemptNo = ISNULL(AttemptNo,0) + 1
	WHERE Id = @CorrespondenceDeliveryId


	SET NOCOUNT OFF
END




' 
END
GO


