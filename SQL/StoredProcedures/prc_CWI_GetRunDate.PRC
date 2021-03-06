/****** Object:  StoredProcedure [dbo].[prc_CWI_GetRunDate]    Script Date: 1/10/2014 3:03:20 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetRunDate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetRunDate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetRunDate]    Script Date: 1/10/2014 3:03:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetRunDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetRunDate 
* Purpose : This PROC would be called to get the Rundates
* Invoked from : Jobs.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetRunDate] @MMRPO=33, @JobId=111
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetRunDate] 
	@MMRPO Int,
	@JobId int
AS
BEGIN
	
	SELECT 
	
	JMTD.FieldValue as RunDate
FROM 	
	CWI_JobMediaBuy JM
INNER JOIN 	
	CWI_Job J ON j.ID=JM.JobId and ISNULL(JM.MMRPO,0) >0 
Inner Join
	CWI_JobMediaBuyRundateTemplateData JMTD ON JMTD.MediaBuyId=JM.ID AND J.ID=@JobId AND JM.MMRPO=@MMRPO
END
' 
END
GO
