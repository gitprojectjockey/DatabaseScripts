/****** Object:  StoredProcedure [dbo].[prc_Citi_VCNAuthsByReportIDResponse]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Citi_VCNAuthsByReportIDResponse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Citi_VCNAuthsByReportIDResponse]
GO
/****** Object:  StoredProcedure [dbo].[prc_Citi_VCNAuthsByReportIDResponse]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Citi_VCNAuthsByReportIDResponse]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

    
/*******************************************************************    
* PROCEDURE: prc_Citi_VCNAuthsByReportIDResponse
* Purpose : This PROC would be invoked from Citi Webservice 
                    
* CREATED:  Ajay Thacker on 13July2012
* MODIFICATION HISTORY    
* DATE  AUTHOR   DESCRIPTION    
**********************************************************************    
 

**********************************************************************    
exec prc_Citi_VCNAuthsByReportIDResponse 88
**********************************************************************/    

--select * from CITI_RawResponseData


CREATE PROCEDURE [dbo].[prc_Citi_VCNAuthsByReportIDResponse]  
@intResponseRawDataID int,
@intHasMore int output,
@intAuthsReportWorkingID int output
AS     
	set ARITHABORT on
	declare @vcRawData varchar(max),
			@xmlRawData xml,
			@xmlVCNAuthsByReportIDRequestData xml,
			@xmlVCNItemData xml,
			@intVCNAuthItemCount int,
			@intVCNAuthItemCounter int,
			@intSettlementID int,
			@vcReturnCodeSuccessFailure varchar(255),
			@vcStatus varchar(255),
			@intPurchaseID int,
	        @intAuthsTrackingID int,
			@vcReportID varchar(100),
			@vcItemsFrom varchar(10),
			@vcItemsTo varchar(10),
			@intItemsFrom int,
			@intItemsTo int,
			@vcHasMore varchar(10),
			@intMaxTxnID int,

			@intAcquirerId int,
			@intRawRequestDataID int,
			@intVCNAuthsWorkingID int,
			@intVCNAuthsDumpID int,
			@vcCardNumber varchar(100),
			@numAmountTransaction numeric(11,2),
			@vcRespCode varchar(2),
			@dtTempMST datetime

set @intHasMore = 0

	set @intVCNAuthItemCounter = 1
	set @vcReturnCodeSuccessFailure = ''''
	
	set @intAuthsReportWorkingID = 0
	set @intVCNAuthsWorkingID = 0

	
	set @intRawRequestDataID = (select rawRequestDataID from CITI_RawResponseData
								where ID = @intResponseRawDataID)


set @intAuthsTrackingID = (select ID from Citi_AuthsTracking
								where RawRequestDataID = @intRawRequestDataID)

 set @intVCNAuthsWorkingID = (Select ID from dbo.CITI_VCNAuthsWorking
								where CurrentAuthsTrackingID = @intAuthsTrackingID)


--   set @intMaxTxnID = (Select isnull(max(TxnID),0) from CITI_VCNAuthsDump)
						
	
--get rawdata from raw table
	set @vcRawData = (select convert(varchar(max),rawdata) from CITI_RawResponseData
						where ID = @intResponseRawDataID)	
 set @vcRawData = replace(@vcRawData,''encoding="UTF-8"'','''')
 set @xmlRawData = @vcRawData
	
