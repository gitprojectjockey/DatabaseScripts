IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMarketingPlans]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetMarketingPlans]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMarketingPlans]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetMarketingPlans
* Purpose : This PROC would be called TO get Marketing Plans either created by in the passed in UserID or
						related from within the Client Team RelationShip
* Invoked from : MarketingPlan.aspx
* CREATED: Ajay Thacker
* CREATED ON : 12May2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetMarketingPlans @inUserId=21
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetMarketingPlans]    
    @inUserId int
	
AS
BEGIN
	BEGIN TRY

		
		
		Select
			 M.Id as MarketingPlanID,
			M.DivisionID,
			C1.ClientCode + '' - '' + C1.ClientName as DivisionName,
			Parent.ClientCode + '' - '' + Parent.ClientName as ClientName,
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
			FORMAT(M.CreatedOn, ''MM/dd/yy hh:mm'') as CreatedOn
		FROM CWI_MarketingPlan M
			inner join CWI_Client C1
				on M.DivisionID = C1.ID
			inner join CWI_Client Parent
				on C1.ParentID = Parent.ID
			inner join CWI_User U
				ON U.Id = M.CreatedBy
			CROSS APPLY [dbo].[fnc_GetDivisionMonthlyBudget](M.DivisionId, M.PlanFrom, M.PlanTo) B
			--LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B 				ON B.ClientID = C1.Id AND B.[HierarchyId] = C1.HierarchyTypeLookupID

		WHERE 
			M.CreatedBy = @inUserId
			and M.IsDeleted = 0

		union


		Select 
			M.Id as MarketingPlanID,
			M.DivisionID,
			C1.ClientCode + '' - '' + C1.ClientName as DivisionName,
			Parent.ClientCode + '' - '' + Parent.ClientName as ClientName,
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
			FORMAT(M.CreatedOn, ''MM/dd/yy hh:mm'') as CreatedOn
		FROM 
			CWI_ClientTeamRelationShip CTR
				inner join CWI_Client C1
					on C1.ID = CTR.ClientID and CTR.UserId = @inUserId
									and C1.ClientStatusLookupID != 504 --InActive
									and CTR.RelationshipActivateDate <= getdate()
									and isnull(CTR.RelationshipInActivateDate,''1/1/3000'') >= getdate()
				inner join CWI_MarketingPlan M
					on M.DivisionID = CTR.ClientID
			inner join CWI_Client Parent
				on C1.ParentID = Parent.ID
			inner join CWI_User U
											 ON U.Id = M.CreatedBy
			and M.IsDeleted = 0
			CROSS APPLY [dbo].[fnc_GetDivisionMonthlyBudget](M.DivisionId, M.PlanFrom, M.PlanTo) B
			--LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C1.Id AND B.[HierarchyId] = C1.HierarchyTypeLookupID

		order by ClientName

	
		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	

' 
END
GO
