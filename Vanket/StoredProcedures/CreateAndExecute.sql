Create Procedure spGetEmployees
as
Begin
  Select Name, Gender from tblEmployee
End

EXECUTE spGetEmployees 