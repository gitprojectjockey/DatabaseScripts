SELECT [City] , SUM([Salary]) as TotalSalaryByCity FROM [dbo].[Employees] Group by City
SELECT [City],[Gender], SUM([Salary]) as TotalSalaryByCityAndGender FROM [dbo].[Employees] Group by City,Gender
SELECT [City],[Gender], SUM([Salary]) as TotalSalaries , COUNT(Id) as EmployeeCount FROM [dbo].[Employees] Group by City,Gender

--Filtering rows using WHERE clause, before aggrgations take place:
SELECT [City],[Gender], SUM([Salary]) as TotalSalaries , COUNT(Id) as EmployeeCount FROM [dbo].[Employees]
WHERE UPPER(City) = 'BOSTON'
Group by City,Gender

--Filtering rows using Having clause, after aggrgations take place:
SELECT [City],[Gender], SUM([Salary]) as TotalSalaries , COUNT(Id) as EmployeeCount FROM [dbo].[Employees]
Group by City,Gender
HAVING UPPER(City) = 'BOSTON'

SELECT [City],[Gender], SUM([Salary]) as TotalSalaries , COUNT(Id) as EmployeeCount FROM [dbo].[Employees]
WHERE UPPER(Gender) = 'MALE'
Group by City,Gender
HAVING UPPER(City) = 'BOSTON'
