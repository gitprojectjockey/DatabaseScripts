/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobMediaBuy]    Script Date: 6/28/2014 4:14:23 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobMediaBuy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobMediaBuy]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobMediaBuy]    Script Date: 6/28/2014 4:14:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobMediaBuy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: [prc_CWI_SetJobMediaBuy] 
* Purpose : This PROC would be called TO INSERT OR UPDATE the selected vendor for media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  29APR14	Mohankumar		History and Vendor last used on implmented          
  12Jun14	Vijesh			Rollback remove media buy 
  16JUN14	Mohankumar		payment method added while adding vendors 
  25JUN14	Vijesh			Change job status to in progress if status is assigned
**********************************************************************  
Execution example :,
**********************************************************************  

declare @p6 int
set @p6=NULL
exec dbo.prc_CWI_SetJobMediaBuy @inJobId=216,@vcVendorIds=''6873'',@inMMRPO=NULL,@inMediaBuyStatus=20102,@inUserId=3,@inRowCount=@p6 output
select @p6
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobMediaBuy]	
	@inJobId bigint,	
	@vcVendorIds varchar(MAX),
	@inMMRPO bigint=NULL,
	@inMediaBuyStatus int,		
	@inUserId int,
	--@vcRemovedVendors varchar(MAX)=NULL,
	@vcMessage varchar(max) OUTPUT   
