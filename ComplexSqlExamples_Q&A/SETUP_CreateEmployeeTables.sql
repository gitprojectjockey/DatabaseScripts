USE [Interview]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------
IF  EXISTS(SELECT * 
          FROM INFORMATION_SCHEMA.TABLES 
          WHERE TABLE_SCHEMA = 'dbo' 
          AND  TABLE_NAME = 'EmployeeSales')
BEGIN
    DROP TABLE EmployeeSales;
END

IF  EXISTS(SELECT * 
          FROM INFORMATION_SCHEMA.TABLES 
          WHERE TABLE_SCHEMA = 'dbo' 
          AND  TABLE_NAME = 'Employee')
BEGIN
    DROP TABLE Employee;
END

IF  EXISTS(SELECT * 
          FROM INFORMATION_SCHEMA.TABLES 
          WHERE TABLE_SCHEMA = 'dbo' 
          AND  TABLE_NAME = 'EmployeeRegion')
BEGIN
    DROP TABLE EmployeeRegion;
END
GO
-----------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[EmployeeRegion](
  RegionId int IDENTITY(1,1) NOT NULL,
  RegionName nvarchar(100) NOT NULL,
  RegionalOfficeState varchar(2) NULL 
  PRIMARY KEY CLUSTERED 
 (
	[RegionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

------------------------------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[Employee](
	[EmployeeId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[LastName] [nvarchar](255) NOT NULL,
	[Salary] [decimal](16, 2) NULL,
	[YearsEmployed] [int] NULL,
	[Gender] [varchar](5) NULL,
	[LastSalesAmtUpdate][DateTime] NULL DEFAULT NULL,
	[RegionId] [int] FOREIGN KEY REFERENCES EmployeeRegion(RegionId) NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LastName] ON [dbo].[Employee]
(
	[LastName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

----------------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[EmployeeSales](
	[EmployeeSaleId] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [int] FOREIGN KEY REFERENCES Employee(EmployeeId) ON DELETE CASCADE NOT NULL,
	[SaleDate][Date] NOT NULL,
	[SaleAmount][Decimal](16,2) NOT NULL
	PRIMARY KEY CLUSTERED
(
	[EmployeeSaleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
	
GO

CREATE NONCLUSTERED INDEX [IDX_EmployeeId] ON [dbo].[EmployeeSales]
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeSales] WITH CHECK ADD CONSTRAINT
    PositiveNumberOnly CHECK (([SaleAmount] >= 0))
GO

---------------------------------------------------------------------------------------------------------
Insert Into EmployeeRegion(RegionName,RegionalOfficeState)Values('WEST','CA')
Insert Into EmployeeRegion(RegionName,RegionalOfficeState)Values('MID-WEST','NE')
Insert Into EmployeeRegion(RegionName,RegionalOfficeState)Values('SOUTH-WEST','TX')
Insert Into EmployeeRegion(RegionName,RegionalOfficeState)Values('SOUTH-EAST','SC')
Insert Into EmployeeRegion(RegionName,RegionalOfficeState)Values('NORTH-EAST','MA')

---------------------------------------------------------------------------------------------------------
DECLARE @lastInsertedEmployeeId as int
DECLARE @saleDate as DateTime

--Insert into Employee Table
insert into Employee (FirstName,LastName,Salary,YearsEmployed,Gender,RegionId)values('Sam','Tatum',92000.00,1,'M',5)

--Get emp id from last insert
SELECT @lastInsertedEmployeeId = (SELECT IDENT_CURRENT ('Employee') AS Current_Identity)

--Get date and add some days
SELECT @saleDate = (SELECT DATEADD(DAY,10,GETDATE()))

--Insert emp sales records
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,1000.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,4499.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,1100.56)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,1435.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,8999.99)



-----------------------------------------------------------------------------------------------------------------------
 --CREATE DUPLICATES
--Insert into Employee Table
insert into Employee (FirstName,LastName,Salary,YearsEmployed,Gender,RegionId)values('Pete','Sampson',101000.00,12,'M',4)

 --Get emp id from last insert
SELECT @lastInsertedEmployeeId = (SELECT IDENT_CURRENT ('Employee') AS Current_Identity)
--Get date and add some days
SELECT @saleDate = (SELECT DATEADD(DAY,44,GETDATE()))

--Insert emp sales records
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,1001.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,4494.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,1111.56)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,1500.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,6587.99)

-------------------------------------------------------------------------------------------------------------------------

--Insert into Employee Table

insert into Employee (FirstName,LastName,Salary,YearsEmployed,Gender,RegionId)values('Kelly','Tango',34000.00,11,'F',3)

 --Get emp id from last insert
SELECT @lastInsertedEmployeeId = (SELECT IDENT_CURRENT ('Employee') AS Current_Identity)
--Get date and add some days
SELECT @saleDate = (SELECT DATEADD(DAY,10,GETDATE()))

--Insert emp sales records
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,2001.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,2494.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,5111.56)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,9500.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,6687.99)
-------------------------------------------------------------------------------------------------------------------------

--Insert into Employee Table
insert into Employee (FirstName,LastName,Salary,YearsEmployed,Gender,RegionId)values('Patsy','Kline',56999.00,5,'F',2)

 --Get emp id from last insert
SELECT @lastInsertedEmployeeId = (SELECT IDENT_CURRENT ('Employee') AS Current_Identity)
--Get date and add some days
SELECT @saleDate = (SELECT DATEADD(DAY,44,GETDATE()))

--Insert emp sales records
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,2345.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,5555.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,7895.56)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,2244.99)

