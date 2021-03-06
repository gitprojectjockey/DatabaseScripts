/****** Object:  StoredProcedure [dbo].[prc_Citi_XMLCreateApprovedPurchaseRequest]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Citi_XMLCreateApprovedPurchaseRequest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Citi_XMLCreateApprovedPurchaseRequest]
GO
/****** Object:  StoredProcedure [dbo].[prc_Citi_XMLCreateApprovedPurchaseRequest]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Citi_XMLCreateApprovedPurchaseRequest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'      
/*******************************************************************      
* PROCEDURE: prc_Citi_XMLCreateApprovedPurchaseRequest  
* Purpose : This PROC would be invoked from Citi Console app CITI_CreateApprovedPurchaseRequest.sln
                      
* CREATED:  Ajay Thacker on 16may2012  
* MODIFICATION HISTORY      
* DATE  AUTHOR   DESCRIPTION      
**********************************************************************      
 20Nov2012	Ajay	Updated proc for dbr2289 (read DefaultTransCount from papers table for maxtrans.
												If that value is null, then default to 4trans)
23JUN2014	Mohan	Changes the tabled references based on clientwise application
**********************************************************************      

grant execute on prc_Citi_XMLCreateApprovedPurchaseRequest to  citiadmin  
  
  
   --max trans from papers   
      select  * from COMDATACommunicationControl
where ProcessedDate is null
update COMDATACommunicationControl
set ProcessedDate = null,retries = 0 where id = 841429
  
**********************************************************************      
exec prc_Citi_XMLCreateApprovedPurchaseRequest  
**********************************************************************/      
      
CREATE PROCEDURE [dbo].[prc_Citi_XMLCreateApprovedPurchaseRequest]    
  
AS      
  
--DECLARE VARIABLES  
declare  
@vcCITIIssuerID varchar(50),
@vcCITIVCardAlias varchar(50),
@vcCITIVersion varchar(50),
 @cur_intComdataCommunicationControlID bigint,  
 @cur_intSettlementID bigint,  
 @cur_numCCLimit numeric(9,2),  
 @cur_vcMMRPO varchar(50),  
 @cur_vcPaperCode VARCHAR(5),  
 @cur_vcPaperName varchar(30),  
 @cur_vcClassification varchar(10),  
 @cur_vcWeekending varchar(10),
 @vcXMLHeader varchar(1000),  
 @vcValidFrom varchar(30),  
 @vcValidTo varchar(30),  
 @dtValidTo datetime,
 @vcCreateApprovedPurchaseRequest varchar(max)  ,
@intRawRequestDataID bigint,
@vcMaxTrans varchar(2),
@cur_vcTransCount varchar(2)


set @vcCITIIssuerID = (SELECT lookupValue from CITI_Lookup		
					where LookupName =''CITI_IssuerID'')
set @vcCITIVCardAlias = (SELECT lookupValue from CITI_Lookup		
					where LookupName =''CITI_VCardAlias'')
set @vcCITIVersion = (SELECT lookupValue from CITI_Lookup		
					where LookupName =''CITI_Version'')
set @vcMaxTrans = ''4''

create table #tempCommunicationControlBridge
(ComDataCommunicationControlID bigint)
  
--ASSIGNED XML HEADER, AND VALIDFROM, VALIDTO VALUES  
set @vcXMLHeader = ''<?xml version="1.0" encoding="UTF-8" ?><OrbiscomRequest IssuerId="'' + @vcCITIIssuerID + ''" Version="'' + @vcCITIVersion + ''">'' 
+ ''<XMLAuthenticateRequest></XMLAuthenticateRequest>''  
set @vcValidFrom =  replace(convert(varchar(20),getdate(),102),''.'',''-'') + '' 00:00:00.0 +0000''  
set @dtValidTo =   dateadd(mm,4,getdate()) --add 4 months
set @dtValidTo = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@dtValidTo)+1,0)) --get the end of month date
set @vcValidTo =  replace(convert(varchar(20),@dtValidTo,102),''.'',''-'') + '' 11:59:00.0 +0000'' 

