IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VW_Menus]'))
DROP VIEW [dbo].[VW_Menus]
GO

/****** Object:  View [dbo].[VW_Menus]    Script Date: 4/25/2013 2:46:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_Menus]
AS

WITH MenuList(id, parentid, MenuCaption,MenuLocation,MenuPage, lvl, SortOrder) AS
(SELECT     id, parentid, MenuCaption,MenuLocation,MenuPage, 0 AS lvl,SortOrder
      FROM         CWI_Menu
      WHERE     (parentid IS NULL) and IsActive = 1
      UNION ALL
      SELECT     t1.id, t1.parentid, t1.MenuCaption,t1.MenuLocation,t1.MenuPage, h.lvl + 1 AS lvl, t1.SortOrder
      FROM         CWI_Menu AS t1 INNER JOIN
                            MenuList AS h ON t1.parentid = h.id WHERE  t1.IsActive = 1)
							

SELECT     id, parentid, MenuCaption,MenuLocation,MenuPage, lvl,SortOrder
FROM         MenuList AS result
GO

