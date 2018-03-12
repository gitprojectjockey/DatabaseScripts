--Get N Highest Salary Sub Query
--In this case I am getting the second highest salary
Select Distinct e.Salary 
From Employee e
Where 3 = (Select Count(Distinct e2.Salary) 
			From Employee e2
			where e.Salary <= e2.Salary
) 