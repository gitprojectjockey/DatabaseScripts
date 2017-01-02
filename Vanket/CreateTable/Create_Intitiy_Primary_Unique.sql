Create Table MasterZipCodesDenver(
	CodeId int Identity(1,1) Primary Key,
	CodeName nvarchar(50),
	Code nvarchar(5)
)
Alter Table  MasterZipCodesDenver Add Constraint UQ_MasterZipCodesDenver_Code Unique(Code)

Create Table MasterZipCodesCastleRock(
	CodeId int Identity(1,1) Primary Key,
	CodeName nvarchar(50),
	Code nvarchar(5)
)

Alter Table MasterZipCodesCastleRock Add Constraint UQ_MasterZipCodesCastleRock_Code Unique(Code)