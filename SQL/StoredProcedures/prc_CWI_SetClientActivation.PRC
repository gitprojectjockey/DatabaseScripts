/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientActivation]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientActivation' )
 DROP PROCEDURE [dbo].[prc_CWI_SetClientActivation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientActivation]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientActivation
* Purpose : This PROC would be called TO Activate a client
				
* Invoked from : Client_Accounting.ascx  (from Client Accounting Tab)
* CREATED: Ajay Thacker
* CREATED ON : 3Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
Select * from CWI_ClientActivation
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetClientActivation]    
    @inClientID int,
	@vcActgXRef varchar(50),
	@inCreatedBy int
	

AS
BEGIN



	Declare @intClientStatusLookupID int,
					@vcRequestorDomainLoginName varchar(100)
	Set @intClientStatusLookupID = 502 --Active

	BEGIN TRANSACTION Trans1
	BEGIN TRY
		

				Set @vcRequestorDomainLoginName = (Select Names + ' - ' + Domain + '\' + [Login] from CWI_User
											where ID = @inCreatedBy)

		update CWI_Client
		set ActgXref =@vcActgXRef,
				ClientStatusLookupID = @intClientStatusLookupID,
				LastStatusModifiedBy = @inCreatedBy,
				LastStatusModifiedOn = getdate()
		where ID = @inClientID		

		Update CWI_ClientActivation
		Set ActivatedBy  = @inCreatedBy,
			ActivatedOn = getdate()
		where ClientID =@inClientID

		/*******************ACTIVATE DIVISION WHILE ACTIVATING CLIENT************************************/		
		UPDATE CWI_Client
		SET ActgXref =NULL,
				ClientStatusLookupID = @intClientStatusLookupID,
				LastStatusModifiedBy = @inCreatedBy,
				LastStatusModifiedOn = GETDATE()
		WHERE ID IN	(SELECT [ID] FROM [dbo].[CWI_Client] WHERE [ParentID]=@inClientID)
		
		Update CWI_ClientActivation
		Set ActivatedBy  = @inCreatedBy,
			ActivatedOn = getdate()
		where ClientID IN (SELECT [ID] FROM [dbo].[CWI_Client] WHERE [ParentID]=@inClientID)
		/************************************END************************************/


		DECLARE @systemuserid int
		SET @systemuserid = NULL
		SELECT @systemuserid = Id FROM CWI_User WHERE Names = 'System'
		IF @systemuserid IS NULL
		begin 
			SET @systemuserid = @inCreatedBy
		end

		
		insert into CWI_Comment
		(
		ObjectLookupId,
		ObjectId,
		Comment,
		CreatedOn,
		CreatedBy,
		ModifiedOn,
		ModifiedBy
		)
		values
		(
			202, --Client General
			@inClientID,
			'Client Activated by ' + @vcRequestorDomainLoginName,
			getdate(),
			@systemuserid,
			getdate(),
			@systemuserid
		)

			


	END TRY
	BEGIN CATCH	
	IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;

END
	


GO
