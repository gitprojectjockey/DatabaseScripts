SET NOCOUNT ON

GO
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'OSS\comaccess')
DROP LOGIN [OSS\comaccess]
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'OSS\comaccess')
CREATE LOGIN [OSS\comaccess] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO

ALTER SERVER ROLE [serveradmin] ADD MEMBER [OSS\comaccess]
GO


IF NOT EXISTS(SELECT top 1 1 FROM CWI_User where id = 1)
BEGIN
	SET IDENTITY_INSERT [dbo].[CWI_User] ON 

	INSERT [dbo].[CWI_User] ([Id], [Login], [Domain], [Names], [Email], [IsActive], [LastLoggedIn], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) 
	VALUES (1, N'System', N'oss', N'System', N'ClientWiseAdmin@xerox.com', 0, NULL, N'oss\msundaram', getdate(), N'oss\msundaram', getdate())
	SET IDENTITY_INSERT [dbo].[CWI_User] OFF
END
GO

SET NOCOUNT OFF