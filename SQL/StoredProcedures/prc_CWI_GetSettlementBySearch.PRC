/****** Object:  StoredProcedure [dbo].[prc_CWI_GetSettlementBySearch]    Script Date: 7/31/2014 5:51:24 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetSettlementBySearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetSettlementBySearch]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetSettlementBySearch]    Script Date: 7/31/2014 5:51:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetSettlementBySearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetSettlementBySearch  
* Purpose : This PROC would be called TO do advanced search in jobs related fields
* Invoked from : ManageSettlement.aspx
* CREATED: MohanKumar Sundaram 
* CREATED ON:  01/10/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetSettlementBySearch
	@planname = NULL
	, @planclient  = NULL
	, @plandivision  = NULL
	, @planfromdt  = NULL
	, @plantodt	 = NULL
	, @jobdesc  = NULL
	, @jobclient = NULL
	, @jobdivision  = NULL
	, @invoicedtfrom  = NULL
	, @invoicedtto	 = NULL
	, @createdonfrom  = NULL
	, @createdonto	 = NULL
    , @jobno	 = NULL
	, @jobclass	 = NULL
	, @jobstatus  = NULL
	, @isquote	 = NULL
	, @iscancelled  = NULL
	, @ispickup  = NULL
	, @createdby  =  NULL 
	, @vendorcode  = NULL
	, @vendorname  = NULL
	, @vendorstate = NULL
	, @vendorcity  = NULL
	, @tasksubject = NULL
	, @tasksummary  = NULL
	, @jobassignee = NUll
	, @addesc = NULL
	, @inUserId  = 8
	, @MMRPO  = null
	, @DeliveryMethod  = NULL
	, @DeliveryStatus =null
**********************************************************************/ 
--@planname=NULL,@planclient=NULL,@plandivision=NULL,@planfromdt=NULL,@plantodt=NULL,@jobdesc=NULL,@jobclient=NULL,@jobdivision=NULL,@invoicedtfrom=NULL,@invoicedtto=NULL,
--@createdonfrom=NULL,@createdonto=NULL,@jobno=NULL,@jobclass=NULL,@jobstatus=NULL,@isquote=NULL,@iscancelled=NULL,@ispickup=NULL,@createdby=NULL,
--@addesc=NULL,@jobassignee=''Test Ad Desc'',@vendorcode=NULL,@vendorname=NULL,@vendorstate=NULL,@vendorcity=NULL,@tasksubject=NULL,@tasksummary=NULL,@inUserId=NULL
CREATE PROCEDURE [dbo].[prc_CWI_GetSettlementBySearch]
	 @planname varchar(max) = NULL
	, @planclient varchar(max) = NULL
	, @plandivision varchar(max) = NULL
	, @planfromdt datetime = NULL
	, @plantodt	datetime = NULL
	, @jobdesc varchar(max) = NULL
	, @jobclient varchar(max) = NULL
	, @jobdivision varchar(max) = NULL
	, @invoicedtfrom datetime = NULL
	, @invoicedtto	datetime = NULL
	, @createdonfrom datetime = NULL
	, @createdonto	datetime = NULL
    , @jobno	bigint = NULL
	, @jobclass	Varchar(max) = NULL
	, @jobstatus int = NULL
	, @isquote	bit = NULL
	, @iscancelled bit = NULL
	, @ispickup bit = NULL
	, @createdby varchar(max) = NULL
	, @jobassignee  varchar(max)= NULL
	, @addesc varchar(max) = NULL
	, @vendorcode  varchar(max)= NULL
	, @vendorname  varchar(max)= NULL
	, @vendorstate  varchar(max)= NULL
	, @vendorcity  varchar(max)= NULL
	, @tasksubject  varchar(max)= NULL
	, @tasksummary  varchar(max)= NULL
	, @inUserId int =  NULL
	, @MMRPO bigint = null
	, @DeliveryMethod varchar(MAX) = NULL
	, @DeliveryStatus varchar(MAX)=null
AS

SET NOCOUNT ON

