/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPasswordRules]    Script Date: 9/2/2014 5:27:32 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPasswordRules]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetPasswordRules]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPasswordRules]    Script Date: 9/2/2014 5:27:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPasswordRules]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetPasswordRules  
* Purpose : This PROC would be called TO get the password rules
* Invoked from : ClientPortalAccess.aspx
* CREATED: MohanKumar Sundaram 02SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetPasswordRules
  
**********************************************************************/ 
  

CREATE PROCEDURE [dbo].[prc_CWI_GetPasswordRules]
AS
SELECT * FROM CWI_PasswordRule' 
END
GO


