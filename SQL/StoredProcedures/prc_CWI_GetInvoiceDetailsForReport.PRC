/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceDetailsForReport]    Script Date: 3/15/2014 9:41:00 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceDetailsForReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceDetailsForReport]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceDetailsForReport]    Script Date: 3/15/2014 9:41:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceDetailsForReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceDetailsForReport 
* Purpose : This PROC would be called TO get all the invoice details to generate the report
* Invoked from : ClientwiseInvoiceService
* CREATED: MohanKumar Sundaram  03/04/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  30Oct14	Vijesh			Included AddressLine2,Service Name from Service table          

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetInvoiceDetailsForReport
	@ClientId = 16760,
	@InvoiceDate = ''2014-11-02'',
	@IsConsolidated  = null,
	@InvoiceType  = null
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetInvoiceDetailsForReport]
	@InvoiceId bigint = NULL,
	@ClientId int = NULL,
	@InvoiceDate Datetime = NULL,
	@IsConsolidated bit = null,
	@InvoiceType int = null

AS
	SET NOCOUNT ON
	IF @InvoiceId IS NOT NULL
	BEGIN
		SELECT *,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN VendorName + '' / ''+ VendorState
			WHEN ClassificationId = 405 /*Television*/ THEN ''Not Applicable'' 
			ELSE VendorState END DisplayClass,

	    CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorName + '' / ''+ VendorState +'' / ''+ VendorCity			
			ELSE VendorName END DisplayPO,
						
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorName + '' / ''+ VendorState +'' / ''+ VendorCity			
			ELSE ''Not Applicable / Not Applicable / Not Applicable'' END DisplayConsolidated,

		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''Service Name''
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN ''Vendor / State''
			ELSE ''State'' END DisplayClassHeader,
		CASE 
			WHEN ClassificationId IN ( 0 /*Service*/, 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN ''Vendor / State / City''
			ELSE ''Publication Name'' END DisplayPOHeader,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''Service Name''			
			ELSE ''Vendor / State / City'' END DisplayConsolidatedHeader,

		CASE  
			WHEN ClassificationId IN ( 0 /*Service*/, 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorCity
			WHEN ClassificationId = 405 /*Television*/ THEN ''Not Applicable'' 
			ELSE VendorName END DisplayClass2,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''''
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN ''City''
			ELSE ''Name'' END DisplayClassHeader2
		


		FROM
		(
		SELECT *
		 FROM
		(
		SELECT  TOP 100 PERCENT
		J.Id JobNo,
		I.InvoiceNo,
		CASE WHEN I.InvoiceNo IS NOT NULL THEN ''A''+CONVERT(VARCHAR,I.InvoiceNo) 
		ELSE CONVERT(VARCHAR,I.InvoiceNo) END AS AdvtInvoiceNo,
		I.InvoiceDate,
		JMB.ActualInvoice,
		J.PONumber,
		dbo.fnc_CWI_GetJobMediabuyRundatesScalar(J.id, JMB.Id) Rundates,
		dbo.fnc_CWI_GetJobAdType(J.Id) AdType,
		V.VendorName,
		V.Physical_City VendorCity,
		V.Physical_StateName VendorState,
		C.ClientCode ClientCode,
		C.ClientName ClientName,
		D.ClientCode DivisionCode,
		D.ClientName DivisionName,
		CASE WHEN IsConsolidated = 1 THEN CA.AddressLine1 ELSE DA.AddressLine1 END  AddressLine1,
		CASE WHEN IsConsolidated = 1 THEN ISNULL(CA.AddressLine2,'''') 
			ELSE ISNULL(DA.AddressLine2,'''') END  AddressLine2,
		CASE WHEN IsConsolidated = 1 THEN CA.City ELSE DA.City END  City,
		CASE WHEN IsConsolidated = 1 THEN CA.StateCode ELSE DA.StateCode END  StateCode,
		CASE WHEN IsConsolidated = 1 THEN CA.StateName ELSE DA.StateName END  StateName,
		CASE WHEN IsConsolidated = 1 THEN CA.Zip ELSE DA.Zip END  Zip,
		J.AdDescription,
		CASE WHEN --JMB.IsComplimentary = 1 OR 
		JMB.IsComplimentaryInvoice = 1 THEN 1 ELSE 0 END IsCompliment,
		LC.LookupName Classification,
		I.IsConsolidated,
		I.InvoiceTypeLookupId,
		J.DivisionId,
		J.ClassificationId

	FROM CWI_Invoice I
		INNER JOIN  CWI_Job J
			ON I.Id = J.InvoiceId
		INNER JOIN  Lookup LC
			ON LC.Id = J.ClassificationId
		INNER JOIN CWI_JobMediaBuy JMB
			ON J.Id = JMB.JobId
		INNER JOIN  vw_CWI_VendorAddress V 
			ON V.VendorId = JMB.VendorId
		INNER JOIN  CWI_Client C
			ON C.ID = I.ClientId
		INNER JOIN CWI_Client D
			ON J.DivisionId = D.Id
		INNER JOIN  vw_CWI_Address CA
			ON CA.ID = C.AddressID
		INNER JOIN  vw_CWI_Address DA
			ON DA.ID = D.AddressID
	WHERE
		I.Id = @InvoiceId
		AND JMB.IsCancelled =0 
		AND JMB.IsRemoved = 0
		AND JMB.DNR = 0
	ORDER BY              
		V.VendorName,C.ClientCode,LC.LookupName,CA.StateName,V.Physical_City
	) x
	UNION ALL
	SELECT 
		J.Id JobNo,
		I.InvoiceNo,
		CASE WHEN I.InvoiceNo IS NOT NULL THEN ''A''+CONVERT(VARCHAR,I.InvoiceNo) 
		ELSE CONVERT(VARCHAR,I.InvoiceNo) END AS AdvtInvoiceNo,
		I.InvoiceDate,
		JMB.ServiceFee ActualInvoice,
		J.PONumber,
		dbo.fnc_CWI_GetJobMediabuyRundatesScalar(J.id, JMB.Id) Rundates,
		dbo.fnc_CWI_GetJobAdType(J.Id) AdType,
		ISNULL(SR.ServiceName, ''Other'') AS VendorName,
		'''' VendorCity,
		'''' VendorState,
		C.ClientCode ClientCode,
		C.ClientName ClientName,
		D.ClientCode DivisionCode,
		D.ClientName DivisionName,
		CASE WHEN IsConsolidated = 1 THEN CA.AddressLine1 ELSE DA.AddressLine1 END  AddressLine1,
		CASE WHEN IsConsolidated = 1 THEN ISNULL(CA.AddressLine2,'''') 
			ELSE ISNULL(DA.AddressLine2,'''') END  AddressLine2,
		CASE WHEN IsConsolidated = 1 THEN CA.City ELSE DA.City END  City,
		CASE WHEN IsConsolidated = 1 THEN CA.StateCode ELSE DA.StateCode END  StateCode,
		CASE WHEN IsConsolidated = 1 THEN CA.StateName ELSE DA.StateName END  StateName,
		CASE WHEN IsConsolidated = 1 THEN CA.Zip ELSE DA.Zip END  Zip,
		JMB.ServiceDescription AS AdDescription,
		CASE WHEN JMB.IsComplimentary = 1 THEN 1 ELSE 0 END IsCompliment,
		''Service''  Classification,
		I.IsConsolidated,
		I.InvoiceTypeLookupId,
	
		J.DivisionId,
		0

	FROM CWI_Invoice I
		INNER JOIN  CWI_Job J
			ON I.Id = J.InvoiceId
		INNER JOIN  Lookup LC
			ON LC.Id = J.ClassificationId
		INNER JOIN CWI_JobService JMB
			ON J.Id = JMB.JobId
		INNER JOIN  CWI_Client C
			ON C.ID = I.ClientId
		INNER JOIN CWI_Client D
			ON J.DivisionId = D.Id
		INNER JOIN  vw_CWI_Address CA
			ON CA.ID = C.AddressID
		INNER JOIN  vw_CWI_Address DA
			ON DA.ID = D.AddressID
		LEFT OUTER JOIN CWI_Service SR 
			ON JMB.ServiceId=SR.Id

	WHERE
		I.Id = @InvoiceId
		AND JMB.IsDeleted =0 
		) z

	return
	END

	
	IF ISNULL(@IsConsolidated,0) =0 AND @InvoiceType IS  NULL
	BEGIN
		DECLARE @InvClientId int = NULL,
				@InvConsolidated bit = NULL,
				@InvType int = NULL


		SELECT 
			@InvClientId = ClientId,
			@InvConsolidated = IsConsolidated,
			@InvType = InvoiceTypeLookupId
		FROM 
			vw_CWI_ClientDivisionInvoice
		WHERE
			ClientDivId = @ClientId

		DECLARE @tblClientDiv TABLE
		(
			ClientDivId int
		)

		IF @InvConsolidated = 1
		begin
			INSERT INTO @tblClientDiv
			SELECT Id FROM CWI_Client WHERE ParentId = @ClientId
		end
		ELSE
		begin
			INSERT INTO @tblClientDiv
			SELECT @ClientId
		end
		
		SELECT *,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN VendorName + '' / ''+ VendorState
			WHEN ClassificationId = 405 /*Television*/ THEN ''Not Applicable'' 
			ELSE VendorState END DisplayClass,

	    CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorName + '' / ''+ VendorState +'' / ''+ VendorCity			
			ELSE VendorName END DisplayPO,
						
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorName + '' / ''+ VendorState +'' / ''+ VendorCity			
			ELSE ''Not Applicable / Not Applicable / Not Applicable'' END DisplayConsolidated,

		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''Service Name''
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN ''Vendor / State''
			ELSE ''State'' END DisplayClassHeader,
		CASE 
			WHEN ClassificationId IN ( 0 /*Service*/, 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN ''Vendor / State / City''
			ELSE ''Publication Name'' END DisplayPOHeader,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''Service Name''			
			ELSE ''Vendor / State / City'' END DisplayConsolidatedHeader,

		CASE  
			WHEN ClassificationId IN ( 0 /*Service*/, 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorCity
			WHEN ClassificationId = 405 /*Television*/ THEN ''Not Applicable'' 
			ELSE VendorName END DisplayClass2,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''''
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN ''City''
			ELSE ''Name'' END DisplayClassHeader2

		FROM
		(
		SELECT * FROM
		(
		SELECT  TOP 100 PERCENT
			J.Id JobNo,
			NULL InvoiceNo,
			NULL AdvtInvoiceNo,
			J.InvoiceDate,
			JMB.ActualInvoice,
			J.PONumber,
			dbo.fnc_CWI_GetJobMediabuyRundatesScalar(J.id, JMB.Id) Rundates,
			dbo.fnc_CWI_GetJobAdType(J.Id) AdType,
			V.VendorName,
			V.Physical_City VendorCity,
			V.Physical_StateName VendorState,
			C.ClientCode ClientCode,
			C.ClientName ClientName,
			D.ClientCode DivisionCode,
			D.ClientName DivisionName,
			CASE WHEN @InvConsolidated = 1 THEN CA.AddressLine1 ELSE DA.AddressLine1 END  AddressLine1,
			CASE WHEN @InvConsolidated = 1 THEN ISNULL(CA.AddressLine2,'''') 
				ELSE ISNULL(DA.AddressLine2,'''') END  AddressLine2,
			CASE WHEN @InvConsolidated = 1 THEN CA.City ELSE DA.City END  City,
			CASE WHEN @InvConsolidated = 1 THEN CA.StateCode ELSE DA.StateCode END  StateCode,
			CASE WHEN @InvConsolidated = 1 THEN CA.StateName ELSE DA.StateName END  StateName,
			CASE WHEN @InvConsolidated = 1 THEN CA.Zip ELSE DA.Zip END  Zip,

			J.AdDescription,
			CASE WHEN --JMB.IsComplimentary = 1 OR 
			JMB.IsComplimentaryInvoice = 1 THEN 1 ELSE 0 END IsCompliment,
			LC.LookupName Classification,
			@InvConsolidated IsConsolidated,
			@InvType InvoiceTypeLookupId,

			J.DivisionId,
		J.ClassificationId

		FROM 
			 CWI_Job J
			INNER JOIN  Lookup LC
				ON LC.Id = J.ClassificationId
			INNER JOIN CWI_JobMediaBuy JMB
				ON J.Id = JMB.JobId
			INNER JOIN  vw_CWI_VendorAddress V 
				ON V.VendorId = JMB.VendorId
			INNER JOIN CWI_Client D
				ON J.DivisionId = D.Id
			INNER JOIN  CWI_Client C
				ON C.ID = D.ParentID
			INNER JOIN  vw_CWI_Address CA
				ON CA.ID = C.AddressID
			INNER JOIN  vw_CWI_Address DA
				ON DA.ID = D.AddressID
			INNER JOIN  @tblClientDiv t
				ON t.ClientDivId = J.DivisionId
		WHERE
			 J.IsQuote =0              
			AND J.IsCancelled =0              
			AND JMB.IsCancelled =0 
			AND JMB.IsRemoved = 0
			AND JMB.DNR = 0
			AND J.InvoiceDate = @InvoiceDate
			

		ORDER BY              
			V.VendorName,C.ClientCode,LC.LookupName,CA.StateName,V.Physical_City
		) x
		UNION ALL
		SELECT  TOP 100 PERCENT
			J.Id JobNo,
			NULL InvoiceNo,
			NULL AdvtInvoiceNo,
			J.InvoiceDate,
			JMB.ServiceFee ActualInvoice,
			J.PONumber,
			dbo.fnc_CWI_GetJobMediabuyRundatesScalar(J.id, JMB.Id) Rundates,
			dbo.fnc_CWI_GetJobAdType(J.Id) AdType,			
			ISNULL(SR.ServiceName, ''Other'') AS VendorName, 
			'''' VendorCity,
			'''' VendorState,
			C.ClientCode ClientCode,
			C.ClientName ClientName,
			D.ClientCode DivisionCode,
			D.ClientName DivisionName,
			CASE WHEN @InvConsolidated = 1 THEN CA.AddressLine1 ELSE DA.AddressLine1 END  AddressLine1,
			CASE WHEN @InvConsolidated = 1 THEN ISNULL(CA.AddressLine2,'''') 
				ELSE ISNULL(DA.AddressLine2,'''') END  AddressLine2,
			CASE WHEN @InvConsolidated = 1 THEN CA.City ELSE DA.City END  City,
			CASE WHEN @InvConsolidated = 1 THEN CA.StateCode ELSE DA.StateCode END  StateCode,
			CASE WHEN @InvConsolidated = 1 THEN CA.StateName ELSE DA.StateName END  StateName,
			CASE WHEN @InvConsolidated = 1 THEN CA.Zip ELSE DA.Zip END  Zip,
			JMB.ServiceDescription AS AdDescription,
			CASE WHEN JMB.IsComplimentary = 1  THEN 1 ELSE 0 END IsCompliment,
			''Service'' Classification,
			@InvConsolidated IsConsolidated,
			@InvType InvoiceTypeLookupId,

			J.DivisionId,0

		FROM 
			 CWI_Job J
			INNER JOIN  Lookup LC
				ON LC.Id = J.ClassificationId
			INNER JOIN CWI_JobService JMB
				ON J.Id = JMB.JobId
			
			INNER JOIN CWI_Client D
				ON J.DivisionId = D.Id
			INNER JOIN  CWI_Client C
				ON C.ID = D.ParentID
			INNER JOIN  vw_CWI_Address CA
				ON CA.ID = C.AddressID
			INNER JOIN  vw_CWI_Address DA
				ON DA.ID = D.AddressID
			INNER JOIN  @tblClientDiv t
				ON t.ClientDivId = J.DivisionId
			LEFT OUTER JOIN CWI_Service SR 
				ON JMB.ServiceId=SR.Id
		WHERE
			 J.IsQuote =0              
			AND J.IsCancelled =0              
			AND JMB.IsDeleted =0 

			AND J.InvoiceDate = @InvoiceDate
		) z

		RETURN
	END

	SELECT *,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN VendorName + '' / ''+ VendorState
			WHEN ClassificationId = 405 /*Television*/ THEN ''Not Applicable'' 
			ELSE VendorState END DisplayClass,

	    CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorName + '' / ''+ VendorState +'' / ''+ VendorCity			
			ELSE VendorName END DisplayPO,
						
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN VendorName
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorName + '' / ''+ VendorState +'' / ''+ VendorCity			
			ELSE ''Not Applicable / Not Applicable / Not Applicable'' END DisplayConsolidated,

		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''Service Name''
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN ''Vendor / State''
			ELSE ''State'' END DisplayClassHeader,
		CASE 
			WHEN ClassificationId IN ( 0 /*Service*/, 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN ''Vendor / State / City''
			ELSE ''Publication Name'' END DisplayPOHeader,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''Service Name''			
			ELSE ''Vendor / State / City'' END DisplayConsolidatedHeader,

		CASE  
			WHEN ClassificationId IN ( 0 /*Service*/, 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) 
			THEN VendorCity
			WHEN ClassificationId = 405 /*Television*/ THEN ''Not Applicable'' 
			ELSE VendorName END DisplayClass2,
		CASE  WHEN ClassificationId = 0 /*Service*/ THEN ''''
			WHEN ClassificationId IN ( 401 /*Newspaper*/, 402 /*Magazine*/, 403 /*Radio*/) THEN ''City''
			ELSE ''Name'' END DisplayClassHeader2

		FROM
		(
		SELECT * FROM
		(
		SELECT TOP 100 PERCENT
			J.Id JobNo,
			I.InvoiceNo,
			CASE WHEN I.InvoiceNo IS NOT NULL THEN ''A''+CONVERT(VARCHAR,I.InvoiceNo) 
			ELSE CONVERT(VARCHAR,I.InvoiceNo) END AS AdvtInvoiceNo,
			I.InvoiceDate,
			JMB.ActualInvoice,
			J.PONumber,
			dbo.fnc_CWI_GetJobMediabuyRundatesScalar(J.id, JMB.Id) Rundates,
			dbo.fnc_CWI_GetJobAdType(J.Id) AdType,
			V.VendorName,
			V.Physical_City VendorCity,
			V.Physical_StateName VendorState,
			C.ClientCode ClientCode,
			C.ClientName ClientName,
			D.ClientCode DivisionCode,
			D.ClientName DivisionName,
			CASE WHEN IsConsolidated = 1 THEN CA.AddressLine1 ELSE DA.AddressLine1 END  AddressLine1,
			CASE WHEN IsConsolidated = 1 THEN ISNULL(CA.AddressLine2,'''') 
					ELSE ISNULL(DA.AddressLine2,'''') END  AddressLine2,
			CASE WHEN IsConsolidated = 1 THEN CA.City ELSE DA.City END  City,
			CASE WHEN IsConsolidated = 1 THEN CA.StateCode ELSE DA.StateCode END  StateCode,
			CASE WHEN IsConsolidated = 1 THEN CA.StateName ELSE DA.StateName END  StateName,
			CASE WHEN IsConsolidated = 1 THEN CA.Zip ELSE DA.Zip END  Zip,

			J.AdDescription,
			CASE WHEN --JMB.IsComplimentary = 1 OR 
			JMB.IsComplimentaryInvoice = 1 THEN 1 ELSE 0 END IsCompliment,
			LC.LookupName Classification,
			I.IsConsolidated,
			I.InvoiceTypeLookupId,

			J.DivisionId,
				J.ClassificationId

		FROM CWI_Invoice I
			INNER JOIN  CWI_Job J
				ON I.Id = J.InvoiceId
			INNER JOIN  Lookup LC
				ON LC.Id = J.ClassificationId
			INNER JOIN CWI_JobMediaBuy JMB
				ON J.Id = JMB.JobId
			INNER JOIN  vw_CWI_VendorAddress V 
				ON V.VendorId = JMB.VendorId
			INNER JOIN  CWI_Client C
				ON C.ID = I.ClientId
			INNER JOIN CWI_Client D
				ON J.DivisionId = D.Id
			INNER JOIN  vw_CWI_Address CA
				ON CA.ID = C.AddressID
			INNER JOIN  vw_CWI_Address DA
				ON DA.ID = D.AddressID
		WHERE
			 J.IsQuote =0              
			AND J.IsCancelled =0              
			AND JMB.IsCancelled =0 
			AND JMB.IsRemoved = 0
			AND JMB.DNR = 0
			AND I.ClientId = @ClientId
			AND I.InvoiceDate = @InvoiceDate

		ORDER BY              
			V.VendorName,C.ClientCode,LC.LookupName,CA.StateName,V.Physical_City
		) x
		UNION ALL
		SELECT TOP 100 PERCENT
			J.Id JobNo,
			I.InvoiceNo,
			CASE WHEN I.InvoiceNo IS NOT NULL THEN ''A''+CONVERT(VARCHAR,I.InvoiceNo) 
			ELSE CONVERT(VARCHAR,I.InvoiceNo) END AS AdvtInvoiceNo,
			I.InvoiceDate,
			JMB.ServiceFee ActualInvoice,
			J.PONumber,
			dbo.fnc_CWI_GetJobMediabuyRundatesScalar(J.id, JMB.Id) Rundates,
			dbo.fnc_CWI_GetJobAdType(J.Id) AdType,
			ISNULL(SR.ServiceName, ''Other'') AS VendorName,
			'''' VendorCity,
			'''' VendorState,
			C.ClientCode ClientCode,
			C.ClientName ClientName,
			D.ClientCode DivisionCode,
			D.ClientName DivisionName,
			CASE WHEN IsConsolidated = 1 THEN CA.AddressLine1 ELSE DA.AddressLine1 END  AddressLine1,
			CASE WHEN IsConsolidated = 1 THEN ISNULL(CA.AddressLine2,'''') 
					ELSE ISNULL(DA.AddressLine2,'''') END  AddressLine2,
			CASE WHEN IsConsolidated = 1 THEN CA.City ELSE DA.City END  City,
			CASE WHEN IsConsolidated = 1 THEN CA.StateCode ELSE DA.StateCode END  StateCode,
			CASE WHEN IsConsolidated = 1 THEN CA.StateName ELSE DA.StateName END  StateName,
			CASE WHEN IsConsolidated = 1 THEN CA.Zip ELSE DA.Zip END  Zip,

			JMB.ServiceDescription AS AdDescription,
			CASE WHEN JMB.IsComplimentary = 1  THEN 1 ELSE 0 END IsCompliment,
			''Service'' Classification,
			I.IsConsolidated,
			I.InvoiceTypeLookupId,

			J.DivisionId,0

		FROM CWI_Invoice I
			INNER JOIN  CWI_Job J
				ON I.Id = J.InvoiceId
			INNER JOIN  Lookup LC
				ON LC.Id = J.ClassificationId
			INNER JOIN CWI_JobService JMB
				ON J.Id = JMB.JobId		
			INNER JOIN  CWI_Client C
				ON C.ID = I.ClientId
			INNER JOIN CWI_Client D
				ON J.DivisionId = D.Id
			INNER JOIN  vw_CWI_Address CA
				ON CA.ID = C.AddressID
			INNER JOIN  vw_CWI_Address DA
				ON DA.ID = D.AddressID
			LEFT OUTER JOIN CWI_Service SR 
				ON JMB.ServiceId=SR.Id

		WHERE
			 J.IsQuote =0              
			AND J.IsCancelled =0              
			AND JMB.IsDeleted =0 
			AND I.ClientId = @ClientId
			AND I.InvoiceDate = @InvoiceDate
	) z


SET NOCOUNT OFF




' 
END
GO


