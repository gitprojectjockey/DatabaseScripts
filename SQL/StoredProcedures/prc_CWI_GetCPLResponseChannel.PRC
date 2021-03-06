/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLResponseChannel]    Script Date: 9/22/2014 7:38:20 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCPLResponseChannel]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCPLResponseChannel]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCPLResponseChannel]    Script Date: 9/22/2014 7:38:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCPLResponseChannel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCPLResponseChannel
* Purpose : This PROC would be called TO fetch response channels
* Invoked from : Profile_ResponseTranslation.aspx  
* CREATED: Vijesh Mahi
* CREATED ON : 18-Sep-2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetCPLResponseChannel 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCPLResponseChannel]    
   
AS
BEGIN
	
	BEGIN TRY
		
			Select Id,Channel
			From [dbo].[CWI_CPL_ResponseChannel]
			where IsActive=1

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	




' 
END
GO
