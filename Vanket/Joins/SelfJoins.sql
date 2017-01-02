SELECT E.Name,M.Name as Manager
FROM [dbo].[tblEmployeeManager] E
INNER JOIN [dbo].[tblEmployeeManager] M
ON E.ManagerID = M.ID

SELECT E.Name,M.Name as Manager
FROM [dbo].[tblEmployeeManager] E
LEFT JOIN [dbo].[tblEmployeeManager] M
ON E.ManagerID = M.ID


