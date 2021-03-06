/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteAssociatedClient]    Script Date: 9/12/2014 1:51:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteAssociatedClient]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteAssociatedClient]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteAssociatedClient]    Script Date: 9/12/2014 1:51:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteAssociatedClient]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteAssociatedClient 
* Purpose : This PROC would be called to delete the assoicated client
* Invoked from : AssociatedClient.aspx
* CREATED: Vijesh 10-Oct-2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_DeleteAssociatedClient 16 , 1122
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_DeleteAssociatedClient]       
@inCorporateId int,
@inClientId int,
@inUserId int  
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION Trans1
		BEGIN TRY
		
			Update [dbo].[CWI_ClientAssociation]
			set [IsRemoved]=1, 
			[ModifiedOn]=getdate(),
			[ModifiedBy]=@inUserId
			where ClientId=@inClientId and [CoporateId]=@inCorporateId and IsRemoved=0

		END TRY
		BEGIN CATCH	  
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
			EXEC prc_CWI_AppRaiseError;
			THROW;
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END' 
END
GO
