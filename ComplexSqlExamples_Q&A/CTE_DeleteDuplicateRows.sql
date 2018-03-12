--DELETE Records with Duplicate LastName,FirstName
With Result(LName,FName,RowNum)
As
(
	Select LastName,FirstName,ROW_NUMBER() Over (Partition by LastName ,FirstName order by LastName, FirstName) as RowNumber
	From Employee
)
Select LName,FName,RowNum From Result where RowNum > 1 
--Delete From Result where RowNum > 1 
