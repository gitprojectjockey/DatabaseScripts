/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCLimitAndTransCount]    Script Date: 7/31/2014 7:30:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCLimitAndTransCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVCLimitAndTransCount]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVCLimitAndTransCount]    Script Date: 7/31/2014 7:30:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVCLimitAndTransCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**********************************************************************************************  
* PROCEDURE: [prc_CWI_GetVCLimitAndTransactionCount]
* Purpose : This PROC would be called to get the default virtaul card CC limit and transaction countdetails
* Invoked from : ManageVirtualCard.aspx
* CREATED: Vijesh 24JUL14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

*************************************************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetVCLimitAndTransCount] @MediaBuyId  = 3294
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetVCLimitAndTransCount] 
	@MediaBuyId bigint 
AS
BEGIN
	BEGIN TRY
		SELECT TOP 1 
			CC.CCLimit,ISNULL(CC.TransCount,0) as TransCount
		FROM COMDATACommunicationControl CC (NOLOCK)
		WHERE CC.SettlementID=@MediaBuyId 
		ORDER BY CreatedDateTime DESC 
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END


' 
END
GO
