--Find Duplicate Rows
select e1.*, e1.EmployeeId from Employee e1
where EmployeeId !=
(
  select Max(employeeid) from Employee e2 
  where e1.FirstName = e2.FirstName
  and e1.LastName = e2.LastName
)