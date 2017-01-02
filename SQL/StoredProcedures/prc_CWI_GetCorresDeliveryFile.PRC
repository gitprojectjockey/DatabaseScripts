/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorresDeliveryFile]    Script Date: 9/25/2014 8:03:43 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorresDeliveryFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorresDeliveryFile]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorresDeliveryFile]    Script Date: 9/25/2014 8:03:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorresDeliveryFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetCorresDeliveryFile 
* Purpose : This PROC would be called TO get correspondence delivery file 
* Invoked from : CorrespondenceService
* CREATED: MohanKumar Sundaram 09SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetCorresDeliveryFile 407
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetCorresDeliveryFile]
	@CorresDeliveryId bigint
AS
	
	DECLARE @corresFolder varchar(100) = ''Correspondence\''
	DECLARE @finaladcopyFolder varchar(100) = ''CreativeAdCopies\''

	SELECT
		CASE WHEN CHARINDEX(@corresFolder, FilePath) = 0
			THEN @finaladcopyFolder+ SUBSTRING(FilePath,CHARINDEX(@finaladcopyFolder, FilePath) + LEN(@finaladcopyFolder),1000)
			ELSE	@corresFolder+ SUBSTRING(FilePath,CHARINDEX(@corresFolder, FilePath) + LEN(@corresFolder),1000) END FilePath,
			[File]
	FROM CWI_CorrespondenceDelivery CD
	WHERE Id = @CorresDeliveryId
	

	




' 
END
GO


