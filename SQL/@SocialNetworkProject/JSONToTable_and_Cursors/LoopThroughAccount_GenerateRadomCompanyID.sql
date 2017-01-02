 USE [SocialNetwork]

  DECLARE @AccountID int;
  DECLARE @RandomCompanyID int;
  DECLARE @MainAccountCurser CURSOR;
 

  SET @MainAccountCurser = CURSOR FOR
  select  AccountID from Account
  order by AccountId
  OPEN @MainAccountCurser

FETCH NEXT
FROM @MainAccountCurser INTO  @AccountID
--Loop Through all Account records and Update CompanyId--
  WHILE @@FETCH_STATUS = 0
  BEGIN
	  --GRAB Random CompanyID from Company Table
		Set  @RandomCompanyID  = (SELECT TOP 1 CompanyID FROM Company ORDER BY NEWID());
		Update dbo.Account set CompanyID  = @RandomCompanyID
		where account.AccountID = @AccountID
		FETCH NEXT FROM  @MainAccountCurser INTO @AccountID
 END	



CLOSE @MainAccountCurser
DEALLOCATE @MainAccountCurser 


