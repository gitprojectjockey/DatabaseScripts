Create Procedure spGetEmployeesByGenderAndDepartment 
	@Gender nvarchar(50),
	@DepartmentId int
as
Begin
  Select Name, Gender from tblEmployee Where Gender = @Gender and DepartmentId = @DepartmentId
End

EXECUTE spGetEmployeesByGenderAndDepartment 'Male', 1

