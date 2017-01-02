--Inner Join-- Join tables return all the matching rows. Non-matching rows are eliminated.
SELECT [Name],[Gender],[Salary],[DepartmentName],[DepartmentHead] 
FROM [dbo].[tblEmployee] 
INNER JOIN tblDepartment ON
tblEmployee.DepartmentId = tblDepartment.ID 

--Left Outer Join-- Join tables and return all the matching rows + NON-matching rows from the left table. 
SELECT [Name],[Gender],[Salary],[DepartmentName],[DepartmentHead] 
FROM [dbo].[tblEmployee] 
LEFT JOIN tblDepartment ON
tblEmployee.DepartmentId = tblDepartment.ID 

--Right Outer Join-- Join tables and return all the matching rows + NON-matching rows from the right table. 
SELECT [Name],[Gender],[Salary],[DepartmentName],[DepartmentHead] 
FROM [dbo].[tblEmployee] 
RIGHT JOIN tblDepartment ON
tblEmployee.DepartmentId = tblDepartment.ID 

--Full Outer Join--Join tables return all rows from both the left and right tables, including the non matching rows.
SELECT [Name],[Gender],[Salary],[DepartmentName],[DepartmentHead] 
FROM [dbo].[tblEmployee] 
FULL JOIN tblDepartment ON
tblEmployee.DepartmentId = tblDepartment.ID 


