/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientImages]    Script Date: 2/25/2014 7:42:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientImages]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientImages]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientImages]    Script Date: 2/25/2014 7:42:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientImages]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientImages 
* Purpose : This PROC would be called to retrieve the images for a given client from supporting document
* Invoked from : AdCopy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientImages 15335
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientImages]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		DECLARE @inParentID INT

		SET @inParentID = (SELECT ParentID FROM CWI_Client WHERE ID=@inClientId)
		
		SELECT FilePath FROM dbo.CWI_SupportingDocument
		WHERE ObjectID IN (@inClientId,@inParentID) AND ObjectLookupID=202
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	

' 
END
GO
