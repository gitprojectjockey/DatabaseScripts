--Join Tables and Retrieve only the NON-matching rows from the left table.
SELECT [Name],[Gender],[Salary],[DepartmentName],[DepartmentHead]
FROM [dbo].[tblEmployee] E
LEFT JOIN [dbo].[tblDepartment] D ON
E.DepartmentId = D.ID
WHERE E.DepartmentId Is null 

--Join Tables and Retrieve only the NON-matching rows from the right table.
SELECT [Name],[Gender],[Salary],[DepartmentName],[DepartmentHead]
FROM [dbo].[tblEmployee] E
RIGHT JOIN [dbo].[tblDepartment] D ON
E.DepartmentId = D.ID
WHERE E.DepartmentId Is null 

--Join Tables and Retrieve all NON-matching rows from both tables.
SELECT [Name],[Gender],[Salary],[DepartmentName],[DepartmentHead]
FROM [dbo].[tblEmployee] E
FULL JOIN [dbo].[tblDepartment] D ON
E.DepartmentId = D.ID
WHERE E.DepartmentId Is null 


