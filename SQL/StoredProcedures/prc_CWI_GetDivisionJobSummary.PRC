/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionJobSummary]    Script Date: 11/8/2013 5:43:23 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionJobSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDivisionJobSummary]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionJobSummary]    Script Date: 11/8/2013 5:43:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionJobSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



/*******************************************************************  
* PROCEDURE: prc_CWI_GetDivisionJobSummary
* Purpose : This PROC would be called TO display the job summary details in tree view
* Invoked from : jobs.aspx 
* CREATED: MohanKumar Sundaram 11/05/2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
28/5/2014  Vijesh		Modified for checking plan term
**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetDivisionJobSummary @DivsionId=14180,@PlanId=1
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetDivisionJobSummary]
    @DivsionId int,
    @PlanId int
AS
    

	DECLARE @tbl TABLE
	(
		ParentId int,
		Id varchar(100),
		Detail varchar(max)
	)

	declare @url varchar(100)
	

	INSERT INTO @tbl
	Select 
		J.ClassificationId,  --CAST(J.ClassificationId as varchar(20)) ParentId,
		CAST(J.ClassificationId as varchar(20)) + ''_'' + CAST(J.id as varchar(20)) Id,
		''<a href="javaScript:void OpenJobWindow('' + CAST(J.id as varchar(20)) + '') '' + ''">'' + CAST(J.id as varchar(max)) + ''</a>-'' +  ISNULL(j.JobName,'''') + ''-''
		+ FORMAT ( ISNULL(J.InvoiceDate,''''), ''d'', ''en-US'' ) + ''-'' + SL.LookupName Detail
		
	from CWI_Job J
	INNER JOIN CWI_MarketingPlan M
		ON J.MarketingPlanId = M.Id AND M.DivisionID = @DivsionId
	INNER JOIN Lookup SL
		ON Sl.Id = J.JobStatusLookupId
	WHERE M.ID=@PlanId

		
	SELECT 
		cast(t.ParentId as varchar(100)) ParentId,
		t.Id,
		t.Detail 
	FROM @tbl t
	UNION ALL
	SELECT 
		NULL ParentId,CAST(VC.Id as varchar(20)) Id, VC.LookupName + '' ('' + CAST(ISNULL(J.JobCount,''0'') as VARCHAR(20)) + '' job(s) )'' Detail
	FROM
	(
		select ParentId, count(*) JobCount from @tbl
		GROUP BY ParentId
	)
	 J
	RIGHT OUTER JOIN  vw_CWI_Classification VC
		ON VC.Id = J.ParentId AND VC.IsActive = 1
	

' 
END
GO


