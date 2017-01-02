/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAllJobsByAdvancedSearch]    Script Date: 10/15/2014 3:24:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAllJobsByAdvancedSearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetAllJobsByAdvancedSearch]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAllJobsByAdvancedSearch]    Script Date: 10/15/2014 3:24:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAllJobsByAdvancedSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetAllJobsByAdvancedSearch  
* Purpose : This PROC would be called TO do advanced search in jobs related fields
* Invoked from : ManageJobs.aspx
* CREATED: MohanKumar Sundaram 
* CREATED ON:  01/10/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  14OCT14	Mohankumar		InsertionBy and InsertionOn returned         

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetAllJobsByAdvancedSearch  
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

	, @jobassignee = ''mohan''
	, @addesc = NULL
	, @inUserId int = NULL
**********************************************************************/ 
--@planname=NULL,@planclient=NULL,@plandivision=NULL,@planfromdt=NULL,@plantodt=NULL,@jobdesc=NULL,@jobclient=NULL,@jobdivision=NULL,@invoicedtfrom=NULL,@invoicedtto=NULL,
--@createdonfrom=NULL,@createdonto=NULL,@jobno=NULL,@jobclass=NULL,@jobstatus=NULL,@isquote=NULL,@iscancelled=NULL,@ispickup=NULL,@createdby=NULL,
--@addesc=NULL,@jobassignee=''Test Ad Desc'',@vendorcode=NULL,@vendorname=NULL,@vendorstate=NULL,@vendorcity=NULL,@tasksubject=NULL,@tasksummary=NULL,@inUserId=NULL
CREATE PROCEDURE [dbo].[prc_CWI_GetAllJobsByAdvancedSearch]
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
    , @jobno	int = NULL
	, @jobclass	int = NULL
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
	, @servicename varchar(max) = NULL
	, @servicedescription varchar(max) = NULL
	, @inUserId int =  NULL
	, @searchtype varchar(100) = NULL
	
	
AS

SET NOCOUNT ON
DECLARE @tblTemp TABLE
(
	TempJobId int
)

DECLARE @tblJobId TABLE
(
	SearchJobId int
)

DECLARE @tblFinalJobId TABLE
(
	SearchJobId int
)
DECLARE @tblJobStatus TABLE
(
	StatusId int
)
 
