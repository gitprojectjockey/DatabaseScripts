


select SCOPE_IDENTITY()
--returns the last identity value that is CREATED in the same session(Connection) and in the same scope.
select @@IDENTITY
--returns the last identity value that is CREATED  in the same session(Connection) and across any scope.
Select IDENT_CURRENT('Test2')
--returns the last identity value that is CREATED for a specific table across any session(Connection) and any scope.




