/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceByAdvanceSearch]    Script Date: 7/10/2014 3:05:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceByAdvanceSearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceByAdvanceSearch]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceByAdvanceSearch]    Script Date: 7/10/2014 3:05:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceByAdvanceSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceByAdvanceSearch  
* Purpose : This PROC would be called to retrieve all the invoice details
* Invoked from : ManageInvoice.aspx
* CREATED: Vijesh Mahi, MohanKumar
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetInvoiceByAdvanceSearch] 
@InvoiceFromDt =''2014-03-02 00:00:00'',
@JobStatus  = NULL,
@ClientCode  = NULL,
@ClientName  = NULL,
@DivisionCode  = NULL,
@DivisionName = NULL,
@IsConsolidated  = NULL,
@InvoiceType  = NULL,
@SearchType = ''default1''
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetInvoiceByAdvanceSearch] 
@InvoiceFromDt DATETIME=NULL,
@JobStatus varchar(max) = NULL,
@ClientCode VARCHAR(MAX) = NULL,
@ClientName VARCHAR(MAX) = NULL,
@DivisionCode VARCHAR(MAX) = NULL,
@DivisionName VARCHAR(MAX) = NULL,
@IsConsolidated bit = NULL,
@InvoiceType varchar(max) = NULL,
@SearchType varchar(20)=NULL

