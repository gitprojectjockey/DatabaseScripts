/****** Object:  View [dbo].[vw_CWI_ClientTeamRelation]    Script Date: 6/19/2013 4:27:11 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_ClientTeamRelation]'))
DROP VIEW [dbo].[vw_CWI_ClientTeamRelation]
GO
/****** Object:  View [dbo].[vw_CWI_ClientTeamRelation]    Script Date: 6/19/2013 4:27:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_ClientTeamRelation]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vw_CWI_ClientTeamRelation]
AS
select * from Lookup
where LookupTypeId = 14
' 
GO
