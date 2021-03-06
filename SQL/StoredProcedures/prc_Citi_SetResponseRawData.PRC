/****** Object:  StoredProcedure [dbo].[prc_Citi_SetResponseRawData]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Citi_SetResponseRawData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Citi_SetResponseRawData]
GO
/****** Object:  StoredProcedure [dbo].[prc_Citi_SetResponseRawData]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Citi_SetResponseRawData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
    
/*******************************************************************    
* PROCEDURE: prc_Citi_SetResponseRawData
* Purpose : This PROC would be invoked from Citi Webservice 
                    
* CREATED:  Ajay Thacker on 15may2012
* MODIFICATION HISTORY    
* DATE  AUTHOR   DESCRIPTION    
**********************************************************************    
    
grant execute on  to  


    select * from CITI_RawResponseData
    
**********************************************************************    
exec prc_Citi_SetResponseRawData @intRawRequestDataID=8,@vcResponse=''<?xml version="1.0" encoding="UTF-8" standalone="no"?><OrbiscomResponse IssuerId="5" ReturnCode="Success" Version="12.2"><XMLAuthenticateResponse><ACL><ACL Name="PM.LOGIN" Value="1"/><AC

L Name="PM.APPROVE" Value="1"/></ACL><User EMailAddress="kevin.barlow@xerox.com" GroupName="API User" UserId="107286" Username="Xerox-ACS-MTF"/></XMLAuthenticateResponse><CreateApprovedPurchaseResponse PurchaseId="425492" RequestId="827853" Status="A"><CP

N AVV="176" Expiry="1210" PAN="5550279806818202"/></CreateApprovedPurchaseResponse><Session SessionId="5315553C94D8405FF8C97C956CA0752BC0FA3446"/></OrbiscomResponse>'',@vcRAWXMLFilePath=''\\dcespfs1\esp\CITI\DEV\Response\RawXML\RequestID_8.xml'',@intResponse

Type_LookupID=1

exec prc_Citi_SetResponseRawData @intRawRequestDataID=90,@vcResponse=''<?xml version="1.0" encoding="UTF-8" standalone="no"?><OrbiscomResponse 
IssuerId="5" ReturnCode="Success" Version="12.2"><XMLAuthenticateResponse><ACL><ACL Name="PM.LOGIN" Value="1"/><ACL Name="PM.APPROVE" 
Value="1"/></ACL><User EMailAddress="kevin.barlow@xerox.com" GroupName="API User" UserId="107286" 
Username="Xerox-ACS-MTF"/></XMLAuthenticateResponse><GetVCNAuthsByVCardResponse DownloadURL="report/1288606994346993785422444102.csv" 
ReportId="1288606994346993785422444102"><Items From="0" HasMore="true" To="10"><VCNAuthItem AcquirerId="999674" AmountTransaction="100" 
CardAcceptorId="123456789012345" CorporateName="Xerox ACS" CpnPan="5550275410882428" CurrencyCodeTransaction="840" Description="Cumul limit fail" 
EffectOnCpnAmount="0" ExpiryDate="1210" MerchantName="MTF TEST               MTF            MO" PurchaseId="425506" RespCode="51" Settled="U" 
Status="A" SystemDate="2012-06-28 18:32:33.00 +0000" TxnId="39054" TxnType="0" UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem 
AcquirerId="999674" AmountTransaction="1" CardAcceptorId="123456789012345" CorporateName="Xerox ACS" CpnPan="5550277362606227" 
CurrencyCodeTransaction="840" Description="Num usages fail" EffectOnCpnAmount="0" ExpiryDate="1210" MerchantName="MTF TEST               MTF            
MO" PurchaseId="425502" RespCode="05" Settled="U" Status="A" SystemDate="2012-06-28 18:28:04.00 +0000" TxnId="39052" TxnType="0" 
UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem AcquirerId="999674" AmountTransaction="5" CardAcceptorId="123456789012345" 
CorporateName="Xerox ACS" CpnPan="5550277362606227" CurrencyCodeTransaction="840" Description="Approval" EffectOnCpnAmount="5" ExpiryDate="1210" 
MerchantName="MTF TEST               MTF            MO" PurchaseId="425502" RespCode="00" Settled="S" Status="A" SystemDate="2012-06-28 18:26:49.00 
+0000" TxnId="39050" TxnType="0" UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem AcquirerId="999674" AmountTransaction="20" 
CardAcceptorId="123456789012345" CorporateName="Xerox ACS" CpnPan="5550277362606227" CurrencyCodeTransaction="840" Description="Approval" 
EffectOnCpnAmount="20" ExpiryDate="1210" MerchantName="MTF TEST               MTF            MO" PurchaseId="425502" RespCode="00" Settled="S" 
Status="A" SystemDate="2012-06-28 18:26:02.00 +0000" TxnId="39048" TxnType="0" UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem 
AcquirerId="999674" AmountTransaction="25" CardAcceptorId="123456789012345" CorporateName="Xerox ACS" CpnPan="5550277362606227" 
CurrencyCodeTransaction="840" Description="Approval" EffectOnCpnAmount="25" ExpiryDate="1210" MerchantName="MTF TEST               MTF            MO" 
PurchaseId="425502" RespCode="00" Settled="S" Status="A" SystemDate="2012-06-28 18:25:45.00 +0000" TxnId="39046" TxnType="0" UserName="Xerox-ACS-MTF" 
VCardAlias="TestRCN1"/><VCNAuthItem AcquirerId="999674" AmountTransaction="25" CardAcceptorId="123456789012345" CorporateName="Xerox ACS" 
CpnPan="5550277362606227" CurrencyCodeTransaction="840" Description="Iss/Netwk decline" EffectOnCpnAmount="0" ExpiryDate="1210" MerchantName="MTF 
TEST               MTF            MO" PurchaseId="425502" RespCode="14" Settled="U" Status="A" SystemDate="2012-06-28 18:22:45.00 +0000" TxnId="39044" 
TxnType="0" UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem AcquirerId="999674" AmountTransaction="100" CardAcceptorId="1234567890ABCDE" 
CorporateName="Xerox ACS" CpnPan="5550275410882428" CurrencyCodeTransaction="840" Description="Approval" EffectOnCpnAmount="100" ExpiryDate="1210" 
MerchantName="NEETA LOPES ACQ SIM    ST.LOUIS      MO " PurchaseId="425506" RespCode="00" Settled="S" Status="A" SystemDate="2012-06-22 15:54:11.00 
+0000" TxnId="38060" TxnType="0" UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem AcquirerId="999674" AmountTransaction="85" 
CardAcceptorId="1234567890ABCDE" CorporateName="Xerox ACS" CpnPan="5550278010237746" CurrencyCodeTransaction="840" Description="AVV match fail" 
EffectOnCpnAmount="0" ExpiryDate="1210" MerchantName="NEETA LOPES ACQ SIM    ST.LOUIS      MO " PurchaseId="425505" RespCode="05" Settled="U" 
Status="A" SystemDate="2012-06-22 15:52:32.00 +0000" TxnId="38058" TxnType="0" UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem 
AcquirerId="999674" AmountTransaction="85" CardAcceptorId="1234567890ABCDE" CorporateName="Xerox ACS" CpnPan="5550278010237746" 
CurrencyCodeTransaction="840" Description="Expiry match fail" EffectOnCpnAmount="0" ExpiryDate="1010" MerchantName="NEETA LOPES ACQ SIM    
ST.LOUIS      MO " PurchaseId="425505" RespCode="05" Settled="U" Status="A" SystemDate="2012-06-22 15:51:41.00 +0000" TxnId="38056" TxnType="0" 
UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem AcquirerId="999674" AmountTransaction="85" CardAcceptorId="1234567890ABCDE" 
CorporateName="Xerox ACS" CpnPan="5550278010237746" CurrencyCodeTransaction="840" Description="Expiry match fail" EffectOnCpnAmount="0" 
ExpiryDate="1010" MerchantName="NEETA LOPES ACQ SIM    ST.LOUIS      MO " PurchaseId="425505" RespCode="05" Settled="U" Status="A" 
SystemDate="2012-06-22 15:51:24.00 +0000" TxnId="38054" TxnType="0" UserName="Xerox-ACS-MTF" VCardAlias="TestRCN1"/><VCNAuthItem AcquirerId="999674" 
AmountTransaction="75" CardAcceptorId="1234567890ABCDE" CorporateName="Xerox ACS" CpnPan="5550276800699984" CurrencyCodeTransaction="840" 
Description="Cumul limit fail" EffectOnCpnAmount="0" ExpiryDate="1210" MerchantName="NEETA LOPES ACQ SIM    ST.LOUIS      MO " PurchaseId="425504" 
RespCode="51" Settled="U" Status="A" SystemDate="2012-06-22 15:45:38.00 +0000" TxnId="38052" TxnType="0" UserName="Xerox-ACS-MTF" 
VCardAlias="TestRCN1"/></Items></GetVCNAuthsByVCardResponse><Session 
SessionId="2591CCD13B3C1EECDBF3E679281E5E518211D76F"/></OrbiscomResponse>'',@vcRAWXMLFilePath=''\\dcespfs1\esp\CITI\DEV\Response\RawXML\RequestID_90_07122012_151122.xml'',@intResponseType_LookupID=3
**********************************************************************/    
    
