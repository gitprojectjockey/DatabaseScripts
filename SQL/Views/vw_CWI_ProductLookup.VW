/****** Object:  View [dbo].[vw_CWI_ProductLookup]    Script Date: 6/19/2013 4:27:11 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_ProductLookup]'))
DROP VIEW [dbo].[vw_CWI_ProductLookup]
GO
/****** Object:  View [dbo].[vw_CWI_ProductLookup]    Script Date: 6/19/2013 4:27:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_ProductLookup]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vw_CWI_ProductLookup]
AS
SELECT * from Lookup WHERE LookupTypeId = 13' 
GO
