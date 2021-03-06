/****** Object:  StoredProcedure [dbo].[prc_CWI_SetResponseCallSourceStatus]    Script Date: 9/12/2014 3:44:16 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetResponseCallSourceStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetResponseCallSourceStatus]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetResponseCallSourceStatus]    Script Date: 9/12/2014 3:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetResponseCallSourceStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/****************************************************************************
* PROCEDURE: [CWI_ResponseCallSourceStatus]  
* Purpose : This PROC would be called TO insert CallSource Status details
* Invoked from : CallSource Service
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
********************************************************************************** */ 
CREATE PROC [dbo].[prc_CWI_SetResponseCallSourceStatus]
	@ResponseStatus varchar(50) = NULL,
	@StartDate datetime = NULL,
	@EndDate datetime = NULL
	
AS
BEGIN
	BEGIN TRY
		INSERT [CWI_ResponseCallSourceStatus](ResponseStatus, StartDate, EndDate, CreatedOn)
		VALUES (@ResponseStatus, @StartDate, @EndDate, getdate())
	END TRY
	BEGIN CATCH	  
			EXEC prc_CWI_AppRaiseError;
			THROW;
	END CATCH
END 

' 
END
GO
