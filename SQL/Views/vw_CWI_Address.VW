/****** Object:  View [dbo].[vw_CWI_Address]    Script Date: 6/19/2013 4:27:11 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_Address]'))
DROP VIEW [dbo].[vw_CWI_Address]
GO
/****** Object:  View [dbo].[vw_CWI_Address]    Script Date: 6/19/2013 4:27:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_Address]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vw_CWI_Address]
AS
SELECT 
	A.* ,
	C.CountryCode,
	C.CountryName,
	S.StateCode,
	S.StateName
FROM CWI_Address A (NOLOCK)
INNER JOIN Country C (NOLOCK) ON A.CountryID = C.ID
INNER JOIN State S (NOLOCK)  ON A.StateID = S.ID' 
GO
