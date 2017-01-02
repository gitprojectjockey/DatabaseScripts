/****** Object:  StoredProcedure [dbo].[prc_CWI_SetWebDelivery]    Script Date: 6/18/2014 2:48:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetWebDelivery]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetWebDelivery]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetWebDelivery]    Script Date: 6/18/2014 2:48:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetWebDelivery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[prc_CWI_SetWebDelivery]
	@CorrespondenceDeliveryId bigint,
	@CorrespondenceId bigint,
	@SentLink varchar(100),
	@status varchar(2), /*S- Sent, F- Failed */
	@Error varchar(max) = ''''
AS
BEGIN
	SET NOCOUNT ON
	Declare @deliverystatus int
	
	
	if @status= ''F'' OR LEFT(@status,1) = ''F''
	begin
		SET @deliverystatus = 3153 /*failed*/
		
	end
	else
	begin /*else sent */
		SET @deliverystatus = 3151 /*Sent*/
		SET @Error = ''''
	end


	UPDATE CWI_CorrespondenceDelivery 
	SET 
		DeliveryStatusLookupId = @deliverystatus,
		SentLink =  @SentLink,
		SentOn = GETDATE(),
		AttemptNo = ISNULL(AttemptNo,0) + 1,
		ErrorMsg = @Error
	WHERE 
		Id = @CorrespondenceDeliveryId


	SET NOCOUNT OFF
END

' 
END
GO


