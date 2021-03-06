/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobGenerateInsertion]    Script Date: 10/14/2014 6:43:39 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobGenerateInsertion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobGenerateInsertion]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobGenerateInsertion]    Script Date: 10/14/2014 6:43:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobGenerateInsertion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobGenerateInsertion 
* Purpose : This PROC would be called TO generate the insertion order for the selected media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
    1/29/14	Mohankumar		Quote is added in correspondence        
	01MAY14	Mohankumar		Rundate and classified category validation disabled  
	25May14 Vijesh Mahi		Action table update for submit change order for Media Buy History	
	16JUN14 Mohankumar		Vitual card process initiated for insetion/change order by inserting records in COMDATACommunicationControl					
	14OCT14 Mohankumar		InsertionGeneratedBy and On are updated in CWI_job table					
**********************************************************************  
Execution example :,
**********************************************************************  
declare @OutMsg varchar(max) = ''''
EXEC prc_CWI_SetJobGenerateInsertion 1345,0,3,@OutMsg out
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobGenerateInsertion]	
	@inJobId bigint,
	@IsSubmitChangeOrder bit = 0,	
	@inUserId int,
	@vcMessage varchar(max) OUTPUT  
AS
BEGIN	

	BEGIN TRY		
		DECLARE @InsertAction varchar(8000)
		DECLARE @InsertActionLink varchar(8000)
		DECLARE @AuthorName varchar(1000)
		DECLARE @dtModifiedBy varchar(50)
		DECLARE @tblVendorStatus TABLE(VendorStatus int)
		DECLARE @tblRunDates TABLE(Rundate datetime)

		DECLARE @inVendorStatus bit,@isGenerate bit,@inMMRPO int,@inVendorCount int
		/*
		Rundate and classified category validation disabled
		
		DECLARE @isRundateExists bit,@inClassificationCategory int

		DECLARE @tblJobSummaryTemplateData TABLE
		(
			MappingFieldId int, FieldValue varchar(1000)
		)

		*/
		DECLARE 
				@IsQuote bit = 0,
				@inMediaBuyStatus int = 20103	

		SET @vcMessage = ''''
		SET @isGenerate = 1
		SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
		SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

		DECLARE @tblJobActionAttribute tt_CWI_JobActionAttribute
		INSERT INTO @tblJobActionAttribute
		EXEC prc_CWI_GetJobActionAttributes @inJobId


		SELECT @IsQuote = IsQuote 
		FROM @tblJobActionAttribute

		/*
		--Rundate and classifiec category validation disabled
		INSERT INTO @tblJobSummaryTemplateData
		SELECT * FROM dbo.fnc_GetJobSummaryTemplateData(@inJobId)
		-----Rundate Validation------

		IF EXISTS (SELECT top 1 1 FROM @tblJobSummaryTemplateData 
				WHERE
					ISNULL(FieldValue,'''') <> ''''
					AND (MappingFieldId in (20201, 20202, 20203, 20204,20205,20206,20207))
				)
		BEGIN
			SET @isRundateExists = 1
		END
		
		-- Rundate validation disabled
		IF @isRundateExists <> 1
		BEGIN
			SET @vcMessage = ''Minimum one weekly rundate required''
			SET @isGenerate=0
			RETURN
		END
		
		INSERT INTO @tblRunDates		
		SELECT top 1 FieldValue AS Rundate FROM @tblJobSummaryTemplateData where MappingFieldId = 20201
		UNION ALL
		SELECT top 1 FieldValue  AS Rundate FROM @tblJobSummaryTemplateData where MappingFieldId = 20202
		UNION ALL
		SELECT top 1 FieldValue  AS Rundate FROM @tblJobSummaryTemplateData where MappingFieldId = 20203
		UNION ALL
		SELECT top 1 FieldValue  AS Rundate FROM @tblJobSummaryTemplateData where MappingFieldId = 20204
		UNION ALL
		SELECT top 1 FieldValue  AS Rundate FROM @tblJobSummaryTemplateData where MappingFieldId = 20205
		UNION ALL
		SELECT top 1 FieldValue  AS Rundate FROM @tblJobSummaryTemplateData where MappingFieldId = 20206
		UNION ALL
		SELECT top 1 FieldValue  AS Rundate FROM @tblJobSummaryTemplateData where MappingFieldId = 20207
		
		
		IF (SELECT COUNT(*) FROM @tblRunDates WHERE Rundate < GETDATE() AND Rundate IS NOT NULL) > 0
		BEGIN
			SET @vcMessage = ''Run dates should be greater than todays date''
			SET @isGenerate=0
			RETURN
		END		
		*/

		/* CLassified category validation disabled
		-----Classification Category validation-----
		SET @inClassificationCategory = (SELECT FieldValue FROM 
										@tblJobSummaryTemplateData where MappingFieldId = 20209)
		IF @inClassificationCategory IS NULL OR @inClassificationCategory=0
		BEGIN
			SET @vcMessage = ''Classified category is not selected for the job.Please select the classified category''
			SET @isGenerate=0
			RETURN
		END	
		*/
		
		DECLARE @actionMessage varchar(max) = ''''
		IF @IsSubmitChangeOrder = 1 /* Validation for submit change order */
		begin
			SELECT @actionMessage = LTRIM(RTRIM(SubmitChangeOrderComment))  FROM @tblJobActionAttribute 

			IF @actionMessage <> ''''
			BEGIN
				SET @vcMessage = @actionMessage
				SET @isGenerate=0
			END
		end
		else
		begin /* Validation for insertion order/quote generation  */
			SELECT @actionMessage = LTRIM(RTRIM(InsertionOrderComment))  FROM @tblJobActionAttribute 

			IF @actionMessage <> ''''
			BEGIN
				SET @vcMessage = @actionMessage
				SET @isGenerate=0
			END
		end


		------If all validations are success then update media buy & job tables----
		IF @isGenerate = 1
		BEGIN

			BEGIN TRANSACTION TRAN1
			BEGIN TRY
				IF( @IsSubmitChangeOrder=1 )
				BEGIN
					UPDATE 	[dbo].[CWI_Job] SET IsChangeOrder=1 , InsertionGeneratedBy = @inUserId
					WHERE ID=@inJobId;

					UPDATE 	
						[dbo].[CWI_JobMediaBuy]	
					SET 
						ExpectedCost=ActualCost,
						ExpectedInvoice = ActualInvoice,
						--ActualCost = NULL,
						--ActualInvoice = NULL,
						ModifiedBy=@inUserId,
						ModifiedOn=GETDATE(),
						InsertionStatusLookupId	= 3101/* Pending */
					WHERE [JobId]=@inJobId 
					AND StatusId = 20103 /* Generated */ AND IsRemoved = 0 
					AND DNR = 0 AND IsCancelled = 0

					SET @InsertAction = ''Submit change order generated by ''+ @AuthorName + '' on '' + @dtModifiedBy --+'' for the vendor '' +@vcVendorCode
					SET @InsertActionLink=''Submit change order for job '' + Convert(varchar,@inJobId) + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@inJobId) + ''></a>'' + ''created by '' + @AuthorName + '' on '' + @dtModifiedBy
			
					EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
						@ActionLookupId = 10014,
						@Action = @InsertAction,
						@ActionWithLink = @InsertActionLink,
						@CreatedBy = @inUserId

					-------below part added for tracking media buy history--------------------------
					declare @tblVendor table(MediaBuyId bigint)
					insert into @tblVendor
						select ID from CWI_JobMediaBuy where JobId=@inJobId and IsRemoved=0 and IsCancelled=0 and DNR=0
					while (select count(*) from @tblVendor) > 0
					begin
						declare @inMediaBuyId bigint

						set @inMediaBuyId = (select top 1 MediaBuyId from @tblVendor)						
						SET @InsertAction = ''Submit change order generated by ''+ @AuthorName + '' on '' + @dtModifiedBy --+'' for the vendor '' +@vcVendorCode
						SET @InsertActionLink=''Submit change order for job '' + Convert(varchar,@inJobId) + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@inJobId) + ''></a>'' + ''created by '' + @AuthorName + '' on '' + @dtModifiedBy
			
						EXEC prc_CWI_SetAction @ObjectLookupId = 211, @ObjectId = @inMediaBuyId,
							@ActionLookupId = 10014,
							@Action = @InsertAction,
							@ActionWithLink = @InsertActionLink,
							@CreatedBy = @inUserId
																
						delete from @tblVendor where MediaBuyId=@inMediaBuyId	
					end
					-----------------end------------------------

				END

				IF( @IsSubmitChangeOrder=0 )
				BEGIN
					UPDATE 	[dbo].[CWI_Job] 
					SET InsertionGeneratedBy = @inUserId, 
						InsertionGeneratedOn = GETDATE()
					WHERE ID=@inJobId;

					declare @mmrpo bigint = ( 
				   SELECT  ISNULL(MAX(MMRPO),0) 
				   FROM    [CWI_JobMediaBuy] ); 


					UPDATE 	
						[dbo].[CWI_JobMediaBuy]	
					SET 
						@mmrpo= [MMRPO]= @mmrpo + 1,
						[StatusId]=@inMediaBuyStatus,
						ModifiedBy=@inUserId,
						ModifiedOn=GETDATE(),
						InsertionStatusLookupId	= 3101/* Pending */		
					WHERE [JobId]=@inJobId 
						AND StatusId = 20102 /* Selected */ 
						AND IsRemoved = 0 
						AND IsCancelled = 0 
						AND DNR = 0

					UPDATE [CWI_JobMediaBuy] SET PayMethodLookupId = V.PayMethodLookupId
					FROM [CWI_JobMediaBuy] JMB
					INNER JOIN CWI_Vendor V
						ON JMB.VendorId = V.Id
					WHERE JMB.JobId = @inJobId

					DECLARE @action varchar(100)=''Insertion order''
					IF @IsQuote = 1
					Begin
						SET @action = ''Quote''
					End
					SET @InsertAction =@action + '' generated by ''+ @AuthorName + '' on '' + @dtModifiedBy --+'' for the vendor '' +@vcVendorCode
					SET @InsertActionLink=@action +'' for job '' + Convert(varchar,@inJobId) + '' <a href="../jobs.aspx?jobid='' + Convert(varchar,@inJobId) + ''></a>'' + ''created by '' + @AuthorName + '' on '' + @dtModifiedBy
			
					EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
						@ActionLookupId = 10010,
						@Action = @InsertAction,
						@ActionWithLink = @InsertActionLink,
						@CreatedBy = @inUserId
					
					END
				----BELOW PART ADDED FOR INSERTING INTO LIFE CYCLE TABLE--------				
				
				EXEC prc_CWI_SetClassificationLifeCycleStatus @inJobId,4003,4205,null,1,@inUserId				
				------------------------END-----------------------

				DECLARE @CorrespondenceTypeLookupId int 

				IF @IsQuote = 1
				begin
					SET @CorrespondenceTypeLookupId = 703
				end
				else IF @IsSubmitChangeOrder = 1
				begin
					SET @CorrespondenceTypeLookupId = 709
				end
				else
				begin
					SET @CorrespondenceTypeLookupId = 701
				end
					
				EXECUTE prc_CWI_SetCorrespondence 	
					@JobId = @inJobId,
					@MMRPO = NULL,
					@CorrespondenceTypeLookupId = @CorrespondenceTypeLookupId,
					@Source  = ''Clientwise Internal'',
					@Author = @inUserId

			IF @CorrespondenceTypeLookupId IN (701,709)	/*insertion and change order*/ -- Initiate virtual card process	
			Begin
				DECLARE @ComDataTemplateID int = 2 /* Update in COMDATACommunicationControl table during submit change order  */
				DECLARE @tblVC TABLE
				(
					MBId bigint,
					cost decimal(18,2)
				)

				INSERT INTO @tblVC
				SELECT JMB.Id,  
					case when ActualCost > 0 then
								ActualCost + 1
						else
								V.DefaultCCLimit
						end
				FROM CWI_JobMediaBuy JMB
					INNER JOIN CWI_Vendor V
						ON JMB.VendorId = V.Id
				WHERE [JobId]=@inJobId 
				AND 
				IsRemoved = 0 AND IsCancelled = 0 AND DNR = 0
				AND JMB.PayMethodLookupId = 852 /* virtual card */

				IF @CorrespondenceTypeLookupId = 701 /*insertion , then add virtual card details for media buy in CWI_VCMediaBuy table */
				BEGIN
					SET @ComDataTemplateID = 1 /* Update in COMDATACommunicationControl table during Insertion Order */
					INSERT INTO CWI_VCMediaBuy
					(
						MediaBuyId,
						VCStatusLookupId
					)
					SELECT MBId, 22141	/*Credit Card Requested */ FROM @tblVC
				END
				
				-- Inserting into COMDATACommunicationContro for Paymethod virtual card
				Insert into COMDATACommunicationControl
				(SettlementID,ComDataTemplateID,Created,ResponseCode,CCLimit)
				SELECT MBId,@ComDataTemplateID,GETDATE(),0,  
					cost
				FROM @tblVC
				
					
			End
										

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT >0 
					ROLLBACK TRANSACTION TRAN1;
				EXEC prc_CWI_AppRaiseError;
				THROW;
			END CATCH
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION TRAN1;
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


