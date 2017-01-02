Create Procedure spGetEmployeeCountByGender
	@Gender nvarchar(20),
	@EmployeeCount int Output
	as
	Begin
		Select @EmployeeCount = COUNT(Id) from tblEmployee where Gender = @Gender
	End 

	Declare @EmployeeTotal int
	Execute spGetEmployeeCountByGender 'Female', @EmployeeTotal output
	Print @EmployeeTotal