declare @json nvarchar(max) =
--Put Json Array Here--
'

'
  DECLARE @AccountID int;
  DECLARE @RandomCompanyID int;
  DECLARE @AccountName varchar(100);
  DECLARE @accountCursor CURSOR



SET @accountCursor = CURSOR FOR
SELECT Account.AccountId,
       Account.Name
FROM   Account


 INSERT INTO Account 
 (IsActive,Balance,Age,Name,Gender,Company,Email,Phone,Address,About,Registered,Latidude,Longitude,CompanyID)  
 select isActive,balance,age,name,gender,company,email,phone,address,about,convert(date,registered,126),latitude,longitude,companyID FROM OPENJSON(@json)
 WITH (
       isActive bit,
	   balance decimal(16, 2),
       age int,
	   name nvarchar(200), 
       gender nvarchar(5),
	   company nvarchar(200),
	   email  nvarchar(200), 
	   phone nvarchar(50),
	   address nvarchar(500),
	   about nvarchar(MAX),
	   registered datetime,
	   latitude decimal(9, 6),
	   longitude decimal(9, 6),
	   companyID int
	   );


OPEN @accountCursor
FETCH NEXT
FROM @accountCursor INTO  @AccountID, @AccountName

WHILE @@FETCH_STATUS = 0
	BEGIN
		   INSERT INTO Friend (Name,Email,Greeting,AccountId)
		   select
			JSON_Value (p.value, '$.name') as Name,
			JSON_Value (p.value, '$.email') as Name,
			JSON_Value (p.value, '$.greeting') as Name,
			 @AccountID
			FROM OPENJSON(@json) as c
			CROSS APPLY OPENJSON (c.value,'$.friends') as p
			where JSON_Value (c.value, '$.name') = @AccountName

		FETCH NEXT FROM @accountCursor INTO @AccountID, @AccountName
	END	

CLOSE @accountCursor
DEALLOCATE  @accountCursor