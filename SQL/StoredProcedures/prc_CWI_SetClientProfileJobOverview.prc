/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileJobOverview]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfileJobOverview')
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileJobOverview]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileJobOverview]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileJobOverview 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile company description
* Invoked from : Profile_CompanyDescription.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileJobOverview 14174,'looking for drivers','1,3','4,5',7
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileJobOverview]	
	@inClientId int,
	@vcJobOverview varchar(max)=NULL,
	@vcRoute varchar(max)=NULL,	
	@vcHiringPosition varchar(max)=NULL, 
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY		
			IF @vcJobOverview IS NOT NULL
			BEGIN
				IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfile] WHERE ClientID=@inClientId)
				BEGIN									
					INSERT INTO [dbo].[CWI_ClientProfile] 
					([ClientID],[JobOverview],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
					VALUES
					(@inClientId,@vcJobOverview,GETDATE(),@inUserId,GETDATE(),@inUserId)
				END
				ELSE
				BEGIN
					UPDATE [dbo].[CWI_ClientProfile]
					SET [JobOverview]=@vcJobOverview,[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
					WHERE [ClientID]=@inClientId
				END	
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)																
			END

			IF EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfileRoute] WHERE ClientID=@inClientId)
			BEGIN	
				DELETE FROM [dbo].[CWI_ClientProfileRoute] WHERE [ClientID]=@inClientId	
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
			END	
			IF @vcRoute IS NOT NULL
			BEGIN								
				INSERT INTO [dbo].[CWI_ClientProfileRoute]
				([ClientID],[RouteID],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])					
				SELECT @inClientId,Items,
				GETDATE(),@inUserId,GETDATE(),@inUserId   FROM  dbo.fnc_SplitCSVIntoTableUsingCTE(@vcRoute,',')
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)		
			END			

			IF EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfileHiringPosition] WHERE ClientID=@inClientId)
			BEGIN
				DELETE FROM [dbo].[CWI_ClientProfileHiringPositionDetail] WHERE [ProfilePositionID] IN 
				(SELECT [ID] FROM [dbo].[CWI_ClientProfileHiringPosition] WHERE  [ClientID]=@inClientId)
				DELETE FROM [dbo].[CWI_ClientProfileHiringPosition] WHERE [ClientID]=@inClientId
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
			END

			IF @vcHiringPosition IS NOT NULL
			BEGIN								
				INSERT INTO [dbo].[CWI_ClientProfileHiringPosition]
				([ClientID],[HiringPositionID],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])					
				SELECT @inClientId,Items,
				GETDATE(),@inUserId,GETDATE(),@inUserId  FROM  dbo.fnc_SplitCSVIntoTableUsingCTE(@vcHiringPosition,',')
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)		
			END			
				
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
GO
