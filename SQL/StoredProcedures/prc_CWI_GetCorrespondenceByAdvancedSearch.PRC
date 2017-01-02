/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceByAdvancedSearch]    Script Date: 9/25/2014 8:54:27 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceByAdvancedSearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorrespondenceByAdvancedSearch]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespondenceByAdvancedSearch]    Script Date: 9/25/2014 8:54:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespondenceByAdvancedSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCorrespondenceByAdvancedSearch  
* Purpose : This PROC would be called TO do advanced search in jobs related fields
* Invoked from : Correspondence.aspx
* CREATED: MohanKumar Sundaram 
* CREATED ON:  02/20/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetCorrespondenceByAdvancedSearch  
	@MMRPO  = NULL
	, @JobNo  = NULL
	, @JobName  = NULL
	, @VendorCode  = NULL
	, @VendorName  = NULL
	, @DivisionCode  = NULL
	, @InvoiceDtFrom   = NULL
	, @InvoiceDtTo	 = NULL
	, @RunDateFrom	  = NULL
	, @RunDateTo	 = NULL
	, @CorrespondenceType  = ''703''
	, @RequestDtFrom   = NULL
	, @RequestDtTo  = NULL
	, @DeliveryStatus  = NULL
	, @LastModifiedDtFrom   = NULL
	, @LastModifiedDtTo   = NULL
	, @DeliveryMethod  = NULL
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetCorrespondenceByAdvancedSearch]
	  @MMRPO bigint = NULL
	, @JobNo bigint = 9
	, @JobName varchar(max) = NULL
	, @VendorCode varchar(max) = NULL
	, @VendorName varchar(max) = NULL
	, @DivisionCode varchar(max) = NULL
	, @InvoiceDtFrom  datetime = NULL
	, @InvoiceDtTo	datetime = NULL
	, @RunDateFrom	 datetime = NULL
	, @RunDateTo	datetime = NULL
	, @CorrespondenceType varchar(MAX) = NULL
	, @RequestDtFrom  datetime = NULL
	, @RequestDtTo datetime = NULL
	, @DeliveryStatus varchar(MAX) = NULL
	, @LastModifiedDtFrom  datetime = NULL
	, @LastModifiedDtTo  datetime = NULL
	, @DeliveryMethod varchar(MAX) = NULL
AS

SET NOCOUNT ON

SET @RequestDtTo = dbo.fnc_GetMaxDateTime(@RequestDtTo)
SET @LastModifiedDtTo = dbo.fnc_GetMaxDateTime(@LastModifiedDtTo)
SET @InvoiceDtTo = dbo.fnc_GetMaxDateTime(@InvoiceDtTo)

DECLARE @tblTemp TABLE
(
	Id bigint,
	JobMediaBuyId bigint,
	MMRPO bigint,
	VendorId int,
	VendorCode varchar(100), 
	VendorName varchar(100), 
	DivisionId int,
	ClientCode  varchar(100), 
	CorrespondenceTypeLookupId int,
	CorrespondenceType varchar(100),
	RequestedOn Datetime,
	LastStatusModifiedOn Datetime,
	InvoiceDate Datetime,
	RunDates varchar(max),
	JobNumber bigint,
	JobName varchar(max),
	Gross money,
	Net money,
	Age int,
	DeliveryMethods varchar(1000)
)

DECLARE @tblCorresType TABLE
(
	CorresTypeId int
)

DECLARE @tblDeliveryStatus TABLE
(
	StatusId int
)
DECLARE @tblDeliveryMethod TABLE
(
	MethodId int
)

DECLARE @tblRunDateMediabuy TABLE
(
	MediaBuyId bigint,
	FieldValue varchar(max)
)

