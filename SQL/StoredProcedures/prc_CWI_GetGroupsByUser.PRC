/****** Object:  StoredProcedure [dbo].[prc_CWI_GetGroupsByUser]    Script Date: 10/7/2014 6:18:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetGroupsByUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetGroupsByUser]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetGroupsByUser]    Script Date: 10/7/2014 6:18:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetGroupsByUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetGroupsByUser  
* Purpose : This PROC would be called TO get the groups for the user
* Invoked from : Clientwise.master.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetGroupsByUser ''msundaram'',''oss''
  
**********************************************************************/ 
  
CREATE PROCEDURE  [dbo].[prc_CWI_GetGroupsByUser]
    @Login	varchar(100),
	@Domain	varchar(100)
AS
     

select distinct G.GroupName,G.Id from CWI_UserGroup UG
INNER JOIN CWI_User U
	ON U.Id = UG.UserID
INNER JOIN CWI_Group G
	ON G.Id = UG.GroupID
WHERE
	U.Login = @Login
	AND U.Domain = @Domain
	AND U.IsActive= 1
	AND G.IsActive= 1
	AND G.GroupName <> ''''

	 ' 
END
GO


