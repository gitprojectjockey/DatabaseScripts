/****** Object:  StoredProcedure [dbo].[prc_CITI_CreateApprovedPurchaseResponse]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CITI_CreateApprovedPurchaseResponse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CITI_CreateApprovedPurchaseResponse]
GO
/****** Object:  StoredProcedure [dbo].[prc_CITI_CreateApprovedPurchaseResponse]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CITI_CreateApprovedPurchaseResponse]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'    
/*******************************************************************    
* PROCEDURE: prc_CITI_CreateApprovedPurchaseResponse
* Purpose : This PROC would be invoked from Citi console app CITI_CreateApprovedPurchaseRequest.sln 
                    
* CREATED:  Ajay Thacker on 15may2012
* MODIFICATION HISTORY    
* DATE  AUTHOR   DESCRIPTION    
**********************************************************************    
    
The "Status" values can be "P","A","D","R"
for Pending,Approved,Deleted,Rejected



    select * from CITI_RawResponseData
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<OrbiscomResponse IssuerId="5" ReturnCode="Success" Version="12.2">
<XMLAuthenticateResponse><ACL><ACL Name="PM.LOGIN" Value="1"/>
<ACL Name="PM.APPROVE" Value="1"/></ACL>
<User EMailAddress="kevin.barlow@xerox.com" GroupName="API User" UserId="107286"
 Username="Xerox-ACS-MTF"/></XMLAuthenticateResponse>
<CreateApprovedPurchaseResponse PurchaseId="424864" RequestId="661697" Status="A">
<CPN AVV="344" Expiry="1209" PAN="5550273211630864"/></CreateApprovedPurchaseResponse>
<CreateApprovedPurchaseResponse PurchaseId="424865" RequestId="661698" Status="A"><CPN AVV="238" Expiry="1209" PAN="5550272989716475"/></CreateApprovedPurchaseResponse><Session SessionId="A2B2BDFF55E8D1EA2CCA7BCFA0CC62B4418DA798"/></OrbiscomResponse>
    

<?xml version="1.0" encoding="UTF-8" standalone="no"?><OrbiscomResponse IssuerId
="5" ReturnCode="Failure" Version="12.2"><Error Code="SG0031" RequestId="9876543
21" Text="Unsupported CDF (VendorID) for purchase Type (Xerox ACS Purchase Type)
"><Params><Param Name="FieldName" Value="VendorID"/><Param Name="PurchaseType" V
alue="Xerox ACS Purchase Type"/></Params></Error></OrbiscomResponse>

UPDATE CITI_RawResponseData set RawData = ''<?xml version="1.0" encoding="UTF-8" standalone="no"?><OrbiscomResponse IssuerId="5" ReturnCode="Failure" Version="12.2"><Error Code="SG0031" RequestId="987654321" Text="Unsupported CDF (VendorID) for purchase Ty

pe (Xerox ACS Purchase Type)"><Params><Param Name="FieldName" Value="VendorID"/><Param Name="PurchaseType" Value="Xerox ACS Purchase Type"/></Params></Error></OrbiscomResponse>'' WHERE id = 3

**********************************************************************    
exec  prc_CITI_CreateApprovedPurchaseResponse 3
**********************************************************************/    
--SELECT * FROM SettlementComDataCCNumber where SettlementID IN (661697,661698)    
--SELECT * FROM COMDATACommunicationControl where SettlementID IN (661697,661698)
--select * from CITI_RawResponseData


