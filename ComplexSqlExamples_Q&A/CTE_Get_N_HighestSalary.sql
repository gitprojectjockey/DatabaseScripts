With Result(Salary,D_Rank)
As
(
	Select Salary, DENSE_RANK() 
	Over(Order by Salary Desc) 
	From Employee
)
Select Salary From Result Where D_Rank = 5