CREATE PROCEDURE [dbo].[prc_Citi_SetResponseRawData]  
@intRawRequestDataID bigint,
@vcResponse varchar(max),
@vcRAWXMLFilePath varchar(max)
,@intResponseType_LookupID int
AS     

declare @intResponseRawDataID bigint,
		@intHasMore int,
		@intAuthsReportWorkingID bigint,
		@intTransReportWorkingID bigint

set @intHasMore = 0
set @intAuthsReportWorkingID = 0

  insert into CITI_RawResponseData
	(RawData,
	 XMLFilePath,
	 IsProcessed,
	CreatedBy,
	ResponseType_LookupID,
	RawRequestDataID
	)
	VALUES
	(@vcResponse,
	 @vcRAWXMLFilePath,
	 0,
	''prc_Citi_SetResponseRawData'',
	@intResponseType_LookupID,
	@intRawRequestDataID
	)

set @intResponseRawDataID = @@identity

update dbo.CITI_CommunicationRequestResponse
set RawResponseDataID  = @intResponseRawDataID,
	ResponseDateTime = getdate()
where RawRequestDataID = @intRawRequestDataID

if @intResponseType_LookupID = 1 --CreateApprovedPurchaseResponse
	exec prc_CITI_CreateApprovedPurchaseResponse @intResponseRawDataID
