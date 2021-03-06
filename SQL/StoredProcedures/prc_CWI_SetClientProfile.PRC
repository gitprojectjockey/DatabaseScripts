/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfile]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfile' )
 DROP PROCEDURE [dbo].[prc_CWI_SetClientProfile]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfile]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: [prc_CWI_SetClientProfile]
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile details for a specific client
* Invoked from : Client_Profile.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfile 
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfile]	
	@inClientId int,
	@vcClientProfile varchar(MAX),
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY
			
		UPDATE 	[dbo].[CWI_Client] 
		SET [ClientProfile]=@vcClientProfile, ModifiedBy=@inUserId, ModifiedOn=GETDATE()
		WHERE ID=@inClientId

		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)

	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
GO
