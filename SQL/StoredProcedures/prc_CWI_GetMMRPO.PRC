/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMMRPO]    Script Date: 1/10/2014 3:03:20 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMMRPO]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetMMRPO]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMMRPO]    Script Date: 1/10/2014 3:03:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMMRPO]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetMMRPO]  
* Purpose : This PROC would be called to get the MMRPO
* Invoked from : Jobs.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetMMRPO] 
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetMMRPO] 
	
AS
BEGIN
	
	SELECT 
	distinct(JM.MMRPO),
	J.ID as JobId,
	JM.ID MediaBuyId
FROM 	
	CWI_JobMediaBuy JM
INNER JOIN 	
	CWI_Job J ON j.ID=JM.JobId and ISNULL(JM.MMRPO,0) >0 
--Inner Join
--	CWI_JobMediaBuyRundateTemplateData JMTD ON JMTD.MediaBuyId=JM.ID
END
' 
END
GO