DECLARE @IsRunDateSearch bit = 0
IF @RunDateFrom IS NOT NULL OR @RunDateTo IS NOT NULL
BEGIN
	SET @IsRunDateSearch = 1

	INSERT INTO @tblRunDateMediabuy
	SELECT 
		JMB.ID,TD.FieldValue 
	FROM CWI_JOBSUMMARYTemplateData TD
	INNER JOIN CWI_TaskTemplateField TTF
		ON TTF.Id = TD.TemplateFieldId
	INNER JOIN CWI_TaskField TF
		ON TTF.TaskFieldId = TF.Id
	INNER JOIN CWI_JobMediaBuy JMB
		ON JMB.JobId = TD.JobId
	WHERE
		TF.MappingLookupId = 20201 /* Ad Rundate */
		AND ISDATE(TD.FieldValue) = 1
		AND
			(
				CAST(TD.FieldValue AS datetime) >= ISNULL(@RunDateFrom,''2013-01-01'') 
				AND 
				CAST(TD.FieldValue AS datetime) <= ISNULL(@RunDateTo,''2300-01-01'')
			)
	UNION
	SELECT 
		MediaBuyId, JMBT.FieldValue 
	FROM
		CWI_JobMediaBuyRundateTemplateData JMBT
		INNER JOIN CWI_TaskTemplateField TTF
			ON JMBT.TemplateFieldId = TTF.Id 
		INNER JOIN CWI_TaskField TF
			ON TTF.TaskFieldId = TF.Id
			AND TF.MappingLookupId =  20201 /* Ad Rundate */
	WHERE
	 ISDATE(JMBT.FieldValue) = 1
		AND
			(
				CAST(JMBT.FieldValue AS datetime) >= ISNULL(@RunDateFrom,''2013-01-01'') 
				AND 
				CAST(JMBT.FieldValue AS datetime) <= ISNULL(@RunDateTo,''2300-01-01'')
			)
END

DECLARE @isMainSearch bit = 0
IF @CorrespondenceType IS NOT NULL
begin
	INSERT INTO @tblCorresType 
	SELECT CAST(Items as int) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@CorrespondenceType,'','')
end

IF @DeliveryMethod IS NOT NULL
begin
	INSERT INTO @tblDeliveryMethod 
	SELECT CAST(Items as int) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@DeliveryMethod,'','')
end

IF @DeliveryStatus IS NOT NULL
begin
	INSERT INTO @tblDeliveryStatus
	SELECT CAST(Items as int) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@DeliveryStatus,'','')
end


