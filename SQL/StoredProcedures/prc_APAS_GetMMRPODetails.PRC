/****** Object:  StoredProcedure [dbo].[prc_APAS_GetMMRPODetails]    Script Date: 8/19/2014 3:16:04 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetMMRPODetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_GetMMRPODetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_GetMMRPODetails]    Script Date: 8/19/2014 3:16:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetMMRPODetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_APAS_GetMMRPODetails   
* Purpose : This PROC would be called TO 
* Invoked from : PaperCostWizard.aspx
* CREATED: MohanKumar Sundaram 31JUL14
* MODIFICATION HIST
ORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_APAS_GetMMRPOD
etails @MMRPO = 277
  
**********************************************************************/ 
--prc_CWI_APAS_GetMMRPODetails 821
CREATE PROC [dbo].[prc_APAS_GetMMRPODetails]
	@mediaBuyId bigint
AS

Select 
	JMB.Id,  
	JMB.MMRPO,
	p.VendorCode , 
	p.VendorName ,  
	JMB.JobId ,
	o.IsQuote ,  
	JMB.PayMethodLookupId Paycode,
	JMB.ActualCost CalcNetCost, 
	dbo.fnc_CWI_GetJobMediabuyRundatesScalar(default,JMB.Id) Rundates, 
	c.ClientCode Clicode,  
	AgencyDisc=isnull(p.AgencyDisc,''0''),  
	c.ClientName,
	ISNULL((	
	SELECT top 1   ISNULL(t.LookupValue,t.FieldValue) FROM dbo.fnc_GetJobSummaryTemplateDataWithLookup(JMB.JobId) t
		where t.MappingFieldId = 20209),'''') Classification,  
	p.AccountRefID ,
	JMB.QuotedCost,
	JMB.QuotedDate,
	ISNULL(JN.AdCopyFileName,'''') AdCopyFileName,
	ISNULL(JMB.IsActualCostFreeze,0) AS IsActualCostFreeze,
	CASE WHEN O.IsCancelled=1 OR JMB.IsCancelled=1 THEN 704 /*Cancellation */ 
		WHEN O.IsQuote =1 THEN 703 /*Quote*/
		WHEN O.IsChangeOrder=1 THEN 709 /* Change Order */
		ELSE  701 /* Insertion Order */
		END CorresType,
	UJC.Names AE,
	UJC.Email AEEmail,
	dbo.fnc_GetUsersEmailsForClientScalar(O.DivisionId,''A'') ccEmail,
	O.InvoiceId,
	JMB.IsCancelled,
	JMB.DNR
   
 from   
	CWI_JobMediaBuy JMB 
	inner join  CWI_Vendor p  
		on  JMB.VendorId = p.Id  
	inner join  CWI_Job O  
		on  O.Id = JMB.JobId  
	inner join CWI_User UJC
		ON UJC.Id = O.CreatedBy
	inner join  CWI_Client c  
		on  c.ID = O.DivisionId  
	  LEFT OUTER JOIN CWI_JobNewspaper JN
		ON JN.JobId = O.Id

 where  
	JMB.Id= @mediaBuyId
  










' 
END
GO