CREATE PROCEDURE [dbo].[prc_CITI_CreateApprovedPurchaseResponse]  
@intResponseRawDataID bigint
AS     
	set ARITHABORT on
	declare
			 @vcRawData varchar(max),
			@xmlRawData xml,
			@xmlCreateApprovedPurchaseRequestData xml,
			@intCreateApprovedPurchaseResponseCount int,
			@intCreateApprovedPurchaseResponseCounter int,
			@intSettlementID bigint,
			@vcReturnCodeSuccessFailure varchar(255),
			@vcStatus varchar(255),
			@intPurchaseID bigint,
	        @intComdataCommunicationControlID bigint

	set @intCreateApprovedPurchaseResponseCounter = 1
	set @vcReturnCodeSuccessFailure = ''''
	set @intComdataCommunicationControlID = 0



	--get rawdata from raw table
	set @vcRawData = (select rawdata from CITI_RawResponseData
						where ID = @intResponseRawDataID)					
    --set @vcRawData = replace(@vcRawData,''Success'',''Successs'')
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
		set @intCreateApprovedPurchaseResponseCount = (SELECT @xmlRawData.value(''count(//OrbiscomResponse/CreateApprovedPurchaseResponse)'',''INT''))
		print @intCreateApprovedPurchaseResponseCount
		print @vcRawData
		while @intCreateApprovedPurchaseResponseCounter <= @intCreateApprovedPurchaseResponseCount
		begin
			set @intSettlementID = 0
			set @intPurchaseID = 0
			set @intComdataCommunicationControlID =0
			set @xmlCreateApprovedPurchaseRequestData = @xmlRawData.query(''//OrbiscomResponse/CreateApprovedPurchaseResponse[sql:variable("@intCreateApprovedPurchaseResponseCounter")]'') 					

			--print convert(varchar(max),@xmlCreateApprovedPurchaseRequestData)

				set @intComdataCommunicationControlID = (select  
				appr.value(''(@RequestId)[1]'',''varchar(50)'')
				from @xmlCreateApprovedPurchaseRequestData.nodes(''/CreateApprovedPurchaseResponse'') apprTBL(appr)
			)

			print @intComdataCommunicationControlID

			set @vcStatus = (select  
				appr.value(''(@Status)[1]'',''varchar(50)'')
				from @xmlCreateApprovedPurchaseRequestData.nodes(''/CreateApprovedPurchaseResponse'') apprTBL(appr)
			)

			print @vcStatus
	
			set @intPurchaseID = (select  
				appr.value(''(@PurchaseId)[1]'',''varchar(50)'')
				from @xmlCreateApprovedPurchaseRequestData.nodes(''/CreateApprovedPurchaseResponse'') apprTBL(appr)
			)

			set @intSettlementID = (select SettlementID from COMDATACommunicationControl
									where ID = @intComdataCommunicationControlID)

			update COMDATACommunicationControl
			SET ProcessedDate = getdate(),
				ResponseMessage = case when @vcStatus = ''A'' then ''CARD ADDED''
										when @vcStatus = ''D'' then ''CARD DELETED''
										WHEN @vcStatus = ''P'' then ''CARD PENDING''
										WHEN @vcStatus = ''R'' then ''CARD REJECTED''
									ELSE ''UNKNOWN RESPONSE''
									END,
				ResponseCode = 0, --need to ask Kevin, 
				Retries = 0
			where ID = @intComdataCommunicationControlID


			insert INTO SettlementComDataCCNumber
			(
			SettlementID,CCNumber,ExpirationDate,CVC2Number,Created,RequestID,PurchaseID
			)
			select  
				@intSettlementID,
				appr.value(''(CPN/@PAN)[1]'',''varchar(50)''),
			--appr.value(''(CPN/@Expiry)[1]'',''varchar(50)''),
			right(ltrim(rtrim(appr.value(''(CPN/@Expiry)[1]'',''varchar(50)''))),2) 
				+ left(ltrim(rtrim(appr.value(''(CPN/@Expiry)[1]'',''varchar(50)''))),2),
			appr.value(''(CPN/@AVV)[1]'',''varchar(50)''),
			getdate(),
			appr.value(''(@RequestId)[1]'',''varchar(50)''),
			appr.value(''(@PurchaseId)[1]'',''varchar(50)'')
				from @xmlCreateApprovedPurchaseRequestData.nodes(''/CreateApprovedPurchaseResponse'') apprTBL(appr)
					
		
			 --Stored Procedure for FaxImage is to be called  
			--need to uncomment this on prodn	
			--exec prc_GenerateFaxImageBySettlementID @intSettlementid 
			UPDATE CWI_Correspondence SET IsReadyToProcess = 1
			WHERE JobMediaBuyId = @intComdataCommunicationControlID
			AND IsTrashed = 0
			AND IsReadyToProcess = 0 
			AND CorrespondenceTypeLookupId IN (701,709) /*Insertion and Chnage order */
		
			Insert INTO CITI_RawResponseData_Settlement_Mapping
			(
				RawResponseDataID,
				SettlementID,
				PurchaseID,
				CreatedBy
			)	
			VALUES
			(
				@intResponseRawDataID,@intsettlementID,@intPurchaseID,''prc_CITI_CreateApprovedPurchaseResponse''
			)
		
	
			set @intCreateApprovedPurchaseResponseCounter= @intCreateApprovedPurchaseResponseCounter + 1
		end --end of while

		update CITI_RawResponseData
			SET isSuccess = 1,
				isProcessed = 1
	where ID = @intResponseRawDataID
end
else
begin
print ''fail''
	declare	 @vcbody VARCHAR(MAX)
	declare	 @profilename varchar(255)
	declare	 @emailSubject varchar(255),
			@xmlErr xml,
			@numRetries int,
			@noRetry int
			
	
	--need to check logic from prc_COMDATAprocessResponse and 
	--update this proc.
	set @intComDataCommunicationControlID = (SELECT ComdataCommunicationControlID 
											from citi_communicationRequestResponse
											where rawresponseDataID = @intResponseRawDataID)

	set @intSettlementID = (select SettlementID from COMDATACommunicationControl
									where ID = @intComdataCommunicationControlID)
	set @xmlErr = @xmlRawData.query(''//OrbiscomResponse/Error'')

	Select @noRetry=Retries  from COMDATACommunicationControl 
		where ID = @intComdataCommunicationControlID
	
	if 4 <= @noRetry 
	Begin
			Update COMDATACommunicationControl set ProcessedDate=getdate(),
			ResponseCode=0, ResponseMessage=left(convert(VARCHAR(max),@xmlErr),79)
			where ID=@intComdataCommunicationControlID
		
			Update CWI_JobMediaBuy set PayMethodLookupId = 851 /*Invoice*/  
			where id=@intSettlementid
		--Stored Procedure for FaxImage is to be called
			--need to uncomment this on prod
			--exec prc_GenerateFaxImageBySettlementID @intSettlementid

			UPDATE CWI_Correspondence SET IsReadyToProcess = 1
			WHERE JobMediaBuyId = @intComdataCommunicationControlID
			AND IsTrashed = 0
			AND IsReadyToProcess = 0 
			AND CorrespondenceTypeLookupId IN (701,709) /*Insertion and Chnage order */
		End
		else
		Begin
			Update COMDATACommunicationControl set Retries=Retries+1 
			where SettlementID=@intSettlementID
		End


	update CITI_RawResponseData
	SET isSuccess = 0,
		isProcessed = 1
	where ID = @intResponseRawDataID

	if exists (select [name] From msdb..sysmail_profile  
				 where [name] = ''MMAAdWorksSupport'')  
		set @profilename = ''MMAAdWorksSupport''  
	else  
		set @profilename = (select top 1 [name] From msdb..sysmail_profile) 
	set @emailSubject = ''Citi prc_CITI_CreateApprovedPurchaseResponse Failed''   
	set @vcbody = ''prc_CITI_CreateApprovedPurchaseResponse Failed on kbcdb1\dc4 tmimmrdb for ResponseRawDataID : '' + convert(VARCHAR(20),@intResponseRawDataID) +''.''

	
	set @vcbody = @vcbody +  convert(varchar(max),@xmlErr)
	
	declare @recipients varchar(100)= NULL 
	select @recipients = LookupName from  Lookup where id= 22004

	IF @recipients IS NULL
	Begin
		SET @recipients = ''ajay.thacker@xerox.com;kevin.barlow@xerox.com;Noel.Ruiz@xerox.com;ServiceDesk.Trippak@xerox.com;Jose.Jimeno@xerox.com''
	End

	EXEC msdb.dbo.sp_send_dbmail 
					@profile_name=@profilename, 
					@recipients = @recipients,
					--@copy_recipients= ''ajay.thacker@acs-inc.com'',
					--@blind_copy_recipients = ''ajay.thacker@acs-inc.com'',
					@subject = @emailSubject, 
					@body = @vcbody,
					@body_format = ''text''
			
end

' 
END
GO
