/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondence]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondence]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondence]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetCorrespondence  
* Purpose : This PROC would be called TO insert correspondence into DB
* Invoked from : Multiple pages to insert data for correspondence process service
* CREATED: MohanKumar Sundaram	1/16/2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  02JUN14	Mohankumar		Camera Ready Ad Copy(Final Ad copy) added
  16JUN14	Mohankumar		IsReadyToProcess implemented based in correspondence type and payment method

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetCorrespondence @JobId = NULL,
	@MMRPO  = 12345,
	@CorrespondenceTypeLookupId = 701,
	@Source  = ''Clientwise generate insertion order'',
	@Author  = 3
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetCorrespondence]
	@JobId bigint= NULL,
	@MMRPO bigint = NULL,
	@CorrespondenceTypeLookupId int,
	@Source varchar(50) = NULL,
	@Author int
AS

BEGIN
	
	DECLARE 	
		@VendorId int = NULL,
		@ClientId int = NULL,
		@InvoiceDate datetime = NULL,
		@StatusLookupId int = 3101/*Pending*/,
		@dt datetime = getdate(),
		@CorresId bigint,
		@MediaBuyId bigint

	
	IF  @MMRPO IS NOT NULL
	BEGIN
		SELECT 
			@JobId = JMB.JobId ,
			@VendorId = JMB.VendorId,
			@MediaBuyId = JMB.Id
		FROM CWI_JobMediaBuy JMB
		WHERE JMB.MMRPO = @MMRPO
	END
	
	DECLARE @tblCorresExisting TABLE
	(
		CorresId bigint,
		MBId bigint
	)

	IF @MMRPO IS NULL AND 
		@CorrespondenceTypeLookupId in ( 701,703,704, 709, 708) --insertion order/Quote/Full Cancellation/Change Order/Camera Ready Ad Copy (Final Ad copy )
	BEGIN
		IF @CorrespondenceTypeLookupId = 701 /* insertion order -  update insertion delivery status*/
		BEGIN
			UPDATE  CWI_JobMediaBuy SET InsertionStatusLookupId = @StatusLookupId 
			WHERE JobId = @JobId
			AND StatusId = 20102 /* Selected */ AND IsRemoved = 0 AND IsCancelled = 0 AND DNR = 0

		END

		UPDATE CWI_Correspondence
		SET IsTrashed = 1, LastModifiedBy = @Author, LastModifiedOn = @dt
 			OUTPUT 
				inserted.Id,
				inserted.JobMediaBuyId
			INTO @tblCorresExisting
		WHERE JobId = @JobId
		AND CorrespondenceTypeLookupId = @CorrespondenceTypeLookupId
		AND IsTrashed= 0 

		UPDATE CWI_CorrespondenceDelivery
		SET IsTrashed = 1, LastModifiedBy = @Author, LastModifiedOn = @dt
		FROM @tblCorresExisting t 
		WHERE  t.CorresId = CorrespondenceId AND
		@CorresId = @JobId
		AND IsTrashed= 0 

		IF @CorrespondenceTypeLookupId = 704 /* Full cancellation */
		Begin
			INSERT CWI_Correspondence
			(
				JobId, JobMediaBuyId, MMRPO, CorrespondenceTypeLookupId, VendorId, ClientId, InvoiceDate, StatusLookupId, 
				Source, CreatedBy, CreatedOn, LastModifiedOn, LastModifiedBy, IsResubmit,IsReadyToProcess
			)
			SELECT
				JMB.JobId,
				JMB.Id,
				JMB.MMRPO,
				@CorrespondenceTypeLookupId,
				JMB.VendorId,
				J.DivisionId,
				J.InvoiceDate,
				@StatusLookupId, 
				@Source, @Author, @dt, @dt, @Author,
				CASE WHEN CE.MBId IS NULL THEN 0 ELSE 1 END,
				dbo.fnc_CWI_IsCorrespondenceReadyToCreate(@CorrespondenceTypeLookupId, JMB.PayMethodLookupId)
			FROM
				CWI_JobMediaBuy JMB
				INNER JOIN  CWI_Job J
					ON J.Id  = JMB.JobId
					AND J.ID = @JobId
					AND JMB.IsCancelled = 1
					AND JMB.IsRemoved = 0
					AND JMB.DNR = 0
				LEFT OUTER JOIN @tblCorresExisting CE
					ON CE.MBId = JMB.Id
		End
		ELSE IF @CorrespondenceTypeLookupId = 708 /* Cameara Ready Ad   */
		Begin
			INSERT CWI_Correspondence
			(
				JobId, JobMediaBuyId, MMRPO, CorrespondenceTypeLookupId, VendorId, ClientId, InvoiceDate, StatusLookupId, 
				Source, CreatedBy, CreatedOn, LastModifiedOn, LastModifiedBy, IsResubmit,FilePath,
				[File],
				IsReadyToProcess
			)
			SELECT
				JMB.JobId,
				JMB.Id,
				JMB.MMRPO,
				@CorrespondenceTypeLookupId,
				JMB.VendorId,
				J.DivisionId,
				J.InvoiceDate,
				@StatusLookupId, 
				@Source, @Author, @dt, @dt, @Author,
				CASE WHEN CE.MBId IS NULL THEN 0 ELSE 1 END,
				FinalAdCopyPath,
				FinalAdCopyFileName,
				dbo.fnc_CWI_IsCorrespondenceReadyToCreate(@CorrespondenceTypeLookupId, JMB.PayMethodLookupId)
			FROM
				CWI_JobMediaBuy JMB
				INNER JOIN  CWI_Job J
					ON J.Id  = JMB.JobId
					AND J.ID = @JobId
					AND JMB.IsCancelled =0
					AND JMB.IsRemoved = 0
					AND JMB.DNR = 0
				LEFT OUTER JOIN @tblCorresExisting CE
					ON CE.MBId = JMB.Id
		End
		ELSE
		Begin
			INSERT CWI_Correspondence
			(
				JobId, JobMediaBuyId, MMRPO, CorrespondenceTypeLookupId, VendorId, ClientId, InvoiceDate, StatusLookupId, 
				Source, CreatedBy, CreatedOn, LastModifiedOn, LastModifiedBy, IsResubmit,IsReadyToProcess
			)
			SELECT
				JMB.JobId,
				JMB.Id,
				JMB.MMRPO,
				@CorrespondenceTypeLookupId,
				JMB.VendorId,
				J.DivisionId,
				J.InvoiceDate,
				@StatusLookupId, 
				@Source, @Author, @dt, @dt, @Author,
				CASE WHEN CE.MBId IS NULL THEN 0 ELSE 1 END,
				dbo.fnc_CWI_IsCorrespondenceReadyToCreate(@CorrespondenceTypeLookupId, JMB.PayMethodLookupId)
			FROM
				CWI_JobMediaBuy JMB
				INNER JOIN  CWI_Job J
					ON J.Id  = JMB.JobId
					AND J.ID = @JobId
					AND JMB.IsCancelled =0
					AND JMB.IsRemoved = 0
					AND JMB.DNR = 0
				LEFT OUTER JOIN @tblCorresExisting CE
					ON CE.MBId = JMB.Id
		End
		RETURN
	END

	SELECT 
		@ClientId = DivisionId,
		@InvoiceDate = InvoiceDate
	FROM
		CWI_Job J
	WHERE
		Id = @JobId

	UPDATE CWI_Correspondence
		SET IsTrashed = 1, LastModifiedBy = @Author, LastModifiedOn = @dt
 			OUTPUT 
				inserted.Id,
				inserted.JobMediaBuyId
			INTO @tblCorresExisting
	WHERE JobMediaBuyId = @MediaBuyId
	AND CorrespondenceTypeLookupId = @CorrespondenceTypeLookupId
	AND IsTrashed= 0 

	UPDATE CWI_CorrespondenceDelivery
	SET IsTrashed = 1, LastModifiedBy = @Author, LastModifiedOn = @dt
	FROM @tblCorresExisting t 
	WHERE  t.CorresId = CorrespondenceId AND
	@CorresId = @JobId
	AND IsTrashed= 0 


	DECLARE @isresubmit bit = 0, @PayMethodLookupId int
	IF EXISTS (SELECT top 1 1 FROM @tblCorresExisting)
	BEGIN
		SET @isresubmit = 1
	END

	SELECT @PayMethodLookupId = PayMethodLookupId FROM CWI_JobMediaBuy WHERE Id = @MediaBuyId

	INSERT CWI_Correspondence
	(
		JobId,JobMediaBuyId, MMRPO, CorrespondenceTypeLookupId, VendorId, ClientId, InvoiceDate, StatusLookupId, 
		Source, CreatedBy, CreatedOn, LastModifiedOn, LastModifiedBy, IsResubmit,IsReadyToProcess
	)
	VALUES 
	(
		@JobId, @MediaBuyId,@MMRPO, @CorrespondenceTypeLookupId, @VendorId, @ClientId, @InvoiceDate, @StatusLookupId, 
		@Source, @Author, @dt, @dt, @Author, @isresubmit,
		dbo.fnc_CWI_IsCorrespondenceReadyToCreate(@CorrespondenceTypeLookupId, @PayMethodLookupId)
	)

	SET @CorresId  =  SCOPE_IDENTITY()

END


' 
END
GO
