/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCDetailTransaction]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCDetailTransaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVCDetailTransaction]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCDetailTransaction]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCDetailTransaction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetVCDetailTransaction]  
* Purpose : This PROC would be called to virtaul card transaction details. 
			This is equivalent of stored proc TMIMMRDB..VCM_GetVirtualCardTransactions
* Invoked from : ManageVirtualCard.aspx
* CREATED: Mohankumar 06JUN14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetVCDetailTransaction] @mediabuyId  = 1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetVCDetailTransaction] 
	@mediabuyId bigint 
AS
BEGIN

	BEGIN TRY
		
Select distinct      
 dateadd(hour,1,cdc.Created) as [Transaction],     
 cdt.Name as [Name],     
 scd.CCNumber as [CCnumber],     
 cdc.CCLimit as CCLimit,     
 CONVERT(varchar(20),    
 dateadd(hh,1,cdc.ProcessedDate),20) as [ProcessDate],     
 cdc.ResponseMessage as [Message],     
 cdc.Created as CreatedDate     
From     
 ComDataCommunicationControl cdc     
Inner Join      
 ComDataTemplate cdt     
on      
 cdc.ComDataTemplateID = cdt.ID     
Inner Join      
 CWI_JobMediaBuy s     
on     
 s.ID = cdc.SettlementID     
LEFT Join     
 SettlementComDataCCNumber scd     
on      
 s.ID = scd.SettlementID     
Where     
 s.ID = @mediabuyId     
Union      
    
Select      
 convert(varchar(10),cdr.PostedDate,110) + '' '' + convert(varchar(8),cdr.PostedTime,108) as [Transaction],     
 ''Reconciliation'' as [Name],     
 scd.CCNumber as [CCnumber],     
 TotalAmountDue as CCLimit,     
 convert(varchar(10),cdr.PostedDate,110) + convert(varchar(8),cdr.PostedTime,108) as [ProcessDate],     
 cdr.Result as [Message],     
 cdr.CreatedDateTime as CreatedDate     
From      
 CWI_JobMediaBuy s   
Left Join     
 SettlementComDataCCNumber scd     
on     
 s.ID = scd.SettlementID      
left Join      
 ComDataReconcile cdr     
on      
 convert(varchar(25),scd.CCNumber) = cdr.CardNo     
Where     
 ISCredit = ''D''     
and     
 s.ID = @mediabuyId    
    
Union      
    
Select     
 convert(varchar(10),cdr.PostedDate,110) + '' '' +  convert(varchar(8),cdr.PostedTime,108) as [Transaction],    
 ''Reconciliation'' as [Name],     
 scd.CCNumber as [CCnumber],     
 TotalAmountDue * -1 as CCLimit,     
 convert(varchar(10),cdr.PostedDate,110) + convert(varchar(8),cdr.PostedTime,108) as [ProcessDate],     
 cdr.Result as [Message],     
 cdr.CreatedDateTime as CreatedDate     
From      
 CWI_JobMediaBuy s   
Left Join     
 SettlementComDataCCNumber scd     
on     
 s.ID = scd.SettlementID      
left Join      
 ComDataReconcile cdr     
on      
 convert(varchar(25),scd.CCNumber) = cdr.CardNo     
Where     
 s.Id = @mediabuyId and cdr.IsCredit = ''C''    
    
-- CardNo = (Select distinct CardNo from ComDataReconcile Where VirtualCardVendorNo = @MMRPO)     
-- and isCredit = ''C''    
    
Union     
    
Select     

 convert(varchar(10),cdt.TransactionDate,110) + '' '' +  convert(varchar(8),cdt.TransactionTime,108) as [Transaction],     
 ''Transaction'' as [Name],     
 cdt.CardNo as [CCNumber],     
 cdt.PreAuthAmt as CCLimit,     
 convert(varchar(10),cdt.PostedDate,110) + convert(varchar(8),cdt.PostedTime,108) as [ProcessDate],     
 [Message] =     
 case     
  when cdt.ApprovalNumber = 0 then cdt.ErrDescription     
  when cdt.ApprovalNumber > 0 then ''Approval Number : '' + convert(varchar(20),cdt.ApprovalNumber)     
 End ,     
 cdt.CreatedDateTime as CreatedDate     
from     
 ComDataTransaction cdt     
inner Join     
 SettlementComDataCCNumber scd     
on     
 cdt.CardNo = scd.CCNumber     
inner join     
 CWI_JobMediaBuy s     
on     
 scd.SettlementID = s.ID     
Where     
 s.Id = @mediabuyId      
ORDER BY [Transaction]    
    
      
    



	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END


' 
END
GO
