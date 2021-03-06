/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobRemoveMediaBuy]    Script Date: 7/18/2014 8:12:30 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobRemoveMediaBuy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobRemoveMediaBuy]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobRemoveMediaBuy]    Script Date: 7/18/2014 8:12:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobRemoveMediaBuy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobRemoveMediaBuy 
* Purpose : This PROC would be called TO remove the selected media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  28/5/2014  Vijesh		Modified for removing run dates         
  18/7/2014  Vijesh     Modified for commented prc_CWI_SetBudgetFromMediaBuy as it is fired on trigger
**********************************************************************  
Execution example :,
**********************************************************************  
declare @vcMessage varchar(max) 
exec prc_CWI_SetJobRemoveMediaBuy ''3014'',1436,7,@vcMessage 
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobRemoveMediaBuy]	
	@vcJobMediaBuyIds varchar(max),
	@inJobId bigint,
	@inUserId int,
	--@inRowCount int OUTPUT ,
	@vcMessage varchar(max) OUTPUT   
AS
BEGIN
	BEGIN TRY	

		DECLARE @inStatusID INT

		SET @vcMessage = ''''

		SET @inStatusID = (SELECT DISTINCT StatusId FROM CWI_JobMediaBuy WHERE JobId=@inJobId AND IsRemoved=0)
		
		IF @inStatusID = 20103
		BEGIN
			SET @vcMessage = ''Page refreshed as the media buy status has been changed''
		END
		ELSE
		BEGIN

			IF EXISTS (SELECT ID FROM [dbo].[CWI_JobMediaBuy]
				WHERE ID IN (SELECT Items FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcJobMediaBuyIds,'','')) AND IsRemoved=1)
			BEGIN
				SET @vcMessage = ''Page refreshed as the selected media buy has been already removed by another user''
			END
			ELSE
			BEGIN
				UPDATE [dbo].[CWI_JobMediaBuy] SET [IsRemoved]=1,[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
				WHERE ID IN (SELECT Items FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcJobMediaBuyIds,'',''))
				AND (StatusId = 20102 OR StatusId=20101) -- for status selected & pending selection

				--SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)

				IF (SELECT COUNT(*) FROM [dbo].[CWI_JobMediaBuy] WHERE JobId=@inJobId AND IsRemoved=0)=0
				BEGIN			
					EXEC prc_CWI_SetClassificationLifeCycleStatus @inJobId,4001,4205,null,0,@inUserId
				END		

				--EXEC prc_CWI_SetBudgetFromMediaBuy 	@inJobId,1,@inUserId?/*this is commented as trigger created when removing media buy*/
				
				------Remove run dates for the media buy------------
				Delete from CWI_JobMediaBuyRundateTemplateData 
					where MediaBuyId in (SELECT Items FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcJobMediaBuyIds,'',''))
					

				--Inserting into Action table to track History
				DECLARE @InsertAction varchar(8000)
				DECLARE @InsertActionLink varchar(8000)
				DECLARE @AuthorName varchar(1000)
				DECLARE @dtModifiedBy varchar(50)
				DECLARe @VendorName varchar(8000)
				SELECT @VendorName=VendorName FROM CWI_Vendor WHERE ID IN (SELECT VendorId FROM CWI_JobMediaBuy WHERE ID= @vcJobMediaBuyIds)

				SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
				SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

				SET @InsertAction = ''Media Buy '' + @VendorName + '' removed by '' + @AuthorName + '' on '' + @dtModifiedBy
				SET @InsertActionLink=''Media Buy '' + @VendorName + '' removed for job '' + Convert(varchar,@inJobId) + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@inJobId) + ''></a>'' + '' by '' + @AuthorName + '' on '' + @dtModifiedBy

				EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
					@ActionLookupId = 10011,
					@Action = @InsertAction,
					@ActionWithLink = @InsertActionLink,
					@CreatedBy = @inUserId	

				------------for media buy history---------
				EXEC prc_CWI_SetAction @ObjectLookupId = 211, @ObjectId = @inJobId,
					@ActionLookupId = 10011,
					@Action = @InsertAction,
					@ActionWithLink = @InsertActionLink,
					@CreatedBy = @inUserId
			END	
		END

	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END










' 
END
GO
