/****** Object:  StoredProcedure [dbo].[prc_CWI_GetRelatedSettlements]    Script Date: 3/17/2014 2:00:10 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetRelatedSettlements]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetRelatedSettlements]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetRelatedSettlements]    Script Date: 3/17/2014 2:00:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetRelatedSettlements]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************  
* PROCEDURE: prc_CWI_GetRelatedSettlements  
* Purpose : This PROC would be called TO get all the Settelements for the vendor id
* Invoked from : Settelement.aspx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
--exec prc_CWI_GetRelatedSettlements '''',14163
--exec prc_CWI_GetRelatedSettlements 5962,''''
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetRelatedSettlements] 
	@VendorID INT=Null,
	@DivisionID INT =null
AS
BEGIN


DECLARE @tblRelated TABLE (Id int)
DECLARE @dtInvoiceDate datetime
	SET @dtInvoiceDate = (SELECT MIN(InvoiceDate) FROM CWI_Job J
								INNER JOIN CWI_JobMediaBuy MB 
								ON MB.JobId=J.ID  
								WHERE InvoiceId IS NULL
								AND ISNULL(MB.IsCancelled,0) = 0 
								AND ISNULL(MB.DNR,0) = 0
								AND ISNULL(J.IsQuote,0) = 0
								AND J.IsCancelled=0
								AND ISNULL(MB.IsRemoved,0) = 0 AND J.[JobStatusLookupId] NOT IN (8004,8006,8007,8008,8009,8010))
	
	--PRINT @dtInvoiceDate

IF( ISNull(@VendorID,0)>0 )
BEGIN

INSERT INTO @tblRelated

SELECT distinct VendorId FROM CWI_VendorContact VC1
INNER JOIN 
(
SELECT Email, PhoneWork FROM CWI_VendorContact
WHERE 
	VendorId = @VendorID 
	AND ISNULL(EMail,'''') <>''''
	AND ISNULL(PhoneWork,'''') <>''''
	) VC2
	ON VC1.Email= VC2.Email OR VC1.PhoneWork = VC2.PhoneWork
UNION
SELECT @VendorId

	
SELECT       
		JMB.MMRPO,
		C.ID as DivisionId,
		V.Id as VendorId,
		J.IsQuote,
		V.VendorCode,
		V.VendorName,
		C.ClientCode DivisionCode,
		C.ClientName DivisionName,
		J.InvoiceDate,
		(Select Min(Convert(datetime,fieldvalue))  FROM fnc_CWI_GetJobMediabuyRundates(J.ID, NULL)) as FirstRundate	
		
FROM CWI_JobMediaBuy JMB
INNER JOIN CWI_Job J ON J.ID=JMB.JobId  
INNER JOIN CWI_Vendor V ON V.ID=JMB.VendorId
INNER JOIN @tblRelated RV
	ON RV.Id = JMB.VendorId
INNER JOIN CWI_Client C ON C.ID=J.DivisionId

 WHERE  JMB.IsRemoved=0 AND JMB.IsCancelled=0 AND JMB.DNR=0 AND ISNULL(JMB.MMRPO,0)!=0
	AND J.IsQuote = 0 AND J.IsCancelled = 0
	AND JMB.IsComplimentaryInvoice = 0
	AND ISNULL(JMB.ActualInvoice,0) <=0
	AND J.InvoiceDate>=@dtInvoiceDate
	
 

END
else 
IF( ISNull(@DivisionID,0)>0  )
BEGIN


INSERT INTO @tblRelated

SELECT distinct ClientId FROM CWI_ClientContact VC1
INNER JOIN 
(
SELECT Email, PhoneWork FROM CWI_ClientContact
WHERE 
	ClientId = @DivisionID 
	AND ISNULL(EMail,'''') <>''''
	AND ISNULL(PhoneWork,'''') <>''''
	) VC2
	ON VC1.Email= VC2.Email OR VC1.PhoneWork = VC2.PhoneWork
UNION
SELECT @DivisionID

	


SELECT       
		JMB.MMRPO,
		C.ID as DivisionId,
		V.Id as VendorId,
		J.IsQuote,
		V.VendorCode,
		V.VendorName,
		C.ClientCode DivisionCode,
		C.ClientName DivisionName,
		J.InvoiceDate,
		(Select Min(Convert(datetime,fieldvalue))  FROM fnc_CWI_GetJobMediabuyRundates(J.ID, NULL)) as FirstRundate	
		
FROM CWI_JobMediaBuy JMB
INNER JOIN CWI_Job J ON J.ID=JMB.JobId  
INNER JOIN CWI_Vendor V ON V.ID=JMB.VendorId
INNER JOIN CWI_Client C ON C.ID=J.DivisionId
INNER JOIN @tblRelated RV
	ON RV.Id = J.DivisionId


 WHERE  JMB.IsRemoved=0 AND JMB.IsCancelled=0 AND JMB.DNR=0 AND ISNULL(JMB.MMRPO,0)!=0
	AND J.IsQuote = 0 AND J.IsCancelled = 0
	AND JMB.IsComplimentaryInvoice = 0
	AND ISNULL(JMB.ActualInvoice,0) <=0
	AND J.InvoiceDate>=@dtInvoiceDate

END



END




' 
END
GO
