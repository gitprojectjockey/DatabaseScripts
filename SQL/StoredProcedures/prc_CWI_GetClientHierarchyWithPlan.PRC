/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientHierarchyWithPlan]    Script Date: 9/23/2013 8:44:31 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientHierarchyWithPlan]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientHierarchyWithPlan]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientHierarchyWithPlan]    Script Date: 9/23/2013 8:44:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientHierarchyWithPlan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientHierarchyWithPlan
* Purpose : This PROC would be called TO get client/division hierarchy with plan details
* Invoked from : Jobs.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClientHierarchyWithPlan 13957
  
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetClientHierarchyWithPlan]
	@ClientId int -- Division
AS

DECLARE @tbl TABLE
(
	ClientId int,
	ClientCode varchar(10),
	ClientName varchar(300),
	ParentId int,
	PlanId int,
	PlanName varchar(255)
)

INSERT INTO @tbl
(ClientId,ClientCode, ClientName, ParentID)
SELECT Id, ClientCode, ClientName, ParentID FROM CWI_Client WHERE Id = @ClientId
 
DECLARE @ParentId int
SET @ParentId = NULL
SELECT top 1 @ParentId = ParentId FROM @tbl

IF @ParentId IS NULL -- Client passed
begin
	INSERT INTO @tbl
	(ClientId,ClientCode, ClientName, ParentID)
	SELECT Id, ClientCode, ClientName, ParentID 
	FROM dbo.CWI_Client AS C			
		WHERE C.ParentID=@ClientId

	
end
ELSE
begin -- Division passed
	INSERT INTO @tbl
	(ClientId,ClientCode, ClientName, ParentID)
	SELECT Id, ClientCode, ClientName, ParentID  from CWI_Client
	WHERE Id = @ParentId

	
	INSERT INTO @tbl
	(ClientId,ClientCode, ClientName, ParentID)
	SELECT Id, ClientCode, ClientName, ParentID 
	FROM dbo.CWI_Client AS C			
	WHERE C.ParentID=@ParentId
		AND Id <> @ClientId
	
end



;WITH cte AS
(


   SELECT *,
         ROW_NUMBER() OVER (PARTITION BY DivisionID ORDER BY MarketingPlanID DESC) AS rn
   FROM (
   select C.ClientId DivisionID, 
   C.ParentId ParentId,
		M.Id as MarketingPlanID,
			C.ClientCode + '' - '' + C.ClientName as DivisionName,
			M.PlanName,
			format(M.PlanFrom,''MM/yyyy'') + '' - '' + format(M.PlanTo,''MM/yyyy'') as PlanTerm,
			M.PlanFrom,
			M.PlanTo,
			isnull(M.JobCount,0) as JobCount,
			ISNULL(BudgetForecast,0) as	BudgetForecast, 
			ISNULL(BudgetAvailable,0) as BudgetTotalValue,
			ISNULL(BudgetUsed,0) as BudgetUsedValue,	
			ISNULL(BudgetCommitted,0) as BudgetCommitted,
			--U.Names as CreatedBy,
			FORMAT(M.CreatedOn, ''MM/dd/yy hh:mm'') as CreatedOn
    from @tbl C
		LEFT OUTER  JOIN CWI_MarketingPlan M
			ON C.ClientId = M.DivisionID
				AND getdate() between PlanFrom and PlanTo
		CROSS APPLY [dbo].[fnc_GetDivisionMonthlyBudget](M.DivisionId, M.PlanFrom, M.PlanTo) B
		) xz
) 

SELECT *
FROM cte
WHERE rn = 1
ORDER BY CASE WHEN MarketingPlanID IS NULL THEN -1 ELSE 0 END DESC, DivisionName' 
END
GO


