USE [SocialNetwork]
GO

/****** Object:  Table [dbo].[Friend]    Script Date: 12/23/2016 11:56:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Friend](
	[FriendID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](200) NOT NULL,
	[Greeting] [nvarchar](500) NULL,
	[AccountID] [int] NOT NULL,
 CONSTRAINT [PK_Friend] PRIMARY KEY CLUSTERED 
(
	[FriendID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Friend]  WITH CHECK ADD  CONSTRAINT [FK_Friend_Account] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Account] ([AccountID])
GO

ALTER TABLE [dbo].[Friend] CHECK CONSTRAINT [FK_Friend_Account]
GO


