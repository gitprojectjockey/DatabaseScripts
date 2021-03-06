IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_ClientSummaryBudget]'))
DROP VIEW [dbo].[vw_CWI_ClientSummaryBudget]
GO

CREATE VIEW vw_CWI_ClientSummaryBudget

AS
select 
	ID,
	ClientID,
	521 [HierarchyId],
	BudgetName,
	BudgetForecast,
	BudgetUsed,
	BudgetCommitted,
	BudgetAvailable,
	BudgetFrom,
	BudgetTo,
	RevisionId,
	CreatedBy,
	CreatedOn,
	ModifiedBy,
	ModifiedOn,
	IsActive 
from 
	CWI_ClientBudget CB
WHERE
	CAST(getdate() as date)  between BudgetFrom AND BudgetTo
UNION ALL
select 
	ID,
	DivisionID,
	522 [HierarchyId],
	BudgetName,
	BudgetForecast,
	BudgetUsed,
	BudgetCommitted,
	BudgetAvailable,
	BudgetFrom,
	BudgetTo,
	RevisionId,
	CreatedBy,
	CreatedOn,
	ModifiedBy,
	ModifiedOn,
	IsActive
from 
	CWI_DivisionBudget DB
WHERE
	CAST(getdate() as date)  between BudgetFrom AND BudgetTo

GO