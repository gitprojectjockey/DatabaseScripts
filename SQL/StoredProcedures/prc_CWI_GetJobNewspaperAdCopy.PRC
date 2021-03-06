/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobNewspaperAdCopy]    Script Date: 5/14/2014 3:13:15 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobNewspaperAdCopy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobNewspaperAdCopy]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobNewspaperAdCopy]    Script Date: 5/14/2014 3:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobNewspaperAdCopy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobNewspaperAdCopy 
* Purpose : This PROC would be called to retrieve the adcopy details for a newspaper job
* Invoked from : AdCopy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetJobNewspaperAdCopy 3
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetJobNewspaperAdCopy]
@inJobNewspaperId bigint
AS
BEGIN

	BEGIN TRY
		SELECT	JobId,ISNULL(AdCopyContent,'''') AS AdCopyContent,ISNULL(AdCopyPath,'''') AS AdCopyPath,
		ISNULL(AdCopyFileName,'''') AS AdCopyFileName,ISNULL([AdCopyVersion],0.00) AS[AdCopyVersion],
		[AdCopyCreatedBy],[AdCopyCreatedOn],U.Names AS Author
		FROM [dbo].[CWI_JobNewspaper] N
		INNER JOIN CWI_User AS U ON N.AdCopyCreatedBy=U.Id
		WHERE 	--Id = @inJobNewspaperId		
		JobId = @inJobNewspaperId
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	


' 
END
GO
