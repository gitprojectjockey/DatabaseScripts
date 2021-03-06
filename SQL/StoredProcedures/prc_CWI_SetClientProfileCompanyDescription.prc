/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileCompanyDescription]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfileCompanyDescription')
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileCompanyDescription]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileCompanyDescription]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileCompanyDescription 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile company description
* Invoked from : Profile_CompanyDescription.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileCompanyDescription NULL,1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileCompanyDescription]	
	@inClientId int,
	@vcCompanyDistinguish varchar(max)=NULL,
	@vcDriversWorkReason varchar(max)=NULL,
	@bitIsSingleDriverTruck bit=NULL,
	@vcCompanyDescription varchar(max)=NULL, 
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY		
			IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfile] WHERE ClientID=@inClientId)
			BEGIN				
					INSERT INTO [dbo].[CWI_ClientProfile]
					([ClientID],[CompanyDistinguish],[DriversWorkReason],[IsSingleDriverTruck],[CompanyDescription],
					[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
					VALUES
					(@inClientId,@vcCompanyDistinguish,@vcDriversWorkReason,@bitIsSingleDriverTruck,@vcCompanyDescription,
					GETDATE(),@inUserId,GETDATE(),@inUserId)												
			END
			ELSE
			BEGIN
				UPDATE [dbo].[CWI_ClientProfile]
				SET [CompanyDistinguish]=@vcCompanyDistinguish,[DriversWorkReason]=@vcDriversWorkReason,
					[IsSingleDriverTruck]=@bitIsSingleDriverTruck,[CompanyDescription]=@vcCompanyDescription,
					[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
				WHERE [ClientID]=@inClientId				
			END	
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)		
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
GO