--Determine if the response is a success or failure
	set @vcReturnCodeSuccessFailure =  (select  
											appr.value(''(@ReturnCode)[1]'',''varchar(50)'')
										from @xmlRawData.nodes(''/OrbiscomResponse'') apprTBL(appr)
										)
	print ''@vcReturnCodeSuccessFailure''
	print @vcReturnCodeSuccessFailure
	if @vcReturnCodeSuccessFailure = ''Success'' --parse success data
	begin

		set @xmlVCNAuthsByReportIDRequestData = @xmlRawData.query(''//OrbiscomResponse/GetVCNAuthsByReportIdResponse[1]'') 					
		set @vcReportID = (select  
							appr.value(''(@ReportId)[1]'',''varchar(100)'')
							from @xmlVCNAuthsByReportIDRequestData.nodes(''/GetVCNAuthsByReportIdResponse'') apprTBL(appr)
							)
			print ''@vcReportID''
			print @vcReportID
			
		set @vcItemsFrom = (select  
					appr.value(''(@From)[1]'',''varchar(10)'')
					from @xmlVCNAuthsByReportIDRequestData.nodes(''/GetVCNAuthsByReportIdResponse/Items'') apprTBL(appr)
				)
		set @vcItemsTo = (select  
					appr.value(''(@To)[1]'',''varchar(10)'')
					from @xmlVCNAuthsByReportIDRequestData.nodes(''/GetVCNAuthsByReportIdResponse/Items'') apprTBL(appr)
				)
		set @vcHasMore = (select  
					appr.value(''(@HasMore)[1]'',''varchar(10)'')
					from @xmlVCNAuthsByReportIDRequestData.nodes(''/GetVCNAuthsByReportIdResponse/Items'') apprTBL(appr)
				)
		if upper(@vcHasMore) = ''TRUE''
				set @intHasMore = 1
						

		print @vcItemsFrom
		print @vcItemsTo
		print @vcHasMore

		set @intVCNAuthItemCount = (SELECT @xmlRawData.value(''count(//OrbiscomResponse/GetVCNAuthsByReportIdResponse/Items/VCNAuthItem)'',''INT''))
		print @intVCNAuthItemCount

		while @intVCNAuthItemCounter <= @intVCNAuthItemCount
				begin
					print @intVCNAuthItemCounter
					set @xmlVCNItemData = @xmlRawData.query(''//OrbiscomResponse/GetVCNAuthsByReportIdResponse/Items/VCNAuthItem[sql:variable("@intVCNAuthItemCounter")]'') 					
					/*
					set @intAcquirerId = (select  
						appr.value(''(@AcquirerId)[1]'',''int'')
						from @xmlVCNItemData.nodes(''/VCNAuthItem'') apprTBL(appr)
						)
					print @intAcquirerId
					*/
				insert into CITI_VCNAuthsDump
				(RawResponseDataID,AcquirerID,AmountTransaction,CardAcceptorID,CorporateName,CardNumber,
				 CurrencyCodeTransaction,Description,EffectOnCardAmount,ExpiryDate,MerchantName,PurchaseID,
				RespCode,Settled,Status,SystemDate,TxnID,TxnType,UserName,VCardAlias,CreatedBy)
				select  @intResponseRawDataID,
						appr.value(''(@AcquirerId)[1]'',''int''),
						appr.value(''(@AmountTransaction)[1]'',''numeric(11,2)''),
						appr.value(''(@CardAcceptorId)[1]'',''varchar(100)''),
						appr.value(''(@CorporateName)[1]'',''varchar(100)''),
						appr.value(''(@CpnPan)[1]'',''varchar(100)''),
						appr.value(''(@CurrencyCodeTransaction)[1]'',''int''),
						appr.value(''(@Description)[1]'',''varchar(255)''),
						appr.value(''(@EffectOnCpnAmount)[1]'',''numeric(11,2)''),
						appr.value(''(@ExpiryDate)[1]'',''varchar(4)''),
						appr.value(''(@MerchantName)[1]'',''varchar(40)''),
						appr.value(''(@PurchaseId)[1]'',''int''),
						appr.value(''(@RespCode)[1]'',''varchar(2)''),
						appr.value(''(@Settled)[1]'',''varchar(1)''),
						appr.value(''(@Status)[1]'',''varchar(1)''),
						appr.value(''(@SystemDate)[1]'',''varchar(50)''),
						appr.value(''(@TxnId)[1]'',''int''),
						appr.value(''(@TxnType)[1]'',''int''),
						appr.value(''(@UserName)[1]'',''varchar(150)''),
						appr.value(''(@VCardAlias)[1]'',''varchar(150)''),
						''prc_Citi_VCNAuthsByReportIDResponse''
						from @xmlVCNItemData.nodes(''/VCNAuthItem'') apprTBL(appr)
						left JOIN CITI_VCNAuthsDump authdump
						ON appr.value(''(@TxnId)[1]'',''int'') = authdump.TxnID
							--and authdump.txnid > @intMaxTxnID 
						where authdump.TXNID is null

				set @intVCNAuthsDumpID = @@identity
				
				if isnull(@intVCNAuthsDumpID,0) != 0
				begin

						set @vcCardNumber = (select Cardnumber from CITI_VCNAuthsDump
												where ID = @intVCNAuthsDumpID)
						set @numAmountTransaction = (select AmountTransaction from CITI_VCNAuthsDump
												where ID = @intVCNAuthsDumpID)
						set @vcRespCode = (select RespCode from CITI_VCNAuthsDump
												where ID = @intVCNAuthsDumpID)

						set @dtTempMST = (select replace(SystemDate,''+0000'','''') from CITI_VCNAuthsDump
												where ID = @intVCNAuthsDumpID)
					
						set	@dtTempMST = dateadd(hh,datediff(hh,getutcdate(),getdate()),@dtTempMST)
					
						--Exec vcm_updateCost if Its not a Decline and if AuthAmount > 0
						if len(isnull(@vcCardNumber,'''')) > 0 and isnull(@numAmountTransaction,0) > 0
							and isnull(@vcRespCode,'''') = ''00''
								exec vcm_updateCost @vcCardNumber,@numAmountTransaction

						--insert into comdataTransaction
								Insert into COMDATATransaction
								(
									CustID,
									CardNo,
									TransactionDate,
									TransactionTime,
									TotalAmountBilled,
									PostedDate,
									PostedTime,
									MCCCode,
									ErrCode,
									ErrDescription,
									StationInformation,
									PreAuthAmt,
									ApprovalNumber,
									CreatedDatetime,
									CreatedBy,
									CitiVCNAuthsDumpID

								)
								Select
									AcquirerID,
									CardNumber,
									convert(datetime,convert(VARCHAR(10),@dtTempMST,101)),
									convert(datetime,convert(VARCHAR(10),@dtTempMST,108)),
									0,
									null,
									null,
									AcquirerID,
									Respcode,
									Description,
									MerchantName,
									AmountTransaction,
									CASE WHEN RespCode = ''00'' THEN PurchaseID
											else 0
									end,
									getdate(),
									''prc_CITI_VCNAuthsByVCardResponse'',
									@intVCNAuthsDumpID
								from CITI_VCNAuthsDump
								where ID = @intVCNAuthsDumpID
				
						--> Exec vcm_updateapstatus
						Exec vcm_updateapstatus @vcCardNumber
	
				END
				
				set @intVCNAuthItemCounter= @intVCNAuthItemCounter + 1
				end --end of while
			
				
				update Citi_AuthsTracking
				Set ResponseItemsFrom = convert(int,@vcItemsFrom),
					ResponseItemsTo	 = convert(int,@vcItemsTo),
					ResponseHasMore = @vcHasMore,
					ResponseReportID = @vcReportID,
					RawResponseDataID = @intResponseRawDataID,
					ResponseCreatedOn = getdate(),
					ResponseCreatedBy = ''prc_Citi_VCNAuthsByReportIDResponse''
				where ID = @intAuthsTrackingID
				


-----
/*
From the vcReportId, get the AuthsReportWorkingID
From AuthsReportWorkingID, check if VCNAuthsWorkingID is null or not
if VCNAuthsWorkingID is not null, this means its a carried forward request
now check if has more = false
if hasmore is false, then mark the carried forward request as complete.
if has more is true, then update CITI_AuthsReportWorking 
	with request from and request to data
*/

set @intAuthsReportWorkingID = (select ID from CITI_AuthsReportWorking
								where ReportID = @vcReportID)

set @intVCNAuthsWorkingID = (SELECT VCNAuthsWorkingID from CITI_AuthsReportWorking
							where ID = @intAuthsReportWorkingID
							)
set @intVCNAuthsWorkingID = isnull(@intVCNAuthsWorkingID,0)


	if upper(@vcHasMore) = ''FALSE''
	begin
		if @intVCNAuthsWorkingID != 0
			update CITI_VCNAuthsWorking
				set CurrentRequestStatus_LookupID = 22, -- completed
					CurrentRequestAppEndDatetime = getdate(),
					PreviousRequestStartDateUTC = CurrentRequestStartDateUTC,
					PreviousRequestEndDateUTC = CurrentRequestEndDateUTC,
					PreviousRequestStartDateMST = CurrentRequestStartDateMST,
					PreviousRequestEndDateMST = CurrentRequestEndDateMST,
					PreviousRequestStatus_LookupID = 22, --completed
					PreviousRequestAppStartDateTime = CurrentRequestAppStartDateTime,
					PreviousRequestAppEndDateTime = getdate(),
					PreviousAuthsTrackingID = CurrentAuthsTrackingID
				where ID = @intVCNAuthsWorkingID

			DELETE from CITI_AuthsReportWorking
			where id = @intAuthsReportWorkingID
	end
	else --there are more records
	BEGIN
			
			set @intItemsFrom = convert(int,@vcItemsFrom)
			set @intItemsTo = convert(int,@vcItemsTo)
				
			set @intItemsFrom = @intItemsTo + (SELECT convert(INT,LookupValue) from citi_lookup
													where lookupname = ''VCNAuthsByReportIDRequest_FromSubtract''
											   )
			set @intItemsTo = @intItemsFrom + (SELECT convert(INT,LookupValue) from citi_lookup
													where lookupname = ''VCNAuthsByReportIDRequest_ToAdd''
											   )


			Update CITI_AuthsReportWorking
				set RequestFrom = @intItemsFrom,
					RequestTo = @intItemsTo
				where id = @intAuthsReportWorkingID

	end
					
	update CITI_RawResponseData
			SET isSuccess = 1,
				isProcessed = 1
	where ID = @intResponseRawDataID

			
	END --end of @vcReturnCodeSuccessFailure = ''Success''

else
begin
print ''fail''
	declare	 @vcbody VARCHAR(MAX)
	declare	 @profilename varchar(255)
	declare	 @emailSubject varchar(255),
			@xmlErr xml
			

	set @xmlErr = @xmlRawData.query(''//OrbiscomResponse/Error'')

	Update CITI_AuthsReportWorking
		set RequestStatus_LookupID = 32, --completed
					AppEndDateTime = getdate()
		where id = @intAuthsReportWorkingID

	update CITI_RawResponseData
	SET isSuccess = 0,
		isProcessed = 1
	where ID = @intResponseRawDataID

	update CITI_VCNAuthsWorking
		SET CurrentRequestStatus_LookupID = 23,	 --error
			CurrentRequestAppEndDatetime = getdate()
	where ID = @intVCNAuthsWorkingID

	if exists (select [name] From msdb..sysmail_profile  
				 where [name] = ''MMAAdWorksSupport'')  
		set @profilename = ''MMAAdWorksSupport''  
	else  
		set @profilename = (select top 1 [name] From msdb..sysmail_profile) 
	set @emailSubject = ''prc_Citi_VCNAuthsByReportIDResponse Failed''   
	set @vcbody = ''prc_Citi_VCNAuthsByReportIDResponse Failed.. ''

	
	set @vcbody = @vcbody +  convert(varchar(max),@xmlErr)
	print @vcbody

	EXEC msdb.dbo.sp_send_dbmail 
					@profile_name=@profilename, 
					@recipients = ''ajay.thacker@xerox.com;kevin.barlow@xerox.com'',
					--@copy_recipients= ''ajay.thacker@acs-inc.com'',
					--@blind_copy_recipients = ''ajay.thacker@acs-inc.com'',
					@subject = @emailSubject, 
					@body = @vcbody,
					@body_format = ''text''
			
end





' 
END
GO