set @vcCreateApprovedPurchaseRequest = ''''  
  
--Step 1 - Create cursor for card requests  


declare curCiti cursor for  
 SELECT top 1 comm.ID,comm.SettlementID,comm.ccLimit,  
  JMB.MMRPO,V.VendorCode papercode,v.VendorName [name],LC.LookupName classificationname ,convert(varchar(10),J.InvoiceDate,101),
  case when V.DefaultTransCount is null then @vcMaxTrans else convert(varchar(2),V.DefaultTransCount) end
  
 from COMDATACommunicationControl comm  
  inner JOIN CWI_JobMediaBuy JMB  
  ON JMB.ID = comm.SettlementID  
  inner JOIN CWI_Vendor V  
  ON V.Id = JMB.VendorId
  INNER JOIN CWI_Job J
	ON J.Id = JMB.JobId
  inner join Lookup LC
  ON J.ClassificationId = LC.ID  
    
 where ComDataTemplateID = 1 --Purchase Request  
 and processedDate is NULL  
 and Retries < 5 


  
  
open Curciti  
Fetch from curciti into @cur_intComdataCommunicationControlID,@cur_intSettlementID,  
      @cur_numCCLimit,@cur_vcMMRPO,@cur_vcPaperCode,@cur_vcPaperName,  
      @cur_vcClassification  ,@cur_vcWeekending,@cur_vcTransCount
while @@fetch_Status = 0  
begin  
  --Setting the CreateApprovedPurchaseRequest element with attributes  
  set @vcCreateApprovedPurchaseRequest = @vcCreateApprovedPurchaseRequest +  
   ''<CreateApprovedPurchaseRequest Amount="'' + convert(varchar(10),@cur_numCCLimit)  
   + ''" Comment="Purchase Request for SettlementID '' + convert(varchar(30),@cur_intSettlementID)  
   + ''" CurrencyCode="840" PurchaseType="Xerox ACS Purchase"  
    SupplierName="Xerox ACS Supplier"  
    VCardAlias="'' + @vcCITIVCardAlias + ''"   
    ValidFor="4M" CurrencyType="B" ''
    -- + ''RequestId="'' + + convert(varchar(10),@cur_intSettlementID) + ''">''  
	+ ''RequestId="'' + + convert(varchar(30),@cur_intComdataCommunicationControlID) + ''">''  


set @vcCreateApprovedPurchaseRequest = @vcCreateApprovedPurchaseRequest +  
  ''<CDFs>  
     <CDF FieldName="MMRPO" FieldValue="'' + @cur_vcMMRPO + ''" />   
     <CDF FieldName="VENDORID" FieldValue="'' + @cur_vcPaperCode + ''" />   
     <CDF FieldName="VENDORNAME" FieldValue="'' + replace(@cur_vcPaperName,''&'','' '') + ''" />   
     <CDF FieldName="CLASSIFICATION" FieldValue="'' + @cur_vcClassification +''" />   
	<CDF FieldName="WEEKENDINGDATE" FieldValue="'' + @cur_vcWeekending +''" />   
  </CDFs>''    




  --Adding ALSRules with Velocity Control  
  set @vcCreateApprovedPurchaseRequest = @vcCreateApprovedPurchaseRequest +  
   ''<ALSRules><Rule Action="A" Alias="VC">  
    <Controls><OPMCCControl /> <OPMIDControl />   
     <VelocityControl CumulativeLimit="'' +  convert(varchar(10),@cur_numCCLimit)   
    + ''" MaxTrans="'' + @cur_vcTransCount + ''" Period="C" />   
    <ValidityPeriod ValidFrom="'' + @vcValidFrom +''" ValidTo="'' + @vcValidTo + ''" />   
   </Controls></Rule></ALSRules></CreateApprovedPurchaseRequest>''  
  
	insert into #tempCommunicationControlBridge
	VALUES(@cur_intComdataCommunicationControlID)


	update comdatacommunicationcontrol
	set TransCount = @cur_vcTransCount
	where ID = @cur_intComdataCommunicationControlID
  
  Fetch next from curciti into @cur_intComdataCommunicationControlID,@cur_intSettlementID,  
      @cur_numCCLimit,@cur_vcMMRPO,@cur_vcPaperCode,@cur_vcPaperName,  
      @cur_vcClassification  ,@cur_vcWeekending,@cur_vcTransCount
end  
  
close curciti  
deallocate curciti  

		  
if len(@vcCreateApprovedPurchaseRequest) > 0  
begin
 
 Insert into CITI_RawRequestData
	(RawData,RequestType_LookupID,CreatedBy)
 Select @vcXMLHeader + @vcCreateApprovedPurchaseRequest + ''</OrbiscomRequest>'',
		1,--1 = CreateApprovedPurchaseRequest
		''prc_Citi_XMLCreateApprovedPurchaseRequest''

 set @intRawRequestDataID = @@identity

 insert into CITI_CommunicationRequestResponse
	(COMDATACommunicationControlID,RawRequestDataID,Createdby)
 select COMDATACommunicationControlID,@intRawRequestDataID,''prc_Citi_XMLCreateApprovedPurchaseRequest''
 from #tempCommunicationControlBridge
	

  Select @vcXMLHeader + @vcCreateApprovedPurchaseRequest + ''</OrbiscomRequest>'' as XMLDBData,
		 @intRawRequestDataID as RawRequestDataID  
 

END

' 
END
GO
