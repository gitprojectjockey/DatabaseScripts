
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GetEmployeeFullName
  @EmployeeId int = 0,
  @FullName nvarchar(100) OUT

  AS
  BEGIN
    Select ISNULL(CAST(e.FirstName AS VARCHAR(50)),'') + ' ' +  
	ISNULL(CAST(e.LastName AS VARCHAR(50)),'') as EmployeeName
	from Employee e
	where e.EmployeeId = @EmployeeId
  END