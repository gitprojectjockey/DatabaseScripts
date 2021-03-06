/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionMarkupClassification]    Script Date: 11/19/2013 7:22:50 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionMarkupClassification]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDivisionMarkupClassification]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionMarkupClassification]    Script Date: 11/19/2013 7:22:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionMarkupClassification]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetDivisionMarkupClassification 
* Purpose : This PROC would be called to retrieve the markup percentage for the selected media buy classification
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE         AUTHOR          DESCRIPTION              
18-11-2013     Vijesh Mahi
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetDivisionMarkupClassification 14180,401
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetDivisionMarkupClassification]
@inClientID int,
@inClassificationId int
AS
BEGIN
	BEGIN TRY

		SELECT	CASE WHEN ISNULL(cc.MarkupPct,-1.00) = -1.00  
		THEN (SELECT ISNULL(MarkupPct,0) FROM CWI_Client WHERE ID = @inClientID)		
		ELSE CC.MarkupPct
		END AS MarkupPct,
		COALESCE(CC.RoundToLookupID,3005) AS RoundToLookupID 
		FROM  CWI_ClientClassification CC
		WHERE CC.ClientID = @inClientID AND CC.ClassificationLookupID=@inClassificationId			

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
END
' 
END
GO
