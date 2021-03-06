IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLookupById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetLookupById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetLookupById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetLookupById  
* Purpose : This PROC would be called TO get the looup for Id
* Invoked from : All pages that contain dropdown controls
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
prc_CWI_GetLookupById	1
**********************************************************************
*/

CREATE PROCEDURE [dbo].[prc_CWI_GetLookupById]
	@ID int
AS
SELECT Id,
LookupTypeId,
LookupName  FROM Lookup
Where ID = @ID' 
END
GO