else if @intResponseType_LookupID = 2 --ModifyApprovedPurchaseResponse
	exec prc_CITI_ModifyApprovedPurchaseResponse @intResponseRawDataID
else if @intResponseType_LookupID = 3 --VCNAuthsByVCardResponse
	begin
		exec prc_CITI_VCNAuthsByVCardResponse 
				@intResponseRawDataID,
				@intHasMore output,
				@intAuthsReportWorkingID output
		 
		select @intHasMore as HasMoreData,
				@intAuthsReportWorkingID as AuthsReportWorkingID
	end
else if @intResponseType_LookupID = 4 --VCNAuthsByReportIDResponse
	begin
		exec prc_Citi_VCNAuthsByReportIDResponse @intResponseRawDataID,
				@intHasMore output,
				@intAuthsReportWorkingID output

		select @intHasMore as HasMoreData,
				@intAuthsReportWorkingID as AuthsReportWorkingID
	end
else if @intResponseType_LookupID = 5 --VCNTransByVCardResponse
	begin
		exec prc_CITI_VCNTransByVCardResponse 
				@intResponseRawDataID,
				@intHasMore output,
				@intTransReportWorkingID output
		 
		select @intHasMore as HasMoreData,
				@intTransReportWorkingID as TransReportWorkingID
	end
else if @intResponseType_LookupID = 6 --VCNTransByReportIDResponse
	begin
		exec prc_Citi_VCNTransByReportIDResponse @intResponseRawDataID,
				@intHasMore output,
				@intTransReportWorkingID output

		select @intHasMore as HasMoreData,
				@intTransReportWorkingID as TransReportWorkingID
	end



' 
END
GO
