/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientActivitySummary]    Script Date: 7/28/2014 5:47:51 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientActivitySummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientActivitySummary]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientActivitySummary]    Script Date: 7/28/2014 5:47:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientActivitySummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientActivitySummary   
* Purpose : This PROC would be called TO display client activity summary in dashboard
* Invoked from : dashboard.aspx
* CREATED: MohanKumar Sundaram	7/2/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  28JUL14	Mohankumar		Cost Collection count bug fiixed         

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClientActivitySummary 3
  
**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_GetClientActivitySummary] 
	@userId int 
AS


DECLARE @tblUserDivision TABLE
(
	ClientId int,
	ClientCode varchar(50),
	ClientName varchar(100),
	ParentId int
)
INSERT INTO @tblUserDivision
SELECT * FROM dbo.fnc_GetClientsForUser(@userId,''D'')

DECLARE @tblJob TABLE
(
	JobId bigint,
	DivisionId int,
	InvoiceDate date,
	JobStatusLookupId int,
	IsQuote bit,
	InvoiceApproveDate datetime
)


DECLARE @tblJMB TABLE
(
	JobId bigint,
	DivisionId int,
	InvoiceDate date,
	StatusId int, 
	IsCancelled bit, 
	IsQuote bit, 
	DNR bit,
	IsCostCollected bit
)



DECLARE @tblJobCount TABLE
(
	DivisionId int,
	InvoiceDate date,
	JB int default 0,
	[AS] int  default 0,
	IP int default 0,
	OH int default 0,
	JPI int default 0,
	AIA int default 0,
	MB int default 0,
	SF int default 0,
	CC int default 0

)

INSERT INTO @tblJob
(JobId, DivisionId,InvoiceDate, JobStatusLookupId , IsQuote, InvoiceApproveDate)
SELECT 
	J.Id JobId,
	J.DivisionId, 
	J.InvoiceDate,
	JobStatusLookupId,
	IsQuote,
	J.InvoiceGeneratedDate InvoiceApproveDate
	
 FROM CWI_Job (NOLOCK) J
	INNER JOIN @tblUserDivision UD
		ON UD.ClientId = J.DivisionId
	/* -- The following can be used to get the jobs created by the user and assing to the user and thier group
	LEFT OUTER JOIN	
		(
		 select distinct JobId from CWI_JobAssignee JA (NOLOCK)
		 WHERE (JA.UserID = @userId
		 OR
		 JA.GroupID IN (
		select GroupID from CWI_UserGroup  (NOLOCK) where UserId=@userId)
		)
		AND JA.IsRemoved = 0
		) JA
		ON JA.JobID = J.id

		*/
WHERE 
/*
(
	J.CreatedBy = @userId
	/* -- The following can be used to get the jobs created by the user and assing to the user and thier group
	OR UD.ClientId IS NOT NULL
	OR JA.JobID IS NOT NULL
	*/
)
AND 
*/J.JobStatusLookupId IN (8001/*In Progress*/,8012/* Assigned */, 8002 /* Awaiting Invoice Authorization */)


INSERT INTO @tblJMB
select JMB.JobId,J.DivisionId, J.InvoiceDate, JMB.StatusId, JMB.IsCancelled, J.IsQuote, JMB.DNR , 
	IsCostCollected = (CASE WHEN IsComplimentary=1 THEN  1
							WHEN IsComplimentary = 0 AND ActualCost>0 THEN 1
							ELSE 0 END)
from CWI_JobMediaBuy JMB (NOLOCK)
INNER JOIN @tblJob J
	ON j.JobId = JMB.JobId
WHERE
	IsRemoved = 0

SELECT 
	C.ClientCode + '' - '' + C.ClientName Division,
	J.*,
	ISNULL(JB.JB,0) JB,
	ISNULL([AS].[AS],0) [AS],
	ISNULL(IP.IP,0) IP,
	
	ISNULL(MB.MB,0) MB,
	ISNULL(JPI.JPI,0) JPI,
	ISNULL(CC.CC,0) CC,
	ISNULL(JS.SF,0) SF,
	ISNULL(AIA.AIA,0) AIA
FROM

(SELECT distinct DivisionId,InvoiceDate, InvoiceApproveDate FROM @tblJob 
)J
INNER JOIN CWI_Client C
	ON C.Id  =J.DivisionId
LEFT OUTER JOIN
(
SELECT DivisionId,InvoiceDate,
	COUNT(*) JB
FROM @tblJob group by DivisionId,InvoiceDate) JB
ON J.DivisionId = JB.DivisionId AND J.InvoiceDate = JB.InvoiceDate
LEFT OUTER JOIN
(
SELECT DivisionId,InvoiceDate,
	COUNT(*) [AS]
FROM @tblJob
WHERE JobStatusLookupId = 8012/* Assigned */ group by DivisionId,InvoiceDate) [AS]
ON J.DivisionId = [AS].DivisionId AND J.InvoiceDate = [AS].InvoiceDate
LEFT OUTER JOIN
(
SELECT DivisionId,InvoiceDate,
	COUNT(*) [IP]
FROM @tblJob
WHERE JobStatusLookupId = 8001/*In Progress*/ group by DivisionId,InvoiceDate
) [IP]

ON J.DivisionId = [IP].DivisionId AND J.InvoiceDate = [IP].InvoiceDate
LEFT OUTER JOIN
(
SELECT DivisionId,InvoiceDate,Count(*) MB FROM @tblJMB
WHERE IsCancelled = 0 
AND IsQuote = 0
AND DNR = 0
GROUP BY DivisionId,InvoiceDate
) MB
ON J.DivisionId = MB.DivisionId AND J.InvoiceDate = MB.InvoiceDate
LEFT OUTER JOIN
(
SELECT DivisionId,InvoiceDate,Count(distinct JobId) JPI FROM @tblJMB
WHERE StatusId = 20102 /* Selected */
GROUP BY DivisionId,InvoiceDate
) JPI
ON J.DivisionId = JPI.DivisionId AND J.InvoiceDate = JPI.InvoiceDate
LEFT OUTER JOIN
(
SELECT DivisionId,InvoiceDate,Count(*) CC FROM @tblJMB
WHERE IsCancelled = 0
AND DNR = 0
AND IsCostCollected = 0
GROUP BY DivisionId,InvoiceDate
) CC
ON J.DivisionId = CC.DivisionId AND J.InvoiceDate = CC.InvoiceDate
LEFT OUTER JOIN
(
SELECT DivisionId,InvoiceDate,count(*) SF FROM CWI_JobService JS (NOLOCK)
INNER JOIN @tblJob J
	ON j.JobId = JS.JobId
WHERE
	IsDeleted = 0
GROUP BY DivisionId,InvoiceDate
) JS
ON J.DivisionId = JS.DivisionId AND J.InvoiceDate = JS.InvoiceDate
LEFT OUTER JOIN
(
SELECT DivisionId,InvoiceDate,
	COUNT(*) AIA
FROM @tblJob
WHERE JobStatusLookupId = 8002/* Awaiting Invoice Approval */ 
and IsQuote=0
GROUP BY DivisionId,InvoiceDate) [AIA]
ON J.DivisionId = [AS].DivisionId AND J.InvoiceDate = [AS].InvoiceDate
ORDER BY J.DivisionId, J.InvoiceDate




' 
END
GO
