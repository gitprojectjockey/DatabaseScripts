/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskFilter]    Script Date: 10/10/2014 9:22:08 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskFilter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTaskFilter]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTaskFilter]    Script Date: 10/10/2014 9:22:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTaskFilter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetTaskFilter 
* Purpose : This PROC would be called TO retrieve the filter values for the task grid column in dashboard page
* Invoked from : MyTasks.ascx
* CREATED: Vijesh  10/8/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTaskFilter	7	
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetTaskFilter]
@Author INT
As
Begin

	SELECT Id as FilterId, FilterColumn,FilterValue
	FROM CWI_TaskFilter 
	WHERE CreatedBy=@Author and IsRemoved=0

End
		



' 
END
GO
