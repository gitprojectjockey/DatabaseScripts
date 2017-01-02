/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceConsolidatedStatus]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceConsolidatedStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceConsolidatedStatus]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceConsolidatedStatus]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceConsolidatedStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetCorrespondenceConsolidatedStatus
* Purpose : This PROC would be called TO set correspondence status based on its delivery methods status
* Invoked from : CorrespondenceService
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetCorrespondenceConsolidatedStatus @correspondenceid= 1
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetCorrespondenceConsolidatedStatus]
	@correspondenceid bigint
AS
	DECLARE @tbl TABLE
	(
		MethodId int,
		StatusId int,
		ErrMsg varchar(max),
		Attempt int
	)

	DECLARE @CorrespondenceTypeLookupId int, @mediaBuyId bigint

	INSERT INTO @tbl
	SELECT DeliveryMethodLookupId, DeliveryStatusLookupId, Exception, AttemptNo
	FROM CWI_CorrespondenceDelivery
	WHERE CorrespondenceId =@correspondenceid AND IsTrashed=0

	SELECT @mediaBuyId = JobMediaBuyId, @CorrespondenceTypeLookupId = CorrespondenceTypeLookupId FROM CWI_Correspondence WHERE Id = @correspondenceid AND IsTrashed = 0

	DECLARE @statuslookupid int = NULL, @rowcnt int = 0
	DECLARE @error varchar(max) = NULL
	SELECT @rowcnt = count(*) FROM @tbl
	IF @rowcnt=0
	BEGIN
		SET @statuslookupid = 3101	/*	Pending*/
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT top 1 1 FROM @tbl WHERE StatusId = 3154 /*Acknowledged*/)
		BEGIN
			SET @statuslookupid = 3105	/*	Acknowledged*/
		END
		ELSE IF EXISTS (SELECT top 1 1 FROM @tbl WHERE StatusId = 3151 /*Sent*/)
		BEGIN
			SET @statuslookupid = 3103	/*	Sent*/
		END
		ELSE 
		BEGIN
			declare  @errcnt int = 0
			SELECT  @errcnt = count(*) FROM @tbl WHERE StatusId = 3153/*Error*/
			IF @rowcnt = @errcnt
			begin
				SELECT @error = t.ErrMsg
				FROM
				(SELECT   
					StatusId,
						Stuff((SELECT '''','''' + CAST(ISNULL(ErrMsg ,0) AS varchar(max))
									FROM   @tbl t2 
									WHERE  t2.StatusId = t1.StatusId 
									FOR XML PATH('''')), 1, 1, '''') ErrMsg 
					FROM   @tbl t1 
				   group by StatusId
				) t

				SET @statuslookupid = 3104	/*	Error*/
			end 
		END
	END

	DECLARE @maxAttempt int = 0

	SELECT @maxAttempt = ISNULL(MAX(Attempt),0) FROM @tbl

	IF @statuslookupid IS NOT NULL
	BEGIN
		IF @error IS NULL
		begin
			UPDATE CWI_Correspondence SET StatusLookupId = @statuslookupid, AttemptNo = @maxAttempt
			WHERE Id = @correspondenceid
		end
		ELSE
		begin
			UPDATE CWI_Correspondence SET StatusLookupId = @statuslookupid, ErrorMsg = @error, AttemptNo = @maxAttempt
			WHERE Id = @correspondenceid
		end
		IF @CorrespondenceTypeLookupId IN (701, 709) /* Insertion Order, Change Order */
		BEGIN
			If @StatusLookupId = 3103 /*Sent */
			BEGIN
				UPDATE  CWI_JobMediaBuy 
				SET InsertionStatusLookupId = @StatusLookupId , InsertionDeliveredOn = GETDATE()
				WHERE Id = @mediaBuyId 
			END
			ELSE
			BEGIN
				UPDATE  CWI_JobMediaBuy 
				SET InsertionStatusLookupId = @StatusLookupId 
				WHERE Id = @mediaBuyId 
			END

		END

	END


' 
END
GO