IF @inUserId IS NOT NULL
BEGIN
	SELECT t.*, ISNULL(C.Id,0) CorresId
	FROM
	(
	SELECT 
	distinct
		 MB.ID AS MediaBuyId,
			MB.MMRPO,
			J.InvoiceDate,
			J.IsQuote,
			ISNULL(MB.DNR,0) AS DNR,
			--CAST (CASE WHEN MB.StatusId = 20104 THEN 1 ELSE 0 END AS BIT) AS IsCancelled,	
			CASE WHEN J.JobStatusLookupId = 8006 /*cancelled*/ THEN CAST(1 AS BIT) ELSE MB.IsCancelled END IsCancelled,
			ISNULL(MB.QuotedCost,0) AS QuotedCost,
			ISNULL(MB.CostType,'''') AS CostType,
			ISNULL(MB.ActualCost,0) AS NetCost,
			ISNULL(MB.ActualInvoice,0) AS GrossInvoice,
			V.VendorCode,
			V.VendorName,
			[dbo].[fnc_FormatRemovalPhone](V.Physical_Workphone,default) WorkPhone,
			D.ClientCode+''-''+D.ClientName AS Division,
			C.ClientCode+''-''+C.ClientName AS Client,
			M.PlanName,
			U.Id AS UserId,
			U.Names AS JobSubmitter,
			LC.LookupName AS ClassificationName,
			LC.Id AS ClassificationId,
			ZC.TimeZone AS VendorTimeZone,
			C.ID AS ClientID,
			D.ID AS DivisionID,
			M.ID AS PlanID,
			J.ID AS JobID,
			V.VendorId AS VendorId,
			(CASE WHEN IsComplimentary=1 THEN  1
							WHEN IsComplimentary = 0 AND ISNULL(ActualCost,0)>0 THEN 1
							ELSE 0 END) IsCostCollected,
			J.JobStatusLookupId,
			(CASE	WHEN J.IsCancelled= 1 THEN 704
					WHEN J.IsChangeOrder= 1 THEN 709
					WHEN J.IsQuote= 1 THEN 703
					ELSE 701 /*Insertion Order*/ END) CorrespondenceTypeLookupId

	FROM CWI_JobMediaBuy MB
	INNER JOIN CWI_Job J
		ON J.ID = MB.JobId

	INNER JOIN CWI_MarketingPlan M
		ON M.ID = J.MarketingPlanId
	INNER JOIN CWI_User U
		ON U.Id = J.CreatedBy
	INNER JOIN CWI_Client D
		ON M.DivisionID = D.ID
	INNER JOIN CWI_Client C
		ON D.ParentID = C.ID
	INNER JOIN Lookup LC
		ON LC.Id = J.ClassificationId
	INNER JOIN Lookup LS
		ON LS.Id = J.JobStatusLookupId
	
	INNER JOIN vw_CWI_VendorAddress V
		ON V.VendorId=MB.VendorId
	LEFT JOIN ZipCode AS ZC 
					ON ZC.ZipCode=V.Physical_Zip 
	where  J.InvoiceId IS NULL
		AND MB.IsRemoved = 0
		AND MB.DNR = 0
		AND MB.IsCancelled = 0
		AND J.IsCancelled=0
		AND J.IsQuote = 0
		--AND MB.MMRPO IS NOT NULL
		AND J.InvoiceDate >= ISNULL(@invoicedtfrom,''2013-01-01'') 
		AND J.JobStatusLookupId<>8003 
		AND MB.StatusId <> 20102 
				--AND J.InvoiceDate <= ISNULL(@invoicedtto,''2300-01-01'')
	
	) t
	LEFT OUTER JOIN CWI_Correspondence C
		ON C.JobMediaBuyId = t.MediaBuyId
			AND C.CorrespondenceTypeLookupId = t.CorrespondenceTypeLookupId And IsTrashed=0
	ORDER BY t.InvoiceDate, t.VendorCode asc
	RETURN
END
DECLARE @tblTemp TABLE
(
	TempMainId bigint
)

DECLARE @tblMainId TABLE
(
	SearchMainId bigint
)

DECLARE @tblFinalMainId TABLE
(
	SearchMainId bigint
)

DECLARE @tblDeliveryMethod TABLE
(
	MethodId bigint
)

DECLARE @tblDeliveryStatus TABLE
(
	StatusId bigint
)

DECLARE @tblJobClass TABLE
(
	ClassId bigint
)

IF @jobclass IS NOT NULL
begin
	INSERT INTO @tblJobClass 
	SELECT CAST(Items as bigint) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@jobclass,'','')
end

IF @DeliveryMethod IS NOT NULL
begin
	INSERT INTO @tblDeliveryMethod 
	SELECT CAST(Items as bigint) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@DeliveryMethod,'','')
end

IF @DeliveryStatus IS NOT NULL
begin
	INSERT INTO @tblDeliveryStatus 
	SELECT CAST(Items as bigint) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@DeliveryStatus,'','')
end

IF(@createdonto IS NOT NULL)
begin
	SET @createdonto = dbo.fnc_GetMaxDateTime(@createdonto)
end 
DECLARE @isPreviousSearch bit = 0

IF @inUserId IS NULL
BEGIN

	IF ( ISNULL(@planname,'''') <> '''' OR ISNULL(@planclient,'''') <> ''''
		OR ISNULL(@plandivision,'''') <> ''''
		OR @planfromdt IS NOT NULL
		OR @plantodt IS NOT NULL
		)
	BEGIN
	
		SET @isPreviousSearch = 1
		SET @planclient = ISNULL(@planclient,'''')
		SET @plandivision = ISNULL(@plandivision,'''')

		INSERT INTO @tblMainId
		select 
				MB.ID
		 
		from CWI_MarketingPlan M
			INNER JOIN CWI_Client D
				ON M.DivisionID = D.ID
			INNER JOIN CWI_Client C
				ON D.ParentID = C.ID
			INNER JOIN CWI_Job J
				ON J.MarketingPlanId = M.Id
			INNER JOIN CWI_JobMediaBuy MB
				ON MB.JobId = J.Id
		WHERE
			M.IsDeleted =0 AND
			((C.ClientCode like +''%''+@planclient+''%'' OR C.ClientName like +''%''+@planclient+''%'')
				AND 
				(D.ClientCode LIKE +''%''+@plandivision+''%'' OR D.ClientName LIKE +''%''+@plandivision+''%'')
				)
				AND
				(
				M.PlanFrom >= ISNULL(@planfromdt,''2013-01-01'') 
				AND M.PlanTo <= ISNULL(@plantodt,''2300-01-01'')
				)
			AND ( @planname IS NULL OR M.PlanName like ''%'' + @planname + ''%'')

	END

	IF ( ISNULL(@jobdesc ,'''') <> '''' OR ISNULL(@jobclient ,'''') <> ''''
		OR ISNULL(@jobdivision ,'''') <> ''''
		OR @invoicedtfrom  IS NOT NULL
		OR @invoicedtto	 IS NOT NULL
		OR @createdonfrom   IS NOT NULL
		OR @createdonto		 IS NOT NULL
		OR @jobno	  IS NOT NULL
		OR @jobclass		 IS NOT NULL
		OR @jobstatus    IS NOT NULL
		OR @isquote			 IS NOT NULL
		OR @iscancelled 		 IS NOT NULL
		OR @ispickup     IS NOT NULL
		OR ISNULL(@createdby  ,'''') <> ''''
		OR ISNULL(@jobassignee  ,'''') <> ''''
		OR ISNULL(@addesc ,'''') <> ''''

		)
	BEGIN
		SET @jobclient = ISNULL(@jobclient,'''')
		SET @jobdivision = ISNULL(@jobdivision,'''')
		SET @jobdesc = ISNULL(@jobdesc,'''')
		SET @createdby = ISNULL(@createdby,'''')
		SET @jobassignee = ISNULL(@jobassignee,'''')
		SET @addesc = ISNULL(@addesc,'''')

		IF ISNULL(@jobassignee  ,'''') <> ''''
		begin
			INSERT INTO @tblTemp
			select JMB.Id
				from CWI_JobAssignee JA
			INNER JOIN CWI_JobMediaBuy JMB
				ON JMB.JobId = JA.JobID
			LEFT OUTER JOIN CWI_User UA
				ON UA.Id = JA.UserID
			LEFT OUTER JOIN CWI_Group G
				ON G.Id = JA.GroupID
			WHERE
	
				( @jobassignee IS NULL OR UA.Names like ''%'' + @jobassignee + ''%''
				OR G.GroupName like ''%'' + @jobassignee + ''%'')

			INSERT INTO @tblTemp
			SELECT 
				JMB.Id  
			FROM CWI_Job j
			INNER JOIN CWI_JobMediaBuy JMB
				ON JMB.JobId = J.Id
				INNER JOIN CWI_User UC
					ON UC.Id = J.CreatedBy
				INNER JOIN CWI_MarketingPlan M
					ON M.ID = J.MarketingPlanId
				INNER JOIN CWI_Client D
					ON M.DivisionID = D.ID
				INNER JOIN CWI_Client C
					ON D.ParentID = C.ID
				INNER JOIN @tblTemp t -- Jobs assigned
					ON t.TempMainId = JMB.ID
				
			WHERE
				J.InvoiceDate >= ISNULL(@invoicedtfrom,''2013-01-01'') 
				AND J.InvoiceDate <= ISNULL(@invoicedtto,''2300-01-01'')
				AND  ( @jobno IS NULL OR J.Id = @jobno)
				AND ( @jobdesc IS NULL OR J.JobSummary like ''%'' + @jobdesc + ''%'')
				AND ( @addesc IS NULL OR J.AdDescription like ''%'' + @addesc + ''%'')
				AND  ( @jobstatus IS NULL OR J.JobStatusLookupId = @jobstatus)
				AND  ( @isquote IS NULL OR J.IsQuote = @isquote)
				AND  ( @iscancelled IS NULL OR J.IsCancelled = @iscancelled)
				AND  ( @ispickup IS NULL OR J.IsPickup = @ispickup)
				AND J.CreatedOn >= ISNULL(@createdonfrom,''2013-01-01'') 
				AND J.CreatedOn <= ISNULL(@createdonto,''2300-01-01'')
				AND  (@createdby IS NULL OR UC.Names like ''%'' + @createdby + ''%'')
				AND (@jobclient IS NULL OR C.ClientCode like +''%''+@jobclient+''%'' OR C.ClientName like +''%''+@jobclient+''%'')
				AND (@jobdivision IS NULL OR D.ClientCode LIKE +''%''+@jobdivision+''%'' OR D.ClientName LIKE +''%''+@jobdivision+''%'')
				AND ( @jobclass IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblJobClass WHERE ClassId = J.ClassificationId)
				) 
		end
		else
		begin

			INSERT INTO @tblTemp
			SELECT 
				JMB.Id  
			FROM CWI_Job j
				INNER JOIN CWI_JobMediaBuy JMB
					ON JMB.JobId = J.Id
				INNER JOIN CWI_User UC
					ON UC.Id = J.CreatedBy
				INNER JOIN CWI_MarketingPlan M
					ON M.ID = J.MarketingPlanId
				INNER JOIN CWI_Client D
					ON M.DivisionID = D.ID
				INNER JOIN CWI_Client C
					ON D.ParentID = C.ID
				
			WHERE
				J.InvoiceDate >= ISNULL(@invoicedtfrom,''2013-01-01'') 
				AND J.InvoiceDate <= ISNULL(@invoicedtto,''2300-01-01'')
				AND  ( @jobno IS NULL OR J.Id = @jobno)
				AND ( @jobdesc IS NULL OR J.JobSummary like ''%'' + @jobdesc + ''%'')
				AND  ( @jobstatus IS NULL OR J.JobStatusLookupId = @jobstatus)
				AND  ( @isquote IS NULL OR J.IsQuote = @isquote)
				AND  ( @iscancelled IS NULL OR J.IsCancelled = @iscancelled)
				AND  ( @ispickup IS NULL OR J.IsPickup = @ispickup)
				AND J.CreatedOn >= ISNULL(@createdonfrom,''2013-01-01'') 
				AND J.CreatedOn <= ISNULL(@createdonto,''2300-01-01'')
				AND  ( @createdby IS NULL OR UC.Names like ''%'' + @createdby + ''%'')
				AND (@jobclient IS NULL OR C.ClientCode like +''%''+@jobclient+''%'' OR C.ClientName like +''%''+@jobclient+''%'')
				AND (@jobdivision IS NULL OR D.ClientCode LIKE +''%''+@jobdivision+''%'' OR D.ClientName LIKE +''%''+@jobdivision+''%'')
				AND ( @addesc IS NULL OR J.AdDescription like ''%'' + @addesc + ''%'')
				AND ( @jobclass IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblJobClass WHERE ClassId = J.ClassificationId)
				)
		end		
		
		
		IF @isPreviousSearch = 1
		begin
			DELETE @tblMainId
			WHERE SearchMainId not in
			(
				SELECT 
					j.SearchMainId
				FROM @tblMainId j
				INNER JOIN @tblTemp t
					ON j.SearchMainId = t.TempMainId
			)
		end

		else
		begin
			INSERT INTO @tblMainId
			SELECT * FROM @tblTemp;
			
			
		end

		SET @isPreviousSearch = 1

	END
	
	IF ( ISNULL(@vendorcode,'''') <> '''' OR ISNULL(@vendorname,'''') <> ''''
		OR ISNULL(@vendorstate,'''') <> ''''
		OR ISNULL(@vendorcity,'''') <> ''''
		OR @MMRPO IS NOT NULL
		)
	BEGIN
		SET @vendorcode  = ISNULL(@vendorcode,'''')
		SET @vendorname  = ISNULL(@vendorname,'''')
		SET @vendorstate  = ISNULL(@vendorstate,'''')
		SET @vendorcity  = ISNULL(@vendorcity,'''')
	
		INSERT INTO @tblTemp
		select JMB.Id 
		from CWI_JobMediaBuy JMB
		INNER JOIN vw_CWI_VendorAddress VA
			ON VA.VendorId = JMB.VendorId
		where
			( @vendorcode IS NULL OR VA.VendorCode like ''%'' + @vendorcode + ''%'')
			AND ( @vendorname IS NULL OR VA.VendorName like ''%'' + @vendorname + ''%'')
			AND ( @vendorstate IS NULL OR VA.Physical_StateName like ''%'' + @vendorstate + ''%'')
			AND ( @vendorcity IS NULL OR VA.Physical_City like ''%'' + @vendorcity + ''%'')
			AND (@MMRPO IS NULL OR JMB.MMRPO = @MMRPO)

		IF @isPreviousSearch = 1
		begin
			DELETE @tblMainId
			WHERE SearchMainId not in
			(
				SELECT 
					j.SearchMainId
				FROM @tblMainId j
				INNER JOIN @tblTemp t
					ON j.SearchMainId = t.TempMainId
			)
		end
		else
		begin
			INSERT INTO @tblMainId
			SELECT * FROM @tblTemp
		end

		SET @isPreviousSearch = 1
	END


	IF ( ISNULL(@tasksubject,'''') <> '''' OR ISNULL(@tasksummary,'''') <> '''')
	BEGIN
		INSERT INTO @tblTemp
		select 
			JMB.Id  
		from CWI_Task T
		INNER JOIN CWI_JobMediaBuy JMB
				ON JMB.JobId = T.ObjectId
		INNER JOIN CWI_TaskNote TN
			ON TN.TaskId = T.Id
			AND TN.IsSummary = 1
		where
			T.ObjectLookupId = 205  -- Job object lookup id
	
			AND ( @tasksubject IS NULL OR T.[Subject] like ''%'' + @tasksubject + ''%'')
			AND ( @tasksummary IS NULL OR TN.Note like ''%'' + @tasksummary + ''%'')

		IF @isPreviousSearch = 1
		begin
			DELETE @tblMainId
			WHERE SearchMainId not in
			(
				SELECT 
					j.SearchMainId
				FROM @tblMainId j
				INNER JOIN @tblTemp t
					ON j.SearchMainId = t.TempMainId
			)
		end
		else
		begin
			INSERT INTO @tblMainId
			SELECT * FROM @tblTemp
		end

		SET @isPreviousSearch = 1
	END

	
	IF ( ISNULL(@DeliveryMethod,'''') <> '''' OR ISNULL(@DeliveryStatus,'''') <> '''') 
	BEGIN
		DELETE from @tblTemp
		INSERT INTO @tblTemp
		SELECT C.JobMediaBuyId
		FROM
		 CWI_Correspondence C 
		left JOIN CWI_CorrespondenceDelivery CD ON CD.CorrespondenceId=C.Id

		WHERE( @DeliveryMethod IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblDeliveryMethod WHERE MethodId = CD.DeliveryMethodLookupId)
				) 
			AND ( @DeliveryStatus IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblDeliveryStatus WHERE StatusId = CD.DeliveryStatusLookupId)
				) 
			AND (@MMRPO IS NULL OR C.MMRPO = @MMRPO)
			
		IF @isPreviousSearch = 1
		begin
			DELETE @tblMainId
			WHERE SearchMainId not in
			(
				SELECT 
					j.SearchMainId
				FROM @tblMainId j
				INNER JOIN @tblTemp t
					ON j.SearchMainId = t.TempMainId
			)
		end
		else
		begin
			INSERT INTO @tblMainId
			SELECT * FROM @tblTemp
		end

		SET @isPreviousSearch = 1
	END
	
	/*
	Pending

	d.	Services Related Fields:
	i.	Service Name
	ii.	Service Description

	*/

END

ELSE
BEGIN
	INSERT INTO @tblTemp
	select MB.ID
		from CWI_JobAssignee JA
		INNER JOIN CWI_JobMediaBuy MB
			ON MB.JobId = JA.JobID
		LEFT OUTER JOIN CWI_User UA
			ON UA.Id = JA.UserID
		LEFT OUTER JOIN
			( SELECT GroupId FROM CWI_UserGroup UG
				WHERE UG.UserID = @inUserId
			) G
			ON G.GroupId = JA.GroupID
	WHERE
		UA.Id = @inUserId
		OR G.GroupID IS NOT NULL

	INSERT INTO @tblTemp
	SELECT 
			MB.ID 
	FROM CWI_Job j
	INNER JOIN CWI_JobMediaBuy MB
			ON MB.JobId = J.ID
	Where J.CreatedBy = @inUserId

	INSERT INTO @tblTemp
	SELECT 
		MB.Id
	FROM
		CWI_Job J
		INNER JOIN CWI_MarketingPlan M
			ON J.MarketingPlanId = M.ID
		INNER JOIN CWI_JobMediaBuy MB
			ON MB.JobId = J.ID
		INNER JOIN dbo.fnc_GetClientsForUser(@inUserId,''D'') C
			ON C.ClientId = M.DivisionID


	INSERT INTO @tblMainId
	SELECT MB.Id FROM @tblTemp t
	INNER JOIN CWI_JobMediaBuy MB
			ON t.TempMainId = t.TempMainId
	INNER JOIN  CWI_Job j
		ON MB.JobId = j.ID
	
		and InvoiceDate >= getdate()

		SET @isPreviousSearch = 1
END


INSERT INTO @tblFinalMainId
SELECT distinct * from @tblMainId WHERE SearchMainId IS NOT NULL


IF @isPreviousSearch = 1
BEGIN
	SELECT t.*, ISNULL(C.Id,0) CorresId
	FROM
	(
	SELECT 
	distinct
		 MB.ID AS MediaBuyId,
			--ISNULL(MB.MMRPO,0) MMRPO,
			MB.MMRPO,
			J.InvoiceDate,
			J.IsQuote,
			ISNULL(MB.DNR,0) AS DNR,
			--CAST (CASE WHEN MB.StatusId = 20104 THEN 1 ELSE 0 END AS BIT) AS IsCancelled,	
			CASE WHEN J.JobStatusLookupId = 8006 /*cancelled*/ THEN CAST(1 AS BIT) ELSE MB.IsCancelled END IsCancelled,
			ISNULL(MB.QuotedCost,0) AS QuotedCost,
			ISNULL(MB.CostType,'''') AS CostType,
			ISNULL(MB.ActualCost,0) AS NetCost,
			ISNULL(MB.ActualInvoice,0) AS GrossInvoice,
			V.VendorCode,
			V.VendorName,
			V.Physical_Workphone WorkPhone,
			D.ClientCode+''-''+D.ClientName AS Division,
			C.ClientCode+''-''+C.ClientName AS Client,
			M.PlanName,
			U.Id AS UserId,
			U.Names AS JobSubmitter,
			LC.LookupName AS ClassificationName,
			LC.Id AS ClassificationId,
			ZC.TimeZone AS VendorTimeZone,
			C.ID AS ClientID,
			D.ID AS DivisionID,
			M.ID AS PlanID,
			J.ID AS JobID,
			V.VendorId AS VendorId,
			(CASE WHEN IsComplimentary=1 THEN  1
							WHEN IsComplimentary = 0 AND ISNULL(ActualCost,0)>0 THEN 1
							ELSE 0 END) IsCostCollected,
			J.JobStatusLookupId,
			(CASE	WHEN J.IsCancelled= 1 THEN 704
					WHEN J.IsChangeOrder= 1 THEN 709
					WHEN J.IsQuote= 1 THEN 703
					ELSE 701 /*Insertion Order*/ END) CorrespondenceTypeLookupId

	FROM @tblFinalMainId t
	INNER JOIN CWI_JobMediaBuy MB
		ON MB.Id=t.SearchMainId
	INNER JOIN CWI_Job J
		ON J.ID = MB.JobId

	INNER JOIN CWI_MarketingPlan M
		ON M.ID = J.MarketingPlanId
	INNER JOIN CWI_User U
		ON U.Id = J.CreatedBy
	INNER JOIN CWI_Client D
		ON M.DivisionID = D.ID
	INNER JOIN CWI_Client C
		ON D.ParentID = C.ID
	INNER JOIN Lookup LC
		ON LC.Id = J.ClassificationId
	INNER JOIN Lookup LS
		ON LS.Id = J.JobStatusLookupId


	INNER JOIN vw_CWI_VendorAddress V
		ON V.VendorId=MB.VendorId
	LEFT JOIN ZipCode AS ZC 
					ON ZC.ZipCode=V.Physical_Zip 
		
	where 
		 MB.IsRemoved = 0
			--AND MB.MMRPO IS NOT NULL
			
	) t
	LEFT OUTER JOIN CWI_Correspondence C
		ON C.JobMediaBuyId = t.MediaBuyId
			AND C.CorrespondenceTypeLookupId = t.CorrespondenceTypeLookupId And IsTrashed=0
	ORDER BY t.InvoiceDate, t.VendorCode asc
END
ELSE
BEGIN
	SELECT t.*, ISNULL(C.Id,0) CorresId
	FROM
	(

	SELECT 
	distinct top 1000
		 MB.ID AS MediaBuyId,
			--ISNUll(MB.MMRPO,0) MMRPO,
			MB.MMRPO,
			J.InvoiceDate,
			J.IsQuote,
			ISNULL(MB.DNR,0) AS DNR,
			--CAST (CASE WHEN MB.StatusId = 20104 THEN 1 ELSE 0 END AS BIT) AS IsCancelled,	
			CASE WHEN J.JobStatusLookupId = 8006 /*cancelled*/ THEN CAST(1 AS BIT) ELSE MB.IsCancelled END IsCancelled,
			ISNULL(MB.QuotedCost,0) AS QuotedCost,
			ISNULL(MB.CostType,'''') AS CostType,
			ISNULL(MB.ActualCost,0) AS NetCost,
			ISNULL(MB.ActualInvoice,0) AS GrossInvoice,
			V.VendorCode,
			V.VendorName,
			V.Physical_Workphone WorkPhone,
			D.ClientCode+''-''+D.ClientName AS Division,
			C.ClientCode+''-''+C.ClientName AS Client,
			M.PlanName,
			U.Id AS UserId,
			U.Names AS JobSubmitter,
			LC.LookupName AS ClassificationName,
			LC.Id AS ClassificationId,
			ZC.TimeZone AS VendorTimeZone,
			C.ID AS ClientID,
			D.ID AS DivisionID,
			M.ID AS PlanID,
			J.ID AS JobID,
			V.VendorId AS VendorId,
			(CASE WHEN IsComplimentary=1 THEN  1
							WHEN IsComplimentary = 0 AND ISNULL(ActualCost,0)>0 THEN 1
							ELSE 0 END) IsCostCollected,
							J.JobStatusLookupId,
			(CASE	WHEN J.IsCancelled= 1 THEN 704
					WHEN J.IsChangeOrder= 1 THEN 709
					WHEN J.IsQuote= 1 THEN 703
					ELSE 701 /*Insertion Order*/ END) CorrespondenceTypeLookupId


	FROM  CWI_JobMediaBuy MB
		
	INNER JOIN CWI_Job J
		ON J.ID = MB.JobId

	INNER JOIN CWI_MarketingPlan M
		ON M.ID = J.MarketingPlanId
	INNER JOIN CWI_User U
		ON U.Id = J.CreatedBy
	INNER JOIN CWI_Client D
		ON M.DivisionID = D.ID
	INNER JOIN CWI_Client C
		ON D.ParentID = C.ID
	INNER JOIN Lookup LC
		ON LC.Id = J.ClassificationId
	INNER JOIN Lookup LS
		ON LS.Id = J.JobStatusLookupId


	INNER JOIN vw_CWI_VendorAddress V
		ON V.VendorId=MB.VendorId
	LEFT JOIN ZipCode AS ZC 
					ON ZC.ZipCode=V.Physical_Zip 
		
	where 
		 MB.IsRemoved = 0
			--AND MB.MMRPO IS NOT NULL

	) t
	LEFT OUTER JOIN CWI_Correspondence C
		ON C.JobMediaBuyId = t.MediaBuyId
			AND C.CorrespondenceTypeLookupId = t.CorrespondenceTypeLookupId And IsTrashed=0
	ORDER BY t.InvoiceDate, t.VendorCode asc
END




SET NOCOUNT OFF









' 
END
GO
