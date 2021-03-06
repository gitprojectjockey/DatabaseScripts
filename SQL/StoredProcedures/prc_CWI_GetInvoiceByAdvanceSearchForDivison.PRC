/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceByAdvanceSearchForDivison]    Script Date: 7/16/2014 3:12:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceByAdvanceSearchForDivison]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceByAdvanceSearchForDivison]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceByAdvanceSearchForDivison]    Script Date: 7/16/2014 3:12:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceByAdvanceSearchForDivison]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceByAdvanceSearchForDivison  
* Purpose : This PROC would be called to retrieve the job details for the selected division
* Invoked from : ManageInvoice.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :--
**********************************************************************  
exec [prc_CWI_GetInvoiceByAdvanceSearchForDivison] 
@InvoiceFromDt =''2014-06-29'',
@inClientId = 14212,--,14212
@JobStatus=''8001'',
@SearchType=''''
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetInvoiceByAdvanceSearchForDivison] 
	@InvoiceFromDt DATETIME=NULL,
	@inClientId INT,
	@JobStatus Varchar(max)=null,
	@SearchType varchar(max)=null
AS
BEGIN

	BEGIN TRY

	SET NOCOUNT ON	

	DECLARE @tblDivision TABLE
	(
		DivId int
	)

	DECLARE @tblJobStatus TABLE
	(
		StatusId int
	)
	

	/*IF @JobStatus IS NOT NULL
	begin
		INSERT INTO @tblJobStatus 
		SELECT CAST(Items as int) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@JobStatus,'','')
	end*/
	IF lower(@SearchType)=''default''
	BEGIN
		INSERT INTO @tblJobStatus
		SELECT Id from Lookup 
			where Id in(8002,8001,8012) and IsActive=1/*Awaiting invoice authorization,In Progress,Assigned */  
		--SELECT ID from Lookup where ID NOT IN (8004,8006,8008,8009,8010) AND LookupTypeId = 30		
	END 
	ELSE
	BEGIN
		IF @JobStatus IS NOT NULL
		BEGIN
			INSERT INTO @tblJobStatus 
			SELECT CAST(Items as int) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@JobStatus,'','')
		END
	END


	INSERT INTO @tblDivision
	select distinct  D.Id from CWI_Client C
	INNER JOIN  CWI_Client D
		ON c.Id = D.ParentID
	WHERE 
		C.ID = @inClientId
		OR D.Id = @inClientId

	Declare @tblJobDetails Table
	(DivisionId int, JobNo bigint, MMRPO bigint, VendorId int, VendorCode varchar(50), VendorName varchar(200), AdNet decimal(18,2), AdGross decimal(18,2),
	FreezeInvoice bit,FreezeCost bit,ComplimentaryInvoice bit,ComplimentaryCost bit, AdMargin decimal(18,2), AdMarkupPercentage decimal(18,2),
	InvoiceDate datetime, PONumber varchar(250), MediaBuyId bigint, IsService bit)
	
	Insert into @tblJobDetails
	   SELECT 
			J.DivisionId,
			J.ID AS JobNo,
			MB.MMRPO,
			MB.VendorId,
			V.VendorCode,
			V.VendorName,
			ISNULL(MB.ActualCost,0) AS AdNet,
			ISNULL(MB.ActualInvoice,0) AS AdGross,
			ISNULL(MB.IsActualInvoiceFreeze,0)  AS FreezeInvoice,
			ISNULL(MB.IsActualCostFreeze,0) AS FreezeCost,
			ISNULL(MB.IsComplimentaryInvoice,0) AS ComplimentaryInvoice,
			ISNULL(MB.IsComplimentary,0) AS ComplimentaryCost,
			CASE WHEN ISNULL(MB.ActualInvoice,0)<>0 THEN 
				(ISNULL(MB.ActualInvoice,0)-ISNULL(MB.ActualCost,0))/ISNULL(MB.ActualInvoice,0)
			ELSE 0 END AS AdMargin,
			CASE WHEN ISNULL(MB.ActualCost,0)<>0 THEN 
				(ISNULL(MB.ActualInvoice,0)-ISNULL(MB.ActualCost,0))/ISNULL(MB.ActualCost,0)
			ELSE 0 END AS AdMarkupPercentage,			
			J.InvoiceDate,
			J.PONumber,
			MB.ID AS MediaBuyId,
			0 as IsService
		FROM CWI_Job J
		INNER JOIN CWI_JobMediaBuy MB 
			   ON MB.JobId=J.ID  
		INNER JOIN CWI_Vendor V
				ON V.ID=MB.VendorId
		INNER JOIN @tblDivision C
			ON C.DivId = J.DivisionId	
		WHERE 
			   J.InvoiceDate =  @InvoiceFromDt
			   AND ISNULL(MB.IsCancelled,0) = 0 
			   AND MB.StatusId<>20104
			   AND ISNULL(MB.DNR,0) = 0
			   AND ISNULL(J.IsQuote,0) = 0
			   AND J.IsCancelled=0
			   AND ISNULL(MB.IsRemoved,0) = 0
			   AND ( @JobStatus IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblJobStatus WHERE StatusId = J.JobStatusLookupId)
				) 
			  -- AND J.JobStatusLookupId NOT IN (8004,8006,8007,8008,8009,8010) 
			
		

		select * from @tblJobDetails

		Union 
					
		(select 
		J.DivisionId as DivisionId,
		JS.JobId as JobNo,
		JS.Id AS ServiceFeeId,
		CASE WHEN JS.ServiceId IS NULL AND JS.Id IS NOT NULL THEN 0 ELSE S.Id END AS ServiceId,
		CASE WHEN JS.ServiceId IS NULL AND JS.Id IS NOT NULL THEN ''Other'' ELSE S.ServiceCode END AS ServiceCode,
		--CASE WHEN JS.ServiceId IS NULL AND JS.Id IS NOT NULL THEN ''Other'' ELSE S.ServiceName END AS ServiceName,
		JS.ServiceDescription AS ServiceName,
		0.00 as AdNet,
		JS.ServiceFee as AdGross,
		0 AS FreezeInvoice,
		0 AS FreezeCost,
		JS.IsComplimentary as ComplimentaryInvoice,
		0 AS ComplimentaryCost,
		0 as AdMargin,
		0 as AdMarkupPercentage,
		J.InvoiceDate as InvoiceDate,
		J.PONumber,
		JS.Id as MediaBuyId,
		1 as IsService

		from CWI_Job J 
		inner join CWI_JobService JS
		ON JS.JobId=J.ID
		left outer JOIN CWI_Service S
		ON S.Id=JS.ServiceId 
		INNER JOIN @tblDivision C
			ON C.DivId = J.DivisionId	

		where JS.IsDeleted=0 
		and j.InvoiceDate=@InvoiceFromDt
		and ISNULL(J.IsQuote,0) = 0 
		and J.IsCancelled=0
		and (@JobStatus IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblJobStatus WHERE StatusId = J.JobStatusLookupId))
		)			
		

	END TRY

	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END






















' 
END
GO
