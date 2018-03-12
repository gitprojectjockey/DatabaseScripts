--Note: A CTE can be thought of as a temporary result set that is defined within the 
--execution scope of a single SELECT, INSERT, UPDATE, DELETE, or CREATE VIEW statement. 
--A CTE is similar to a derived table in that it is not stored as an object and lasts only 
--for the duration of the query.

WITH EmployeeSalesCount(EmployeeName,EmployeeId,SalesCount)
AS
(
   Select e.LastName, e.EmployeeId, Count(es.EmployeeSaleId) as SalesCount
   From Employee e
   inner join EmployeeSales es
   on e.EmployeeId = es.EmployeeId
   group by e.LastName, e.EmployeeId
)
Select * from EmployeeSalesCount where
SalesCount > 3