IF ISNULL(@CorrespondenceType,'''') <> ''''
BEGIN
	SET @isMainSearch = 1

	INSERT INTO @tblTemp
	SELECT 
		C.Id,
		C.JobMediaBuyId,
		C.MMRPO,
		V.Id VendorId,
		V.VendorCode,
		V.VendorName, 
		C.ClientId DivisionId,
		D.ClientCode,
		C.CorrespondenceTypeLookupId,
		LC.LookupName CorrespondenceType,
		C.CreatedOn RequestedOn,
		C.LastModifiedOn LastStatusModifiedOn,
		J.InvoiceDate,
		dbo.fnc_CWI_GetJobMediabuyRundatesScalar(C.JobId, C.MMRPO) RunDates,
		J.Id JobNumber,
		J.JobName,
		JMB.ActualCost Gross,
		JMB.ActualInvoice Net,
		DATEDIFF(d,C.CreatedOn,getdate()) Age,
		dbo.fnc_CWI_GetVendorCorresDeliveryScalar(V.Id, C.CorrespondenceTypeLookupId) DeliveryMethods
	FROM 
	CWI_Correspondence C
	INNER JOIN CWI_Job J
		ON J.Id = C.JobId
	INNER JOIN CWI_Vendor V
		ON V.Id = C.VendorId
	INNER JOIN CWI_Client D
		ON D.Id = C.ClientId
	INNER JOIN Lookup LC
		ON LC.Id = C.CorrespondenceTypeLookupId
	INNER JOIN CWI_JobMediaBuy JMB
		ON JMB.Id = C.JobMediaBuyId
	INNER JOIN @tblCorresType tC
		ON tC.CorresTypeId = C.CorrespondenceTypeLookupId
	WHERE
		IsTrashed = 0
		AND ( @MMRPO IS NULL OR C.MMRPO = @MMRPO)
		AND ( @jobno IS NULL OR J.Id = @jobno)
		AND ( @JobName IS NULL OR J.JobName like ''%'' + @JobName + ''%'')
		AND ( @VendorCode IS NULL OR V.VendorCode like ''%'' + @VendorCode + ''%'')
		AND ( @VendorName IS NULL OR V.VendorName like ''%'' + @VendorName + ''%'')
		AND ( @DivisionCode IS NULL OR D.ClientCode like ''%'' + @DivisionCode + ''%'')
		AND C.InvoiceDate >= ISNULL(@InvoiceDtFrom,''2013-01-01'') 
		AND C.InvoiceDate <= ISNULL(@InvoiceDtTo,''2300-01-01'')
		AND ( @IsRunDateSearch = 0 OR EXISTS
					(SELECT top 1 1 FROM @tblRunDateMediabuy WHERE MediaBuyId = C.JobMediaBuyId)
				) 
END
ELSE IF ISNULL(@MMRPO,'''') <> '''' OR
		ISNULL(@VendorCode,'''') <> '''' OR
		ISNULL(@VendorName,'''') <> '''' OR
		ISNULL(@DivisionCode,'''') <> '''' OR
		@InvoiceDtFrom IS NOT NULL OR
		@InvoiceDtTo IS NOT NULL OR
		@RunDateFrom IS NOT NULL OR
		@RunDateTo IS NOT NULL OR
		ISNULL(@JobNo,0) <> 0 OR
		ISNULL(@JobName,'''') <> '''' 
BEGIN
	SET @isMainSearch = 1

	INSERT INTO @tblTemp
	SELECT 
		C.Id,
		C.JobMediaBuyId,
		C.MMRPO,
		V.Id VendorId,
		V.VendorCode,
		V.VendorName, 
		C.ClientId DivisionId,
		D.ClientCode,
		C.CorrespondenceTypeLookupId,
		LC.LookupName CorrespondenceType,
		C.CreatedOn RequestedOn,
		C.LastModifiedOn LastStatusModifiedOn,
		J.InvoiceDate,
		dbo.fnc_CWI_GetJobMediabuyRundatesScalar(C.JobId, C.MMRPO) RunDates,
		J.Id JobNumber,
		J.JobName,
		JMB.ActualCost Gross,
		JMB.ActualInvoice Net,
		DATEDIFF(d,C.CreatedOn,getdate()) Age,
		dbo.fnc_CWI_GetVendorCorresDeliveryScalar(V.Id, C.CorrespondenceTypeLookupId) DeliveryMethods
	FROM 
	CWI_Correspondence C
	INNER JOIN CWI_Job J
		ON J.Id = C.JobId
	INNER JOIN CWI_Vendor V
		ON V.Id = C.VendorId
	INNER JOIN CWI_Client D
		ON D.Id = C.ClientId
	INNER JOIN Lookup LC
		ON LC.Id = C.CorrespondenceTypeLookupId
	INNER JOIN CWI_JobMediaBuy JMB
		ON JMB.Id = C.JobMediaBuyId
	WHERE
		IsTrashed = 0
		AND ( @MMRPO IS NULL OR C.MMRPO = @MMRPO)
		AND ( @jobno IS NULL OR J.Id = @jobno)
		AND ( @JobName IS NULL OR J.JobName like ''%'' + @JobName + ''%'')
		AND ( @VendorCode IS NULL OR V.VendorCode like ''%'' + @VendorCode + ''%'')
		AND ( @VendorName IS NULL OR V.VendorName like ''%'' + @VendorName + ''%'')
		AND ( @DivisionCode IS NULL OR D.ClientCode like ''%'' + @DivisionCode + ''%'')
		AND C.InvoiceDate >= ISNULL(@InvoiceDtFrom,''2013-01-01'') 
		AND C.InvoiceDate <= ISNULL(@InvoiceDtTo,''2300-01-01'')
		AND ( @IsRunDateSearch = 0 OR EXISTS
					(SELECT top 1 1 FROM @tblRunDateMediabuy WHERE MediaBuyId = C.JobMediaBuyId)
				)
END


	IF @isMainSearch = 1
	Begin
		SELECT C.*,
			ISNULL(CD.Id,0) CorresDeliveryId,
			ISNULL(CD.CreatedOn,C.RequestedOn) RequestedDeliveryOn,
			ISNULL(CD.LastModifiedOn,C.LastStatusModifiedOn) LastStatusModifiedDeliveryOn,
			ISNULL(CD.DeliveryMethodLookupId,0) DeliveryMethodLookupId,
			LDM.LookupName DeliveryMethod,
			ISNULL(LDS.LookupName, ''Pending'') DeliveryStatus

		FROM @tblTemp C
		LEFT OUTER JOIN CWI_CorrespondenceDelivery CD
			ON C.Id = CD.CorrespondenceId
		LEFT OUTER  JOIN lookup LDM
			ON LDM.Id = CD.DeliveryMethodLookupId
		LEFT OUTER  JOIN lookup LDS
			ON LDS.Id = CD.DeliveryStatusLookupId
		WHERE
			ISNULL(CD.IsTrashed,0) = 0
			AND ISNULL(CD.CreatedOn,C.RequestedOn) >= ISNULL(@RequestDtFrom,''2013-01-01'') 
			AND ISNULL(CD.CreatedOn,C.RequestedOn) <= ISNULL(@RequestDtTo,''2300-01-01'')
			AND ISNULL(CD.LastModifiedOn,C.LastStatusModifiedOn) >= ISNULL(@LastModifiedDtFrom,''2013-01-01'') 
			AND ISNULL(CD.LastModifiedOn,C.LastStatusModifiedOn) <= ISNULL(@LastModifiedDtTo,''2300-01-01'')
			AND ( @DeliveryMethod IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblDeliveryMethod WHERE MethodId = CD.DeliveryMethodLookupId)
				) 
			AND ( @DeliveryStatus IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblDeliveryStatus WHERE StatusId = CD.DeliveryStatusLookupId)
				) 
				AND ( @IsRunDateSearch = 0 OR EXISTS
					(SELECT top 1 1 FROM @tblRunDateMediabuy WHERE MediaBuyId = C.JobMediaBuyId)
				)
				
	End
	Else
	Begin
		SELECT 
			C.Id,
			C.MMRPO,
			V.Id VendorId,
			V.VendorCode,
			V.VendorName, 
			C.ClientId DivisionId,
			D.ClientCode,
			C.CorrespondenceTypeLookupId,
			LC.LookupName CorrespondenceType,
			C.CreatedOn RequestedOn,
			C.LastModifiedOn LastStatusModifiedOn,
			j.InvoiceDate,
			dbo.fnc_CWI_GetJobMediabuyRundatesScalar(C.JobId, C.MMRPO) RunDates,
			J.Id JobNumber,
			J.JobName,
			JMB.ActualCost Gross,
			JMB.ActualInvoice Net,
			DATEDIFF(d,C.CreatedOn,getdate()) Age,
			dbo.fnc_CWI_GetVendorCorresDeliveryScalar(V.Id, C.CorrespondenceTypeLookupId) DeliveryMethods,
			ISNULL(CD.Id,0) CorresDeliveryId,
			ISNULL(CD.CreatedOn,C.CreatedOn) RequestedDeliveryOn,
			ISNULL(CD.LastModifiedOn,C.LastModifiedOn) LastStatusModifiedDeliveryOn,
			ISNULL(CD.DeliveryMethodLookupId,0) DeliveryMethodLookupId,
			LDM.LookupName DeliveryMethod,
			ISNULL(LDS.LookupName, ''Pending'') DeliveryStatus

		FROM CWI_Correspondence C
		INNER JOIN CWI_Job J
			ON J.Id = C.JobId
		INNER JOIN CWI_Vendor V
			ON V.Id = C.VendorId
		INNER JOIN CWI_Client D
			ON D.Id = C.ClientId
		INNER JOIN Lookup LC
			ON LC.Id = C.CorrespondenceTypeLookupId
		INNER JOIN CWI_JobMediaBuy JMB
			ON JMB.Id = C.JobMediaBuyId
		LEFT OUTER JOIN CWI_CorrespondenceDelivery CD
			ON C.Id = CD.CorrespondenceId
		LEFT OUTER  JOIN lookup LDM
			ON LDM.Id = CD.DeliveryMethodLookupId
		LEFT OUTER  JOIN lookup LDS
			ON LDS.Id = CD.DeliveryStatusLookupId
		WHERE
			 C.IsTrashed = 0
			 AND ISNULL(CD.IsTrashed,0) = 0
			 
			AND ISNULL(CD.CreatedOn,C.CreatedOn) >= ISNULL(@RequestDtFrom,''2013-01-01'') 
			AND ISNULL(CD.CreatedOn,C.CreatedOn) <= ISNULL(@RequestDtTo,''2300-01-01'')
			AND ISNULL(CD.LastModifiedOn,C.LastModifiedOn) >= ISNULL(@LastModifiedDtFrom,''2013-01-01'') 
			AND ISNULL(CD.LastModifiedOn,C.LastModifiedOn) <= ISNULL(@LastModifiedDtTo,''2300-01-01'')
			AND ( @DeliveryMethod IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblDeliveryMethod WHERE MethodId = CD.DeliveryMethodLookupId)
				) 
			AND ( @DeliveryStatus IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblDeliveryStatus WHERE StatusId = CD.DeliveryStatusLookupId)
				) 
				AND ( @IsRunDateSearch = 0 OR EXISTS
					(SELECT top 1 1 FROM @tblRunDateMediabuy WHERE MediaBuyId = C.JobMediaBuyId)
				)
	End








' 
END
GO