AS
BEGIN
	BEGIN TRY
	
	SET NOCOUNT ON	
	
	DECLARE @tblJobStatus TABLE
	(
		StatusId int
	)
	DECLARE @tblInvoiceType TABLE
	(
		InvTypeId int
	)		

	DECLARE @IsCancelled bit= 0
	IF lower(@SearchType)=''default''
	BEGIN
		SET @JobStatus =''''
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

			IF EXISTS (SELECT top 1 1 FROM @tblJobStatus WHERE StatusId = 8006/*cancelled*/)
			begin
				SET @IsCancelled = 1
			end
		END
	END

	IF @InvoiceType IS NOT NULL
	begin
		INSERT INTO @tblInvoiceType
		SELECT CAST(Items as int) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@InvoiceType,'','')
	end

	DECLARE @tblJob TABLE
	(
		DivisionId int,
		JobId bigint,
		InvoiceDate date,
		PO varchar(max),
		GroupClientId int,
		InvoiceId bigint,
		InvoiceType int,
		IsConsolidated bit
	)

	INSERT INTO @tblJob
	SELECT 
		DivisionId ,
		JobNo ,
		InvoiceDate ,
		PONumber ,
		GroupClientId ,
		InvoiceId,
		InvoiceType ,
		IsConsolidated
		 
	FROM
	(
	SELECT x.*,
		CASE WHEN I.ID IS NOT NULL THEN ISNULL(I.InvoiceTypeLookupId,0) ELSE ISNULL(CI.InvoiceTypeLookupId,0) END AS InvoiceType,
	   CASE WHEN I.ID IS NOT NULL THEN ISNULL(I.IsConsolidated,0) ELSE ISNULL(CI.IsConsolidated,0) END AS IsConsolidated
	 FROM 
	(
	SELECT 
		J.DivisionId,
		J.ID AS JobNo, 
		J.InvoiceDate,
		J.PONumber,
		CASE WHEN I.ID IS NOT NULL THEN I.ClientId ELSE D.GroupClientId END AS GroupClientId,
		J.InvoiceId
	FROM 
		CWI_Job J	
		INNER JOIN 
		(
				SELECT D.Id Division, D.ParentID, D.ClientCode DivisionCode, D.ClientName DivisionName,
				CASE WHEN ISNULL(CI.IsConsolidated,0) = 1 THEN C.id                                                                                         
					ELSE D.Id END AS GroupClientId
									
				FROM CWI_Client D 
       
				INNER JOIN CWI_Client C 
							ON D.ParentID = C.ID
				LEFT OUTER JOIN CWI_ClientInvoice CI 
							ON C.ID=CI.ClientId
				LEFT OUTER JOIN CWI_ClientInvoice DI 
							ON D.ID=DI.ClientId			   
		) D
				ON J.DivisionId=D.Division

				 
		INNER JOIN CWI_Client C
				ON C.ID   = D.ParentID
				
		LEFT OUTER JOIN CWI_Invoice I 
			ON I.ClientId=J.DivisionId
				AND I.InvoiceDate=J.InvoiceDate
		WHERE 
				(@InvoiceFromDt IS NULL OR J.InvoiceDate = @InvoiceFromDt)
				AND ( @ClientCode IS NULL OR C.ClientCode like ''%'' + @ClientCode + ''%'')
				AND ( @ClientName IS NULL OR C.ClientName like ''%'' + @ClientName + ''%'')
				AND ( @DivisionCode IS NULL OR D.DivisionCode like ''%'' + @DivisionCode + ''%'')
				AND ( @DivisionName IS NULL OR D.DivisionName like ''%'' + @DivisionName + ''%'')
				AND ISNULL(J.IsQuote,0) = 0
				AND J.IsCancelled=@IsCancelled
				AND ( @JobStatus IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblJobStatus WHERE StatusId = J.JobStatusLookupId)
				) 
		) x

		LEFT OUTER JOIN  CWI_Invoice I
			ON I.ClientId = x.GroupClientId
				AND I.InvoiceDate = x.InvoiceDate
		LEFT OUTER JOIN CWI_Client DV 
				ON DV.ID=x.GroupClientId
		LEFT OUTER JOIN CWI_ClientInvoice CI 
				ON DV.ID=CI.ClientId
		--LEFT OUTER JOIN CWI_Client CL 
		--		ON DV.ParentID=CL.ID
		--LEFT OUTER JOIN CWI_User U 
		--		ON U.Id=I.CreatedBy	
	)z
	WHERE
	  (@IsConsolidated IS NULL OR ISNULL(z.IsConsolidated,0) = @IsConsolidated)	
				AND  ( @InvoiceType IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblInvoiceType WHERE InvTypeId = z.InvoiceType)
				) 

				
	-------------------------Modified 8-Jul-2014-------
	Declare @tblJobDetails Table
	(DivisionId int, JobNo bigint, MMRPO bigint, VendorId int, VendorCode varchar(50), VendorName varchar(200), AdNet decimal(18,2), AdGross decimal(18,2),
	FreezeInvoice bit,FreezeCost bit,ComplimentaryInvoice bit,ComplimentaryCost bit, AdMargin decimal(18,2), AdMarkupPercentage decimal(18,2),
	InvoiceDate datetime, PONumber varchar(250), MediaBuyId bigint, IsService bit,
	GroupClientId int,TotalNet decimal(18,2),TotalGross decimal(18,2),Margin decimal(18,2),MarkupPercentage decimal(18,2), InvoiceId bigint)

		Insert into @tblJobDetails
		   SELECT 
				J.DivisionId,
				J.JobId AS JobNo,
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
				J.PO PONumber,
				MB.ID AS MediaBuyId,
				0 as IsService,
				J.GroupClientId AS GroupClientId,
				0 AS TotalNet,
				0 AS TotalGross,
				0 AS Margin,
				0 AS MarkupPercentage,
				J.InvoiceId	
				FROM @tblJob J
				INNER JOIN CWI_JobMediaBuy MB 
					   ON MB.JobId=J.JobId
				INNER JOIN CWI_Vendor V
					ON V.Id = MB.VendorId
				
				
				WHERE 
						
					    ISNULL(MB.IsCancelled,0) = 0 
					   AND ISNULL(MB.DNR,0) = 0
					   AND ISNULL(MB.IsRemoved,0) = 0				    
				
			
			INSERT INTO @tblJobDetails
			select 
			J.DivisionId as DivisionId,
			JS.JobId as JobNo,
			JS.Id AS ServiceFeeId,
			CASE WHEN JS.ServiceId IS NULL AND JS.Id IS NOT NULL THEN 0 ELSE S.Id END AS ServiceId,
			CASE WHEN JS.ServiceId IS NULL AND JS.Id IS NOT NULL THEN ''Other'' ELSE S.ServiceCode END AS ServiceCode,
			CASE WHEN JS.ServiceId IS NULL AND JS.Id IS NOT NULL THEN ''Other'' ELSE S.ServiceName END AS ServiceName,
			0.00 as AdNet,
			JS.ServiceFee as AdGross,
			0 AS FreezeInvoice,
			0 AS FreezeCost,
			JS.IsComplimentary as ComplimentaryInvoice,
			0 AS ComplimentaryCost,
			0 as AdMargin,
			0 as AdMarkupPercentage,
			J.InvoiceDate as InvoiceDate,
			J.PO PONumber,
			JS.Id as MediaBuyId,
			1 as IsService,
			J.GroupClientId AS GroupClientId,
			0 AS TotalNet,
			0 AS TotalGross,
			0 AS Margin,
			0 AS MarkupPercentage,
			J.InvoiceId		

			from @tblJob J
			INNER join CWI_JobService JS
				ON JS.JobId=J.JobId
			LEFT OUTER JOIN CWI_Service S
				ON S.Id=JS.ServiceId 
			
				WHERE 
						JS.IsDeleted = 0

	------------------------------End----------------------------
	
	SELECT 
	   DV.ID AS DivisionID,	
	   DV.ClientCode AS DivisionCode,
	   DV.ClientName AS DivisionName,
	   ISNULL(CL.ClientCode, DV.ClientCode) AS ClientCode,
	   ISNULL(CL.ClientName, DV.ClientName) AS ClientName,
	   ISNULL(CL.ID, DV.ID) AS ClientID,
	   x.*,	   
	   I.CreatedBy AS ApprovedUserId,
	   I.CreatedOn AS ApprovedOn,
	   U.Names AS ApprovedBy,
	   CASE WHEN I.ID IS NOT NULL THEN ISNULL(I.InvoiceTypeLookupId,0) ELSE ISNULL(CI.InvoiceTypeLookupId,0) END AS InvoiceType,
	   CASE WHEN I.ID IS NOT NULL THEN ISNULL(I.IsConsolidated,0) ELSE ISNULL(CI.IsConsolidated,0) END AS IsConsolidated,
	   (Select ValidationMessage  FROM fnc_CWI_GetInvoiceValidation(@InvoiceFromDt,ISNULL(DV.ID,CL.ID) )) AS ValidationMessage
	   --(Select IsDisabled  FROM fnc_CWI_GetInvoiceValidation(@InvoiceFromDt,ISNULL(DV.ID,CL.ID) )) AS IsDisabled	
	FROM 
	(
		SELECT 
			CASE WHEN I.ID IS NOT NULL THEN I.ClientId ELSE J.GroupClientId END AS GroupClientId,
			J.InvoiceDate,			
			SUM(ISNULL(J.AdNet,0)) AS TotalNet,
			SUM(ISNULL(J.AdGross,0)) AS TotalGross,
			CASE WHEN SUM(ISNULL(J.AdGross,0))<>0 THEN (SUM(ISNULL(J.AdGross,0))-SUM(ISNULL(J.AdNet,0)))/SUM(ISNULL(J.AdGross,0))
			ELSE 0 END AS Margin,
			CASE WHEN SUM(ISNULL(J.AdNet,0))<>0 THEN (SUM(ISNULL(J.AdGross,0))-SUM(ISNULL(J.AdNet,0)))/SUM(ISNULL(J.AdNet,0))
			ELSE 0 END AS MarkupPercentage	 
		FROM
	   @tblJobDetails J
	   LEFT OUTER JOIN CWI_Invoice I 
			ON I.ClientId=J.DivisionId
				AND I.InvoiceDate=J.InvoiceDate
				
				
		GROUP BY
			CASE WHEN I.Id IS NOT NULL THEN I.ClientId ELSE J.GroupClientId END, J.InvoiceDate

	) x
	LEFT OUTER JOIN  CWI_Invoice I
			ON I.ClientId = x.GroupClientId
				AND I.InvoiceDate = x.InvoiceDate
		LEFT OUTER JOIN CWI_Client DV 
				ON DV.ID=x.GroupClientId
		LEFT OUTER JOIN CWI_ClientInvoice CI 
				ON DV.ID=CI.ClientId
		LEFT OUTER JOIN CWI_Client CL 
				ON DV.ParentID=CL.ID
		LEFT OUTER JOIN CWI_User U 
				ON U.Id=I.CreatedBy	
	
	END TRY

	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END










' 
END
GO
