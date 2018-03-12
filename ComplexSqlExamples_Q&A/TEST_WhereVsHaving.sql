--SELECT
--FROM
--WHERE
--GROUP BY
--HAVING
--To help keep things straight I like to think of the order of execution of SQL statements as from top to bottom.  
--That means the WHERE clause is first applied to the result and then, the remaining rows summarized according to the GROUP BY.

--The WHERE clause
--The WHERE clause is used to filter rows from a results.

--The HAVING Clause
--The HAVING clause is used to filter values in a GROUP BY

--When SQL statements have both a WHERE clause and HAVING clause, keep in mind the 
--WHERE clause is applied first, then the results grouped, 
--and finally the groups filtered according to the HAVING clause.
--

Select e.LastName, SUM(es.SaleAmount) as TotalSales 
from  Employee e
inner join EmployeeSales es
on e.EmployeeId = es.EmployeeId
where es.SaleDate > getdate()
Group By e.EmployeeId, e.LastName
Having Sum(es.SaleAmount) >= 24000

