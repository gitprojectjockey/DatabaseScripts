/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobContact]    Script Date: 2/14/2014 2:46:27 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobContact]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobContact]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobContact]    Script Date: 2/14/2014 2:46:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobContact]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: [prc_CWI_GetJobContacts]  
* Purpose : This PROC would be called TO get all the contacts for the contact id
* Invoked from : jobs.aspx
* CREATED: BALA
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetJobContact] (226,227)
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetJobContact]
    @Contact varchar(5000) 

AS
	SELECT 
		CC.Id as ContactID,
		CC.Email
	FROM CWI_ClientContact CC
	WHERE CC.ID IN (Select items From fnc_SplitCommaSeparatedValuesIntoTable(@Contact,'',''))



' 
END
GO
