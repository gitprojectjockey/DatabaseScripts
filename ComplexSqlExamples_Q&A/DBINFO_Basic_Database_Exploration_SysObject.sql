--Basic Database Exploration
--The sys.objects system table is one of the key system tables for gathering a lot of information
--on the objects that comprise your data model, with SYS.OBJECT.TYPE being the key column on which to filter.

--AF = Aggregate function (CLR)
--P = SQL Stored Procedure
--TA = Assembly (CLR) DML trigger
--C = CHECK constraint
--PC = Assembly (CLR) stored-procedure
--TF = SQL table-valued-function
--D = DEFAULT (constraint or stand-alone)
--PG = Plan guide
--TR = SQL DML trigger
--F = FOREIGN KEY constraint
--PK = PRIMARY KEY constraint
--TT = Table type
--FN = SQL scalar function
--R = Rule (old-style, stand-alone)
--U = Table (user-defined)
--FS = Assembly (CLR) scalar-function
--RF = Replication-filter-procedure
--UQ = UNIQUE constraint
--FT = Assembly (CLR) table-valued function
--S = System base table
--V = View
--IF = SQL inline table-valued function
--SN = Synonym
--X = Extended stored procedure
--IT = Internal table
--SQ = Service queue

--Listing out all user-defined tables in a database

SELECT  *
	FROM    sys.objects
	WHERE   type = 'U'; 