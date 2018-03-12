--Note: A CTE can be thought of as a temporary result set that is defined within the 
--execution scope of a single SELECT, INSERT, UPDATE, DELETE, or CREATE VIEW statement. 
--A CTE is similar to a derived table in that it is not stored as an object and lasts only 
--for the duration of the query.

WITH EmployeeCountPerRegion(Region_Name,Region_State,EmployeesPerRegion)
AS
(
  select er.RegionName,er.RegionalOfficeState,COUNT(e.EmployeeId) as EmployeesPerRegion
  from EmployeeRegion er
  inner join Employee e
  on er.RegionId = e.RegionId
  group by er.RegionName,er.RegionalOfficeState
)
Select * from EmployeeCountPerRegion
Order by EmployeesPerRegion