/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobMediaBuyCancellation]    Script Date: 5/27/2014 5:59:59 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobMediaBuyCancellation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobMediaBuyCancellation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobMediaBuyCancellation]    Script Date: 5/27/2014 5:59:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobMediaBuyCancellation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobMediaBuyCancellation 
* Purpose : This PROC would be called TO send cancellation notice for the selected media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE           AUTHOR          DESCRIPTION  
  12-Nov-2013    Vijesh      

**********************************************************************  
Execution example :,
**********************************************************************  
exec prc_CWI_SetJobMediaBuyCancellation NULL,1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobMediaBuyCancellation]
@inJobId bigint,
@vcJobMediaBuyIds varchar(MAX),	
@inMediaBuyStatus int,		
@inUserId int,
@inRowCount INT OUTPUT  	
AS
BEGIN
BEGIN TRY
	DECLARE @tblJMB TABLE
	(
		JMBId bigint
	)

	DECLARE @tblAllJMB TABLE
	(
		JMBId bigint,
		MMRPO1 bigint,
		StatusId1 int,
		DNR1 bit,
		isRemoved1 bit,
		VendorId1 int
	)
	DECLARE @tblInvalidJMB TABLE
	(
		DummyId int,
		JMBId bigint,
		MMRPO bigint
	)
	INSERT INTO @tblJMB
	SELECT CAST(Items as bigint) FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcJobMediaBuyIds,'','')

	INSERT INTO @tblAllJMB
	SELECT JMB.Id, JMB.MMRPO, JMB.StatusId, JMB.DNR, JMB.IsRemoved, JMB.VendorId FROM CWI_JobMediaBuy JMB
	INNER JOIN @tblJMB t
		ON JMB.Id = t.JMBId
	

	INSERT INTO @tblInvalidJMB
	SELECT 1, t.JMBId, t.MMRPO1 FROM @tblAllJMB t
	WHERE
	 t.StatusId1 <> 20103 /*generated*/ OR t.DNR1 = 1 OR t.IsRemoved1 = 1 

	 IF EXISTS(SELECT TOP 1 1 FROM @tblInvalidJMB)
	 BEGIN
		DECLARE @error varchar(max) = ''''

		SELECT  @error = t.MMRPO
		FROM
		(SELECT   
			dummyId,
				Stuff((SELECT '','' + CAST(ISNULL(MMRPO,0) AS varchar(max))
							FROM   @tblInvalidJMB t2 
							WHERE  t2.dummyId = t1.dummyId 
							FOR XML PATH('''')), 1, 1, '''') MMRPO 
			FROM   @tblInvalidJMB t1 
			group by dummyId
		) t

		

		--declare @message NVARCHAR(max) = ''Cancellation failed. Media buy''''s '' + @error + '' cannot be cancelled. Please refresh the page and try again'';
		declare @message NVARCHAR(max) = ''Page refreshed as the media buy''''s '' + @error + '' has been updated by another user'';
		THROW 50000,@message , 1;
	 END


	BEGIN TRANSACTION TRAN1
			
	BEGIN TRY	
	
		UPDATE [dbo].[CWI_JobMediaBuy] 
		SET [StatusId]=@inMediaBuyStatus,[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE(),
		[CancelledDate]=GETDATE(),[IsCancelled]=1
		FROM @tblJMB t
		WHERE t.JMBId =  ID 
		
		IF(SELECT COUNT(*) FROM [dbo].[CWI_JobMediaBuy] WHERE StatusId<>@inMediaBuyStatus AND JobId=@inJobId)=0
		BEGIN
			UPDATE [dbo].[CWI_Job] SET [IsCancelled]=1,[CancelledDateTime]=GETDATE(),[JobStatusLookupId]=8006,--8006 is for cancel
			[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
			WHERE ID=@inJobId
		END
		ELSE
		BEGIN
			UPDATE [dbo].[CWI_Job] SET [IsSelectiveCancel]=1,[ModifiedBy]=@inUserId,
			[ModifiedOn]=GETDATE()
			WHERE ID=@inJobId			
		END

		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
		
		------INSERT INTO CORRESPONDENCE TABLE-----------
		DECLARE @vcMMRPO VARCHAR(MAX)
		SET @vcMMRPO= (SELECT STUFF((SELECT '','' + CONVERT(VARCHAR,MMRPO1 )
            FROM @tblAllJMB 
			
            FOR XML PATH('''')) ,1,1,'''') AS MMRPO)

		WHILE LEN(@vcMMRPO) > 0
		BEGIN	
			DECLARE @inMMRPO BIGINT
			SET @inMMRPO = (SELECT LEFT (@vcMMRPO,CHARINDEX('','',@vcMMRPO+'','')-1))
			EXECUTE prc_CWI_SetCorrespondence 	
					@JobId = @inJobId,
					@MMRPO = @inMMRPO,
					@CorrespondenceTypeLookupId = 704,
					@Source  = ''Clientwise Internal'',
					@Author = @inUserId	
		
			SET @vcMMRPO = STUFF(@vcMMRPO,1,CHARINDEX('','', @vcMMRPO+'',''),'''')			
		END
		-------------------END--------------------								
						
		--Inserting into Action table to track History
		DECLARE @InsertAction varchar(8000)
		DECLARE @InsertActionLink varchar(8000)
		DECLARE @AuthorName varchar(1000)
		DECLARE @dtModifiedBy varchar(50)

		SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
		SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

		DECLARE @VendorName varchar(8000)
		DECLARE @TBL_VENDOR TABLE (VENDORNAME VARCHAR(8000))

		INSERT INTO @TBL_VENDOR
		SELECT VendorName FROM CWI_Vendor  V
		INNER JOIN  @tblAllJMB t
			ON t.VendorId1 = V.Id

		WHILE (SELECT COUNT(*) FROM @TBL_VENDOR ) > 0
		BEGIN	
			
			SET @VendorName = (SELECT TOP 1 VENDORNAME FROM @TBL_VENDOR)
			SET @InsertAction = @VendorName + '' Media Buy cancelled by '' + @AuthorName + '' on '' + @dtModifiedBy
			SET @InsertActionLink=''Media Buy cancelled for job '' + Convert(varchar,@inJobId) + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@inJobId) + ''></a>'' + '' by '' + @AuthorName + '' on '' + @dtModifiedBy
		
			EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
			@ActionLookupId = 10013,
			@Action = @InsertAction,
			@ActionWithLink = @InsertActionLink,
			@CreatedBy = @inUserId
			DELETE FROM @TBL_VENDOR WHERE VENDORNAME=@VendorName
		END
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION TRAN1;
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION TRAN1;
END TRY
	BEGIN CATCH	 		
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END








' 
END
GO
