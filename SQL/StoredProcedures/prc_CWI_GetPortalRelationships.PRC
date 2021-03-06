/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPortalRelationships]    Script Date: 9/10/2014 8:31:44 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPortalRelationships]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetPortalRelationships]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPortalRelationships]    Script Date: 9/10/2014 8:31:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPortalRelationships]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetPortalRelationships  
* Purpose : This PROC would be called TO get the corporate/client/division details for the passed client email
* Invoked from : ClientPortalAccess.aspx
* CREATED: MohanKumar Sundaram 02SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetPortalRelationships @email = ''test@test.com''
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetPortalRelationships]
	@email varchar(100)
AS
select 
	CC.Id,
	CC.ClientId,
	C.ClientCode,
	C.ClientName,
	LH.LookupName Hierarchy,
	CC.IsCWPortalUser HasAccess
from CWI_ClientContact CC
INNER JOIN CWI_Client C
	ON C.Id = CC.ClientId 
INNER JOIN Lookup LH
	ON LH.Id = C.HierarchyTypeLookupID
where 
	CC.IsDeleted = 0
	AND email =  @email 
ORDER BY LH.SortOrder


' 
END
GO