AS
BEGIN	
	BEGIN TRANSACTION
	BEGIN TRY	
		DECLARE @TBL_VENDOR TABLE (VendorId INT, PaymentId int) 
		DECLARE @TBL_MBVENDOR TABLE (MBVendorId INT) 		
		DECLARE @inStatusID INT 
		Declare @inJobStatus int

		SET @vcMessage = ''''

		Set @inJobStatus = (Select JobStatusLookupId from CWI_Job where id=@inJobId)

		if @inJobStatus = 8012  ---lookup id 8012 is assigned job status
		begin
			update CWI_Job set JobStatusLookupId=8001 where ID=@inJobId	---setting job status as In Progress from Assigned
		end

		SELECT top 1 @inStatusID =  StatusId FROM CWI_JobMediaBuy 
		WHERE JobId=@inJobId AND IsRemoved=0
		
		IF @inStatusID <> 20102 /* Selected */--If other than selected, return the warning message
		BEGIN
			SET @vcMessage = ''Insertion order already generated for job. Please refesh the page.''
		END
		ELSE
		BEGIN
				--If @vcRemovedVendors is not null
				--begin					
					--declare @vcRemoveMessage varchar(max),@vcMediaBuyIds varchar(max)=null

					--set @vcMediaBuyIds = (select substring((select '',''+convert(varchar,ID)
										--from CWI_JobMediaBuy where VendorId in 
										--(Select items From fnc_SplitCommaSeparatedValuesIntoTable(@vcRemovedVendors,'','')) 
										--and JobId=@inJobId and IsRemoved=0 for xml path('''')),2,200000))

					--if @vcMediaBuyIds is not null
					--begin
					--	declare @tblRemoveVendor table (MediaBuyId int)

					--	insert into @tblRemoveVendor
					--		select items from fnc_SplitCommaSeparatedValuesIntoTable(@vcMediaBuyIds,'','')

					--	while(select count(*) from @tblRemoveVendor)>0
					--	begin
					--		declare @mId varchar(max)
					--		set @mId = (select top 1 convert(varchar,MediaBuyId) from @tblRemoveVendor)
					--		exec prc_CWI_SetJobRemoveMediaBuy @mId,@inJobId,@inUserId,@vcRemoveMessage 
					--		delete from @tblRemoveVendor where MediaBuyId=@mId
					--	end
					--end
					--else
				--	begin
				--		set @vcMessage = ''Page refreshed as the media buy has been updated by another user''
				--	end

				--	if @vcRemoveMessage is not null
				--	begin 
				--		set @vcMessage = ''Page refreshed as the media buy has been updated by another user''
				--	end
				--end
				if (@vcMessage = '''' or @vcMessage is null)
				Begin
						INSERT INTO @TBL_VENDOR (VendorId)
						Select items From fnc_SplitCommaSeparatedValuesIntoTable(@vcVendorIds,'','')

						/* Get Payment methods of each vendor */
						UPDATE @TBL_VENDOR SET PaymentId = V.PayMethodLookupId
						FROM CWI_Vendor V
						WHERE V.id = VendorId
			
						UPDATE CWI_JobMediaBuy SET IsRemoved = 0,ExpectedCost=dbo.fnc_CWI_AvgActualCost(t.VendorId,@inJobId),
						ExpectedInvoice=dbo.fnc_CalculateInvoice(dbo.fnc_CWI_AvgActualCost(t.VendorId,@inJobId),@inJobId),
						ActualCost=NULL,ActualInvoice=NULL,
						IsActualCostFreeze=0,IsActualInvoiceFreeze=0,IsComplimentary=0,
						IsComplimentaryInvoice=0,DNR=0,
						PayMethodLookupId = t.PaymentId
						OUTPUT INSERTED.VendorId INTO @TBL_MBVENDOR
						FROM @TBL_VENDOR t
						INNER JOIN CWI_JobMediaBuy JMB 
							ON t.VendorId = JMB.VendorId AND JMB.JobId = @inJobId
								AND IsRemoved = 1
		
						INSERT INTO [dbo].[CWI_JobMediaBuy]
								([JobId],[VendorId],[MMRPO],[StatusId],
								[CreatedBy],[CreatedOn],[ModifiedBy],[ModifiedOn],[ExpectedCost],
								[ExpectedInvoice],PayMethodLookupId)
							OUTPUT INSERTED.VendorId INTO @TBL_MBVENDOR
						SELECT
						@inJobId,t.VendorId,@inMMRPO,@inMediaBuyStatus,@inUserId
						,GETDATE(),@inUserId,
						GETDATE(),
						dbo.fnc_CWI_AvgActualCost(t.VendorId,@inJobId),
						dbo.fnc_CalculateInvoice(dbo.fnc_CWI_AvgActualCost(t.VendorId,@inJobId),@inJobId),
						t.PaymentId			
						FROM @TBL_VENDOR t
						LEFT OUTER JOIN CWI_JobMediaBuy JMB
							ON t.VendorId = JMB.VendorId AND JMB.JobId = @inJobId
					
						WHERE JMB.ID is NULL
			
						--SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
		
						DECLARE @tblVendor TABLE
						(
							VendorId int,
							VendorCode varchar(max),
							VendorName varchar(max)
						)
						IF EXISTS (SELECT TOP 1 1 FROM @TBL_MBVENDOR)
						BEGIN
							UPDATE CWI_Vendor SET LastUsedOn = GETDATE()
							OUTPUT INSERTED.Id,INSERTED.VendorCode,INSERTED.VendorName INTO @tblVendor
							FROM @TBL_MBVENDOR
							WHERE MBVendorId = Id		

							DECLARE @vendors varchar(max) = ''''
							SELECT @vendors = STUFF((SELECT '','' + VendorCode 
								FROM @tblVendor
								FOR XML PATH('''')) ,1,1,'''')
		
							--Inserting into Action table to track History
							DECLARE @InsertAction varchar(8000)
							DECLARE @InsertActionLink varchar(8000)
							DECLARE @AuthorName varchar(1000)
							DECLARE @dtModifiedBy varchar(50)

							SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
							SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

							SET @InsertAction = ''Job# ''+ CAST(@inJobId as varchar(max)) +'' Media buy(s) ''+ @vendors +'' selected by '' + @AuthorName + '' on '' + @dtModifiedBy
							SET @InsertActionLink = ''Job# ''+ CAST(@inJobId as varchar(max)) +  ''<a href="../jobs.aspx?jobid=''+ CAST(@inJobId as varchar(max))+''></a> '' +'' Media buy(s) ''+ @vendors +'' selected by '' + @AuthorName + '' on '' + @dtModifiedBy
		
		
							EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
								@ActionLookupId = 10009,
								@Action = @InsertAction,
								@ActionWithLink = @InsertAction,
								@CreatedBy = @inUserId	

							-------below part added for tracking media buy history--------------------------
							while (select count(*) from @tblVendor) > 0
							begin
								declare @inMediaBuyId bigint,@inVendorId int, @vcVendorCode varchar(max),@vcVendorName varchar(max)

								set @inVendorId = (select top 1 VendorId from @tblVendor)
								set @vcVendorCode = (select top 1 VendorCode from @tblVendor)
								set @vcVendorName = (select top 1 VendorName from @tblVendor)
								set @inMediaBuyId = (select ID from CWI_JobMediaBuy where VendorId=@inVendorId and JobId=@inJobId)

								SET @InsertAction = '' Media buy ''+ @vcVendorCode+''-''+@vcVendorName +'' selected by '' + @AuthorName + '' on '' + @dtModifiedBy
								SET @InsertActionLink = ''Job# ''+ CAST(@inJobId as varchar(max)) +  ''<a href="../jobs.aspx?jobid=''+ CAST(@inJobId as varchar(max))+''></a> '' +'' Media buy ''+ @vcVendorCode +'' selected by '' + @AuthorName + '' on '' + @dtModifiedBy
		
								EXEC prc_CWI_SetAction @ObjectLookupId = 211, @ObjectId = @inMediaBuyId,
									@ActionLookupId = 10009,
									@Action = @InsertAction,
									@ActionWithLink = @InsertAction,
									@CreatedBy = @inUserId
										
								delete from @tblVendor where VendorId=@inVendorId	
							end
							-----------------end------------------------

							EXEC prc_CWI_SetClassificationLifeCycleStatus @inJobId,4001,4205,null,1,@inUserId
					END
							-----------------------END-----------------------
				end
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

END
	



' 
END
GO
