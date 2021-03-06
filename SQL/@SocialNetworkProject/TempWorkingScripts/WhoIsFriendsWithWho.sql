/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [FriendID]
      ,[FriendName]
      ,[FriendEmail]
      ,[Greeting]
      ,[AccountID]
      ,Friend.[CompanyID]
	  ,Company.CompanyName
  FROM [SocialNetwork].[dbo].[Friend]
  inner join Company
  on Friend.CompanyID = company.CompanyID
  where Company.CompanyName='ECSTASIA'

  SELECT 
	   Account.[AccountID]
      ,[Balance]
      ,[Name] as 'Name On Account'
      ,[Email]
      ,Account.[CompanyID]
  FROM [SocialNetwork].[dbo].[Account]
  inner join Company on 
  Account.CompanyId = Account.CompanyID
  where Company.CompanyID =108
  and account.CompanyID = 108
  