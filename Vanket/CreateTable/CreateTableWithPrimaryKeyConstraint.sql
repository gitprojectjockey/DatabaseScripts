Create Table dbo.[Cart]
(
  [Id] int identity(1,1) NOT NULL,
  [ClientId] nvarchar(50) NOT NULL,
  [ProductId] int NOT NULL,
  [Amount] int NOT NULL,
  [DatePurchased] DATETIME DEFAULT GETDATE(),
  [IsInCart] bit NOT NULL,
  CONSTRAINT [PK_Purchase] PRIMARY KEY CLUSTERED (Id ASC)

)
