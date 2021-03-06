/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobDNR]    Script Date: 5/27/2014 5:59:59 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobDNR]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobDNR]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobDNR]    Script Date: 5/27/2014 5:59:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobDNR]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobDNR 
* Purpose : This PROC would be called TO set the DNR for the selected media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  04MAY14	Mohankumar		Validation and  Transaction added
							

**********************************************************************  
Execution example :,
**********************************************************************  
declare @inrows int
exec prc_CWI_SetJobDNR ''1,2'',1,3, inrows out
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobDNR]	
	@vcJobMediaBuyIds varchar(max),	
	@inJobId bigint,
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @TBL_VENDOR TABLE 
		(MBId bigint, VId int, VENDORNAME VARCHAR(8000), Status int, cancelled bit, removed bit,IsDNR bit)

		INSERT INTO @TBL_VENDOR
		/*SELECT JMB.Id, V.Id, V.VendorName, JMB.StatusId, JMB.IsCancelled, JMB.IsRemoved FROM CWI_Vendor V 
		INNER JOIN (SELECT CAST( Items as bigint) Id FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcJobMediaBuyIds,'','')) t
		ON t.Id = V.Id
		INNER JOIN CWI_JobMediaBuy JMB
			ON JMB.VendorId = V.Id*/
		SELECT JMB.Id, V.Id, V.VendorName, JMB.StatusId, JMB.IsCancelled, JMB.IsRemoved,JMB.DNR FROM CWI_Vendor V 
		INNER JOIN CWI_JobMediaBuy JMB ON JMB.VendorId = V.Id
		INNER JOIN (SELECT CAST( Items as bigint) Id FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcJobMediaBuyIds,'','')) t
		ON t.Id =JMB.Id
		--SELECT * FROM @TBL_VENDOR
		begin try	
			IF EXISTS (SELECT top 1 1 FROM @TBL_VENDOR WHERE IsDNR=1 OR removed = 1 OR cancelled = 1 OR [Status] <> 20103 /* Generated */)
			Begin
				declare @message NVARCHAR(2000) = ''Page refreshed as the media buy has been updated by another user''; 
				THROW 50000,@message , 1; 
			End
		end try
		begin catch
			throw;
		end catch

		BEGIN TRANSACTION TRAN1
		BEGIN TRY	
			SELECT * FROM @TBL_VENDOR
			UPDATE [dbo].[CWI_JobMediaBuy] SET [DNR]=1,[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
			FROM @TBL_VENDOR t
			WHERE t.MBId = Id
			AND (StatusId = 20103) AND IsCancelled = 0  AND IsRemoved = 0

			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)

			--Inserting into Action table to track History
			DECLARE @InsertAction varchar(8000)
			DECLARE @AuthorName varchar(1000)
			DECLARE @dtModifiedBy varchar(50)
			DECLARE @InsertActionLink varchar(8000)

			SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
			SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId
			DECLARe @VendorName varchar(8000)

			WHILE (SELECT COUNT(*) FROM @TBL_VENDOR ) > 0
			BEGIN
				SET @VendorName = (SELECT TOP 1 VENDORNAME FROM @TBL_VENDOR)

				SET @InsertAction = @VendorName + '' DNR status modified by '' + @AuthorName + '' on '' + @dtModifiedBy
				SET @InsertActionLink=''DNR status for job '' + Convert(varchar(max),@inJobId) + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@inJobId) + ''></a>'' + '' modified by '' + @AuthorName + '' on '' + @dtModifiedBy

				EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
					@ActionLookupId = 10012,
					@Action = @InsertAction,
					@ActionWithLink = @InsertActionLink,
					@CreatedBy = @inUserId	

				------------for media buy history---------
				EXEC prc_CWI_SetAction @ObjectLookupId = 211, @ObjectId = @inJobId,
					@ActionLookupId = 10012,
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
		
		SET NOCOUNT OFF
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END


		


' 
END
GO
