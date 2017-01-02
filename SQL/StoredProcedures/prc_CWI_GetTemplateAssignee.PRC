/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTemplateAssignee]    Script Date: 9/25/2014 9:00:13 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTemplateAssignee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetTemplateAssignee]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetTemplateAssignee]    Script Date: 9/25/2014 9:00:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetTemplateAssignee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetTemplateAssignee
* Purpose : This PROC would be called TO get the assigness for template
* Invoked from : Template.aspx
* CREATED: Mohankumar Sundaram  18 SEP 2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetTemplateAssignee 1
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetTemplateAssignee]
	@TemplateId bigint
AS
	SELECT 
		
		UserId,
		GroupId,
		U.Names UserName,
		G.GroupName,
		IsCopied,
		IsRemoved,
		TA.CreatedBy,
		TA.CreatedOn,
		TA.ModifiedBy,
		TA.ModifiedOn 
	FROM  CWI_TemplateAssignee TA
	LEFT OUTER JOIN CWI_User U ON U.id = TA.UserId 
	LEFT OUTER JOIN CWI_Group G ON G.id = TA.GroupId
	WHERE TemplateId = @TemplateId
	AND TA.IsRemoved = 0



' 
END
GO


