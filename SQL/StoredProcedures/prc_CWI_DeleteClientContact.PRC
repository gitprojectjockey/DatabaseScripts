/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteClientContact]    Script Date: 6/19/2013 2:19:07 PM ******/

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_DeleteClientContact')
 
DROP PROCEDURE [dbo].[prc_CWI_DeleteClientContact]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteClientContact]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteClientContact  
* Purpose : This PROC would be called TO delete the client contact
* Invoked from : Client.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_DeleteClientContact 1, 3
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_DeleteClientContact]
    @ContactId int,
	@Author int
AS

	
	BEGIN TRY
		UPDATE CWI_ClientContact
		SET IsDeleted = 1, ModifiedBy =@Author, ModifiedOn = GETDATE()
		WHERE Id = @ContactId
	END TRY
	BEGIN CATCH
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH




GO
