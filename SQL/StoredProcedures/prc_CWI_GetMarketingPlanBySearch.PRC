IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMarketingPlanBySearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetMarketingPlanBySearch]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMarketingPlanBySearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetMarketingPlanBySearch  
* Purpose : This PROC would be called TO do advanced search in marketing plan
* Invoked from : marketingplan.aspx
* CREATED: MohanKumar Sundaram 
* CREATED ON:  07/26/2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetMarketingPlanBySearch  @ClientCode varchar(50) = ''''
 @ClientName varchar(255) = ''''
 @DivisionCode varchar(50) = ''''
 @DivisionName varchar(255) = ''''
 @FromDate datetime = NULL
 @ToDate datetime = ''2013-07-31''
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetMarketingPlanBySearch]
    @ClientCode varchar(50),
	 @ClientName varchar(255),
	 @DivisionCode varchar(50),
	 @DivisionName varchar(255),
	 @FromDate datetime = NULL,
	 @ToDate datetime = NULL
AS
 

BEGIN

	DECLARE @IsDateSearch bit = 0

	IF @FromDate IS NOT NULL OR @ToDate IS NOT NULL
	BEGIN
		SET @IsDateSearch = 1
		IF @FromDate IS NULL
		begin
			SET @FromDate = ''2005-01-01''
		end
		IF @ToDate IS NULL
		begin
			SET @ToDate = ''2300-01-31''
		end

	END

	IF @IsDateSearch = 0
BEGIN
	select 
		M.Id as MarketingPlanID,
		M.DivisionID,
		D.ClientCode + '' - '' + D.ClientName as DivisionName,
		C.ClientCode + '' - '' + C.ClientName as ClientName,
		M.PlanName,
		format(M.PlanFrom,''MM/yyyy'') + '' - '' + format(M.PlanTo,''MM/yyyy'') as PlanTerm,
		M.PlanFrom,
		M.PlanTo,
		isnull(M.JobCount,0) as JobCount,
		ISNULL(BudgetForecast,0) as	BudgetForecast, 
		ISNULL(BudgetAvailable,0) as BudgetTotalValue,
		ISNULL(BudgetUsed,0) as BudgetUsedValue,	
		ISNULL(BudgetCommitted,0) as BudgetCommitted,
		U.Names as CreatedBy,
		FORMAT(M.CreatedOn, ''MM/dd/yy hh:mm tt'') as CreatedOn 
	from CWI_MarketingPlan M
	INNER JOIN CWI_Client D
		ON M.DivisionID = D.ID
	INNER JOIN CWI_Client C
		ON D.ParentID = C.ID
	inner join CWI_User U
		ON U.Id = M.CreatedBy
	CROSS APPLY [dbo].[fnc_GetDivisionMonthlyBudget](M.DivisionId, M.PlanFrom, M.PlanTo) B
	WHERE
		M.IsDeleted =0 AND
		(C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'' AND 
		 D.ClientCode LIKE +''%''+@DivisionCode+''%'' AND D.ClientName LIKE +''%''+@DivisionName+''%'')
END
ELSE
BEGIN
	select 
		M.Id as MarketingPlanID,
		M.DivisionID,
		D.ClientCode + '' - '' + D.ClientName as DivisionName,
		C.ClientCode + '' - '' + C.ClientName as ClientName,
		M.PlanName,
		format(M.PlanFrom,''MM/yyyy'') + '' - '' + format(M.PlanTo,''MM/yyyy'') as PlanTerm,
		M.PlanFrom,
		M.PlanTo,
		isnull(M.JobCount,0) as JobCount,
		ISNULL(BudgetForecast,0) as	BudgetForecast, 
		ISNULL(BudgetAvailable,0) as BudgetTotalValue,
		ISNULL(BudgetUsed,0) as BudgetUsedValue,	
		ISNULL(BudgetCommitted,0) as BudgetCommitted,
		U.Names as CreatedBy,
		FORMAT(M.CreatedOn, ''MM/dd/yy hh:mm tt'') as CreatedOn 
	from CWI_MarketingPlan M
	INNER JOIN CWI_Client D
		ON M.DivisionID = D.ID
	INNER JOIN CWI_Client C
		ON D.ParentID = C.ID
	inner join CWI_User U
		ON U.Id = M.CreatedBy
	CROSS APPLY [dbo].[fnc_GetDivisionMonthlyBudget](M.DivisionId, M.PlanFrom, M.PlanTo) B
	WHERE
		M.IsDeleted =0 AND
		(C.ClientCode like +''%''+@ClientCode+''%'' AND C.ClientName like +''%''+@ClientName+''%'' AND 
		 D.ClientCode LIKE +''%''+@DivisionCode+''%'' AND D.ClientName LIKE +''%''+@DivisionName+''%'')
		 AND
		 (
			M.PlanFrom >= @FromDate AND M.PlanTo <= @ToDate
		 )
END

END

' 
END
GO