----------------------------------------------------------------------------------------------------------------------

--Insert into Employee Table
insert into Employee (FirstName,LastName,Salary,YearsEmployed,Gender,RegionId)values('Taco','Time',52000.00,3,'M',1)

 --Get emp id from last insert
SELECT @lastInsertedEmployeeId = (SELECT IDENT_CURRENT ('Employee') AS Current_Identity)
--Get date and add some days
SELECT @saleDate = (SELECT DATEADD(DAY,13,GETDATE()))

--Insert emp sales records
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,345.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,555.99)


----------------------------------------------------------------------------------------------------------------------

--Insert into Employee Table
insert into Employee (FirstName,LastName,Salary,YearsEmployed,Gender,RegionId)values('Billy','Kid',42000.00,6,'M',1)

 --Get emp id from last insert
SELECT @lastInsertedEmployeeId = (SELECT IDENT_CURRENT ('Employee') AS Current_Identity)
--Get date and add some days
SELECT @saleDate = (SELECT DATEADD(DAY,13,GETDATE()))

--Insert emp sales records
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,345.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,555.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,222.99)

----------------------------------------------------------------------------------------------------------------------

--Insert into Employee Table
insert into Employee (FirstName,LastName,Salary,YearsEmployed,Gender,RegionId)values('Patty','Hearst',99000.00,14,'F',2)

 --Get emp id from last insert
SELECT @lastInsertedEmployeeId = (SELECT IDENT_CURRENT ('Employee') AS Current_Identity)
--Get date and add some days
SELECT @saleDate = (SELECT DATEADD(DAY,13,GETDATE()))

--Insert emp sales records
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,9999.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,2222.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,1111.99)

----------------------------------------------------------------------------------------------------------------------

--Insert into Employee Table
insert into Employee (FirstName,LastName,Salary,YearsEmployed,Gender,RegionId)values('Robert','Slappy',102000.00,11,'M',3)

 --Get emp id from last insert
SELECT @lastInsertedEmployeeId = (SELECT IDENT_CURRENT ('Employee') AS Current_Identity)
--Get date and add some days
SELECT @saleDate = (SELECT DATEADD(DAY,13,GETDATE()))

--Insert emp sales records
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,3456.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,22566.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,8765.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,5609.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,1234.99)
Insert Into EmployeeSales (EmployeeID,SaleDate,SaleAmount) values(@lastInsertedEmployeeId,@saleDate,4321.99)
