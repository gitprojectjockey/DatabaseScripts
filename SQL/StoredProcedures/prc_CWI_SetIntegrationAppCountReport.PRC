/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationAppCountReport]    Script Date: 9/10/2014 2:03:17 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetIntegrationAppCountReport' )
 DROP PROCEDURE [dbo].[prc_CWI_SetIntegrationAppCountReport]
GO


/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationAppCountReport]    Script Date: 9/10/2014 2:03:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************************************************************  
* PROCEDURE: prc_CWI_SetIntegrationAppCountReport
* Purpose : This PROC would be called to insert/update a row into [CWI_Integration_AppCount_Report] table
* Invoked from : <TBD>
* CREATED: Jorge Maldonado
* MODIFICATION HISTORY  
* DATE            AUTHOR          DESCRIPTION              
  09/08/2014
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_SetIntegrationAppCountReport '','','','','','',0,0,'','',0,0,1
********************************************************************************************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetIntegrationAppCountReport]
	@PaperEmail VARCHAR(500)
    ,@PaperPhone VARCHAR(50)
    ,@CliCode VARCHAR(10)
    ,@PaperName VARCHAR(100)
    ,@ClientName VARCHAR(100)
    ,@AdDescription VARCHAR(500)
    ,@BannerClicks BIGINT
    ,@Apps BIGINT
    ,@By VARCHAR(10)
    ,@Comments VARCHAR(500)
    ,@Year INT
    ,@Month INT
    ,@UserID INT
AS
BEGIN

	BEGIN TRY

	SET NOCOUNT ON;

	INSERT INTO [dbo].[CWI_Integration_AppCount_Report]
			([PaperEmail]
			,[PaperPhone]
			,[CliCode]
			,[PaperName]
			,[ClientName]
			,[AdDescription]
			,[BannerClicks]
			,[Apps]
			,[By]
			,[Comments]
			,[Year]
			,[Month]
			,[CreatedBy]
			,[CreatedOn])
		 VALUES
			(@PaperEmail
			,@PaperPhone
			,@CliCode 
			,@PaperName 
			,@ClientName
			,@AdDescription 
			,@BannerClicks 
			,@Apps 
			,@By 
			,@Comments 
			,@Year 
			,@Month 
			,@UserID 
			,GETDATE())
	
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
END

