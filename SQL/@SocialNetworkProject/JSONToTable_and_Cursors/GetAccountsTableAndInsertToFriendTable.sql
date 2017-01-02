 USE [SocialNetwork]

  DECLARE @AccountID int;
  DECLARE @FriendAccountID int;
  DECLARE @FriendName varchar(100);
  DECLARE @FriendEmail varchar(200);
  DECLARE @FriendCompanyID int;
  DECLARE @FriendGreeting varchar(500);
  DECLARE @Index int;

  DECLARE @MainAccountCurser CURSOR;
  DECLARE @RandomAccountCurser CURSOR;
 

  SET @MainAccountCurser = CURSOR FOR
  SELECT [AccountID]
  FROM [SocialNetwork].[dbo].[Account]
  ORDER BY AccountID;

  OPEN @MainAccountCurser

FETCH NEXT FROM @MainAccountCurser INTO  @AccountID
  WHILE @@FETCH_STATUS = 0
  BEGIN
		 
		SET @RandomAccountCurser = CURSOR FOR
		SELECT TOP 4 AccountID, Name,Email,CompanyID FROM Account
		WHERE AccountID <> @AccountID
		ORDER BY NEWID()

        OPEN @RandomAccountCurser;
		Set @Index = 0;
		FETCH NEXT FROM @RandomAccountCurser INTO @FriendAccountID, @FriendName, @FriendEmail, @FriendCompanyID;
		WHILE @@CURSOR_ROWS > @Index
		BEGIN
			SET @FriendGreeting = 'Hello ' + @FriendName + ', Hope you are have a great day!';
		    INSERT INTO dbo.Friend(FriendName,FriendEmail,Greeting,AccountID,FriendAccountID,Friend.CompanyID)VALUES(@FriendName,@FriendEmail, @FriendGreeting, @AccountID, @FriendAccountID,@FriendCompanyID);
			FETCH NEXT FROM @RandomAccountCurser INTO @FriendAccountID, @FriendName, @FriendEmail, @FriendCompanyID;
			Set @Index =  @Index + 1;
		END
		CLOSE @RandomAccountCurser
        DEALLOCATE @RandomAccountCurser
     FETCH NEXT FROM  @MainAccountCurser INTO @AccountID
 END	

CLOSE @MainAccountCurser
DEALLOCATE @MainAccountCurser 
