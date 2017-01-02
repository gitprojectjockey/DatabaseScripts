    Declare @EmployeeTotal int
	Execute spGetEmployeeCountByGender 'Female', @EmployeeTotal output
	Print @EmployeeTotal



	--View the information about the stored procedure, like parameter names, their datatypes etc. sp_help can be used with any database object, like tables, 
	--views, SP's, triggers etc. Alternatively, you can also press ALT+F1, when the name of the object is highlighted.
	Execute sp_help spGetEmployeeCountByGender

	--View the Text of the stored procedure
	Execute sp_helptext spGetEmployeeCountByGender


	--View the dependencies of the stored procedure. This system SP is very useful, especially if you want to check, if there are any stored procedures that 
	--are referencing a table that you are abput to drop. sp_depends can also be used with other database objects like table etc.
	Execute sp_depends tblEmployee

	--View the Text of an objects indexes
	Execute sp_helpIndex tblEmployee