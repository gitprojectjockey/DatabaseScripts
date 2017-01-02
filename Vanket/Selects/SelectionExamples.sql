SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Age > 33
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Age != 33
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Age IN (33,53)
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Age NOT IN (33,53)
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Age BETWEEN 33 and 53
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Name LIKE 'S%'
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Email LIKE '%@%'

Select DISTINCT Age,Gender from Person

--This will get me any row where email has one char before and after the @ symbol folowed by .com.
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Email LIKE '_@_.com'
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Email LIKE '____@Snap.com'

--This will get any name the starts with M or S or T
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Name LIKE '[MST]%'

--This will get any name the does NOT starts with M or S or T
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where Name LIKE '[^MST]%'

SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Where (Age != 33 AND Name LIKE '[MST]%' AND Gender = 2) 

SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] order by Age DESC
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] order by Gender, Age ASC
SELECT [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] order by Name DESC, Age ASC

Select TOP 3 Name, Age from Person
Select TOP 50 PERCENT Name, Age from Person
--************************************* Find the eldest person in the list ******************************
SELECT TOP 1 [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Order by Age DESC
--************************************* Find the youngest person in the list ******************************
SELECT TOP 1 [Id],[Name],[Email],[Gender],[Age] FROM [Vanket].[dbo].[Person] Order by Age ASC