DECLARE @isPreviousSearch bit = 0
SET @searchtype = LTRIM(RTRIM(UPPER(ISNULL(@searchtype,''''))))

IF @searchtype =''''
BEGIN
IF @JobStatus IS NOT NULL
		BEGIN
			INSERT INTO @tblJobStatus 
			SELECT CAST(Items as int) FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@JobStatus,'','')
		END


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

	INSERT INTO @tblJobId
	select 
			J.Id PlanJobId
		 
	from CWI_MarketingPlan M
		INNER JOIN CWI_Client D
			ON M.DivisionID = D.ID
		INNER JOIN CWI_Client C
			ON D.ParentID = C.ID
		INNER JOIN CWI_Job J
			ON J.MarketingPlanId = M.Id
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
		select JA.JobID
			from CWI_JobAssignee JA
		LEFT OUTER JOIN CWI_User UA
			ON UA.Id = JA.UserID
		LEFT OUTER JOIN CWI_Group G
			ON G.Id = JA.GroupID
		WHERE
	
			( @jobassignee IS NULL OR UA.Names like ''%'' + @jobassignee + ''%''
			OR G.GroupName like ''%'' + @jobassignee + ''%'')

		INSERT INTO @tblTemp
		SELECT 
			J.ID JobId 
		FROM CWI_Job j
			INNER JOIN CWI_User UC
				ON UC.Id = J.CreatedBy
			INNER JOIN CWI_Client D
				ON J.DivisionID = D.ID
			INNER JOIN CWI_Client C
				ON D.ParentID = C.ID
			INNER JOIN @tblTemp t -- Jobs assigned
				ON t.TempJobId = J.ID
		WHERE
			J.InvoiceDate >= ISNULL(@invoicedtfrom,''2013-01-01'') 
			AND J.InvoiceDate <= ISNULL(@invoicedtto,''2300-01-01'')
			AND  ( @jobno IS NULL OR J.Id = @jobno)
			AND ( @jobdesc IS NULL OR J.JobSummary like ''%'' + @jobdesc + ''%'')
			AND ( @addesc IS NULL OR J.AdDescription like ''%'' + @addesc + ''%'')
			AND  ( @jobclass IS NULL OR J.ClassificationId = @jobclass)
			--AND  ( @jobstatus IS NULL OR J.JobStatusLookupId = @jobstatus)
			AND ( @JobStatus IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblJobStatus WHERE StatusId = J.JobStatusLookupId))
			AND  ( @isquote IS NULL OR J.IsQuote = @isquote)
			AND  ( @iscancelled IS NULL OR J.IsCancelled = @iscancelled)
			AND  ( @ispickup IS NULL OR J.IsPickup = @ispickup)
			AND J.CreatedOn >= ISNULL(@createdonfrom,''2013-01-01'') 
			AND J.CreatedOn <= ISNULL(@createdonto,''2300-01-01'')
			AND  (@createdby IS NULL OR UC.Names like ''%'' + @createdby + ''%'')
			AND
				((C.ClientCode like +''%''+@jobclient+''%'' OR C.ClientName like +''%''+@jobclient+''%'')
				AND 
				(D.ClientCode LIKE +''%''+@jobdivision+''%'' OR D.ClientName LIKE +''%''+@jobdivision+''%'')
				)
				
	end
	else
	begin

		INSERT INTO @tblTemp
		SELECT 
			J.ID JobId 
		FROM CWI_Job j
			INNER JOIN CWI_User UC
				ON UC.Id = J.CreatedBy
			INNER JOIN CWI_Client D
				ON J.DivisionID = D.ID
			INNER JOIN CWI_Client C
				ON D.ParentID = C.ID
		WHERE
			J.InvoiceDate >= ISNULL(@invoicedtfrom,''2013-01-01'') 
			AND J.InvoiceDate <= ISNULL(@invoicedtto,''2300-01-01'')
			AND  ( @jobno IS NULL OR J.Id = @jobno)
			AND ( @jobdesc IS NULL OR J.JobSummary like ''%'' + @jobdesc + ''%'')
			AND  ( @jobclass IS NULL OR J.ClassificationId = @jobclass)
			--AND  ( @jobstatus IS NULL OR J.JobStatusLookupId = @jobstatus)
			AND ( @JobStatus IS NULL OR EXISTS
					(SELECT top 1 1 FROM @tblJobStatus WHERE StatusId = J.JobStatusLookupId))
			AND  ( @isquote IS NULL OR J.IsQuote = @isquote)
			AND  ( @iscancelled IS NULL OR J.IsCancelled = @iscancelled)
			AND  ( @ispickup IS NULL OR J.IsPickup = @ispickup)
			AND J.CreatedOn >= ISNULL(@createdonfrom,''2013-01-01'') 
			AND J.CreatedOn <= ISNULL(@createdonto,''2300-01-01'')
			AND  ( @createdby IS NULL OR UC.Names like ''%'' + @createdby + ''%'')
			AND
				((C.ClientCode like +''%''+@jobclient+''%'' OR C.ClientName like +''%''+@jobclient+''%'')
				AND 
				(D.ClientCode LIKE +''%''+@jobdivision+''%'' OR D.ClientName LIKE +''%''+@jobdivision+''%'')
				)
			AND ( @addesc IS NULL OR J.AdDescription like ''%'' + @addesc + ''%'')
	end		


	IF @isPreviousSearch = 1
	begin
		DELETE @tblJobId
		WHERE SearchJobId not in
		(
			SELECT 
				j.SearchJobId
			FROM @tblJobId j
			INNER JOIN @tblTemp t
				ON j.SearchJobId = t.TempJobId
		)
	end
	else
	begin
		INSERT INTO @tblJobId
		SELECT * FROM @tblTemp
	end
	--SELECT * FROM @tblJobId -- 5 jobs
	--SELECT * FROM @tblTemp -- 5 jobs
	SET @isPreviousSearch = 1

END

IF ( ISNULL(@vendorcode,'''') <> '''' OR ISNULL(@vendorname,'''') <> ''''
	OR ISNULL(@vendorstate,'''') <> ''''
	OR ISNULL(@vendorcity,'''') <> ''''
	)
BEGIN
	SET @vendorcode  = ISNULL(@vendorcode,'''')
	SET @vendorname  = ISNULL(@vendorname,'''')
	SET @vendorstate  = ISNULL(@vendorstate,'''')
	SET @vendorcity  = ISNULL(@vendorcity,'''')
	
	--Added the below line(delete) because already tbltemp table has 5 records which will insert once more (repeating)
	DELETE FROM @tblTemp
	INSERT INTO @tblTemp
	select JMB.JobId 
	from CWI_JobMediaBuy JMB
	INNER JOIN vw_CWI_VendorAddress VA
		ON VA.VendorId = JMB.VendorId
	where
		( @vendorcode IS NULL OR VA.VendorCode like ''%'' + @vendorcode + ''%'')
		AND ( @vendorname IS NULL OR VA.VendorName like ''%'' + @vendorname + ''%'')
		AND ( @vendorstate IS NULL OR VA.Physical_StateName like ''%'' + @vendorstate + ''%'')
		AND ( @vendorcity IS NULL OR VA.Physical_City like ''%'' + @vendorcity + ''%'')
		AND JMB.IsRemoved=0
		

	IF @isPreviousSearch = 1
	begin
		DELETE @tblJobId
		WHERE SearchJobId not in
		(
			SELECT 
				j.SearchJobId
			FROM @tblJobId j
			INNER JOIN @tblTemp t
				ON j.SearchJobId = t.TempJobId
		)
	end
	else
	begin
		INSERT INTO @tblJobId
		SELECT * FROM @tblTemp
	end

	

	SET @isPreviousSearch = 1
END
--SELECT * FROM @tblJobId

IF ( ISNULL(@tasksubject,'''') <> '''' OR ISNULL(@tasksummary,'''') <> ''''
	
	)
BEGIN
	DELETE FROM @tblTemp
	
	INSERT INTO @tblTemp
	select 
		T.ObjectId
	from CWI_Task T
	INNER JOIN CWi_Job J ON J.Id=T.ObjectId	
	LEFT OUTER JOIN CWI_TaskNote TN
	ON TN.TaskId = T.Id
		AND TN.IsSummary = 1
	
		
	where
		T.ObjectLookupId = 205  -- Job object lookup id
	
		AND ( @tasksubject IS NULL OR T.[Subject] like ''%'' + @tasksubject + ''%'')
		AND ( @tasksummary IS NULL OR TN.Note like ''%'' + @tasksummary + ''%'')
		


	IF @isPreviousSearch = 1
	begin
		DELETE @tblJobId
		WHERE SearchJobId not in
		(
			SELECT 
				j.SearchJobId
			FROM @tblJobId j
			INNER JOIN @tblTemp t
				ON j.SearchJobId = t.TempJobId
		)
	end
	else
	begin
		INSERT INTO @tblJobId
		SELECT * FROM @tblTemp
	end

	SET @isPreviousSearch = 1
END

--Service related fields
IF ( ISNULL(@servicename,'''') <> '''' OR ISNULL(@servicedescription,'''') <> ''''
	)
BEGIN
	SET @servicename  = ISNULL(@servicename,'''')
	SET @servicedescription  = ISNULL(@servicedescription,'''')
	DELETE FROm @tblTemp
	INSERT INTO @tblTemp

	SELECT JS.JobId 
	FROM CWI_JobService JS
	INNER JOIN CWI_Job J
		ON J.Id = JS.JobId
	INNER JOIN CWI_Service S 
		ON S.ID=JS.ServiceId
	WHERE
		( @servicename IS NULL OR S.ServiceName like ''%'' + @servicename + ''%'')
		AND ( @servicedescription IS NULL OR JS.ServiceDescription like ''%'' + @servicedescription + ''%'')
		AND JS.IsDeleted=0
		
	IF @isPreviousSearch = 1
	begin
		DELETE @tblJobId
		WHERE SearchJobId not in
		(
			SELECT 
				j.SearchJobId
			FROM @tblJobId j
			INNER JOIN @tblTemp t
				ON j.SearchJobId = t.TempJobId
		)
	end
	else
	begin
		INSERT INTO @tblJobId
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
	--DELETE FROM @tblTemp
	INSERT INTO @tblTemp
	select JA.JobID
		from CWI_JobAssignee JA
	LEFT OUTER JOIN CWI_User UA
		ON UA.Id = JA.UserID 
	LEFT OUTER JOIN
		( SELECT GroupId FROM CWI_UserGroup UG
			WHERE UG.UserID = @inUserId 
		) G
		ON G.GroupId = JA.GroupID
	WHERE
		UA.Id = @inUserId
		AND JA.IsRemoved=0 
		OR G.GroupID IS NOT NULL

		--SELECT * FROM @tblTemp where TempJobId = 1848

	INSERT INTO @tblTemp
	SELECT 
			J.ID JobId 
	FROM CWI_Job j
	Where J.CreatedBy = @inUserId

	--SELECT * FROM @tblTemp where TempJobId = 1848

	INSERT INTO @tblTemp
	SELECT 
		J.ID JobId 
	FROM
		CWI_Job J
		INNER JOIN dbo.fnc_GetClientsForUser(@inUserId,''D'') C
			ON C.ClientId = J.DivisionID


	DECLARE @nextInvoiceDate datetime = ''2013-01-01''

	SELECT @nextInvoiceDate = MIN(J.InvoiceDate) FROM @tblTemp t
	INNER JOIN  CWI_Job j
		ON t.TempJobId = j.ID
	WHERE InvoiceId IS NULL;
	
	INSERT INTO @tblJobId
	SELECT J.Id FROM @tblTemp t
	
	INNER JOIN  CWI_Job j
		ON t.TempJobId = j.ID
		and InvoiceDate = @nextInvoiceDate
	


END

INSERT INTO @tblFinalJobId
SELECT distinct * from @tblJobId


END
ELSE
BEGIN
	--If user selects Jobs Pending Insertion (JPI) from dashboadr then execute the following
	IF @searchtype=''JPI''
	BEGIN
		INSERT INTO @tblFinalJobId
		SELECT distinct J.Id as JobId FROM CWI_Job J 
		INNER JOIN CWI_Client C ON C.Id=J.DivisionId
		INNER JOIN CWI_JobMediaBuy JMB ON J.Id=JMB.JobId AND JMB.IsRemoved = 0
		
		AND JMB.StatusId=20102 /* Media Buy Selected State */
		and J.InvoiceDate=@invoicedtfrom 
		AND C.ClientName = @plandivision
		AND J.JobStatusLookupId IN (8001/*In Progress*/,8012/* Assigned */, 8002 /* Awaiting Invoice Authorization */)
	END
	--If user selects Service Fee (SF) from dashboard then execute the following
	ELSE IF @searchtype=''SF''
	BEGIN
		INSERT INTO @tblFinalJobId
		SELECT distinct J.Id as JobId FROM CWI_Job J 
		INNER JOIN CWI_Client C ON C.Id=J.DivisionId
		INNER JOIN CWI_JobService JS ON J.Id=JS.JobId AND JS.IsDeleted = 0
		AND J.InvoiceDate=@invoicedtfrom 
		AND C.ClientName=@plandivision
		AND J.JobStatusLookupId IN (8001/*In Progress*/,8012/* Assigned */, 8002 /* Awaiting Invoice Authorization */)
	END
	--If user selects Job count (JB) from dashboard OR AIA - Awaiting Invoice Authorization then execute the following
	ELSE IF @searchtype=''JB'' 
	BEGIN
		INSERT INTO @tblFinalJobId
		SELECT distinct J.Id as JobId FROM CWI_Job J 
		INNER JOIN CWI_Client C ON C.Id=J.DivisionId
		AND J.InvoiceDate=@invoicedtfrom 
		AND C.ClientName=@plandivision
		AND J.JobStatusLookupId IN (8001/*In Progress*/,8012/* Assigned */, 8002 /* Awaiting Invoice Authorization */)
	END

END
DECLARE @tblAssginee TABLE
(
	AssigneeJobId int,
	Assignee varchar(max)
)

INSERT INTO @tblAssginee
	SELECT 
	
		t.SearchJobId,
		CASE WHEN U.Names IS NOT NULL THEN U.Names
			WHEN GroupName IS NOT NULL THEN GroupName
			ELSE '''' END assignee

	FROM  @tblFinalJobId t
	LEFT OUTER JOIN CWI_JobAssignee JA
		ON JA.JobID = t.SearchJobId and IsCopied = 0
	LEFT OUTER JOIN CWI_User U ON U.id = JA.UserId
	LEFT OUTER JOIN CWI_Group G ON G.id = JA.GroupId
--SELECT * FROM @tblFinalJobId

SELECT 
	M.Id PlanId,
	M.PlanName,
	J.InvoiceDate,
	J.ID JobId,
	J.JobName,
	J.JobSummary,
	C.ClientCode + '' - '' + C.ClientName Client,
	D.ClientCode + '' - '' +D.ClientName Division,
	LC.LookupName Classification,
	LS.LookupName JobStatus,
	J.IsQuote ,
	J.IsCancelled,
	J.IsPickup,
	U.Names CreatedBy,
	J.CreatedOn,
	a.Assignee,
	UI.Names InsertionBy,
	J.InsertionGeneratedOn InsertionOn
FROM @tblFinalJobId t
INNER JOIN CWI_Job J
	ON J.ID = t.SearchJobId
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
INNER JOIN 
(
	SELECT p1.AssigneeJobId,Stuff(
	( SELECT Assignee  + '',''
		FROM @tblAssginee p2
		WHERE p2.AssigneeJobId = p1.AssigneeJobId
		ORDER BY Assignee
		FOR XML  PATH(''''),type ).value(''.'', ''nvarchar(max)'') 
		, 1, 0, '''') AS Assignee
	FROM @tblAssginee p1
	GROUP BY AssigneeJobId 
) a
	ON a.AssigneeJobId = J.ID
LEFT OUTER JOIN CWI_User UI
	ON UI.Id = J.InsertionGeneratedBy


SET NOCOUNT OFF







' 
END
GO


