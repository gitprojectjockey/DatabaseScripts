--Left Outer Join-- Join tables and return all the matching rows + NON-matching rows from the left table. 
SELECT [Name],[Gender],[Salary],[DepartmentName],[DepartmentHead] 
FROM [dbo].[tblEmployee] 
LEFT JOIN tblDepartment ON
tblEmployee.DepartmentId = tblDepartment.ID 

--Replacing NULL value using ISNULL() function
SELECT [Name],[Gender],[Salary],IsNull([DepartmentName],'No Department') as 'Department Name',IsNull([DepartmentHead],'No Department Head' ) as 'Department Head'
FROM [dbo].[tblEmployee] 
LEFT JOIN tblDepartment ON
tblEmployee.DepartmentId = tblDepartment.ID 

--Replacing NULL value using Case statement
SELECT [Name],[Gender],[Salary], CASE WHEN D.DepartmentName IS NULL THEN 'No Department' ELSE D.DepartmentName END as DepartmentName
FROM [dbo].[tblEmployee] 
LEFT JOIN tblDepartment D ON
tblEmployee.DepartmentId = D.ID 

--Replacing NULL value using Coalesce() function
SELECT [Name],[Gender],[Salary], COALESCE(D.DepartmentName, 'No Department Name') as 'Department Name'
FROM [dbo].[tblEmployee] 
LEFT JOIN tblDepartment D ON
tblEmployee.DepartmentId = D.ID 
