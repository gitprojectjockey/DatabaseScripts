/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPlanClassSummary]    Script Date: 11/3/2014 3:33:49 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPlanClassSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetPlanClassSummary]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPlanClassSummary]    Script Date: 11/3/2014 3:33:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPlanClassSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetPlanClassSummary 
* Purpose : This PROC would be called to return the classification summary of plan
* Invoked from : MarketingPlan.aspx.cs
* CREATED: MohanKumar 05SEP13
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
 prc_CWI_GetPlanClassSummary 11

**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_GetPlanClassSummary]
	@PlanId int,
	@InvoiceDate datetime = null
AS


	
	DECLARE @DivisionId int  = NULL, 
			@PlanFrom datetime = NULL, 
			@PlanTo datetime = NULL

	SELECT 
		@DivisionId = MP.DivisionID,
		@PlanFrom = MP.PlanFrom,
		@PlanTo = MP.PlanTo
	FROM CWI_MarketingPlan MP
	WHERE MP.Id = @PlanId

	SELECT * FROM
	(
		SELECT 
			''C'' + CAST(C.Id AS VARCHAR(15)) Id,
			C.LookupName DisplayName,
			C.IsActive,
			ISNULL(BudgetForecast,0) as	BudgetForecast, 
			ISNULL(BudgetAvailable,0) as BudgetAvailable,
			ISNULL(BudgetUsed,0) as BudgetUsed,	
			ISNULL(BudgetCommitted,0) as BudgetCommitted,
			ISNULL(CJ.JobCount,0) JobCount,
			ISNULL(CJ.StatusJobCount,0) JobStatusCount,
			ISNULL(CJ.CompleteJobCount,0) CompleteJobCount,
			ISNULL(CJ.InCompleteJobCount,0) InCompleteJobCount
		FROM vw_CWI_Classification C
		LEFT OUTER JOIN 
			fnc_CWI_GetJobClassCount(@PlanId, @InvoiceDate) CJ ON CJ.ClassificationId = C.Id
		CROSS APPLY [dbo].[fnc_GetDivisionMonthlyClassBudget](@DivisionId, @PlanFrom, @PlanTo, C.Id) B
		--UNION ALL
		--SELECT 
		--	''S'' + CAST(S.Id AS VARCHAR(15)) Id,
		--	S.ServiceName DisplayName,
		--	S.IsActive,
		--	ISNULL(BudgetForecast,0) as	BudgetForecast, 
		--	ISNULL(BudgetAvailable,0) as BudgetAvailable,
		--	ISNULL(BudgetUsed,0) as BudgetUsed,	
		--	ISNULL(BudgetCommitted,0) as BudgetCommitted,
		--	0 JobCount,
		--	''''
		--FROM CWI_Service S
		--CROSS APPLY [dbo].[fnc_GetDivisionMonthlyServiceBudget](@DivisionId, @PlanFrom, @PlanTo, S.Id) B
	) t
	
	WHERE
		IsActive = 1 OR
		(
		IsActive = 0 AND
		(
			BudgetForecast <> 0 OR
			BudgetAvailable <> 0 OR
			BudgetUsed <> 0 OR
			BudgetCommitted <> 0 
		)
		)
	ORDER BY t.Id


 







' 
END
GO


