USE [SocialNetwork]
GO

/****** Object:  Table [dbo].[Account]    Script Date: 12/23/2016 11:56:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Account](
	[AccountID] [int] IDENTITY(1,1) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Balance] [decimal](16, 2) NOT NULL,
	[Age] [int] NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Gender] [nvarchar](5) NULL,
	[Email] [nvarchar](200) NOT NULL,
	[Phone] [nvarchar](50) NULL,
	[Address] [nvarchar](500) NULL,
	[About] [nvarchar](max) NULL,
	[Registered] [datetime] NOT NULL,
	[Latidude] [decimal](9, 6) NULL,
	[Longitude] [decimal](9, 6) NULL,
 CONSTRAINT [PK_Accounts_AccountId] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Accounts_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


