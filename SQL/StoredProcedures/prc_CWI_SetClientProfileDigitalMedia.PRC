/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileDigitalMedia]    Script Date: 8/5/2014 5:25:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileDigitalMedia]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileDigitalMedia]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileDigitalMedia]    Script Date: 8/5/2014 5:25:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileDigitalMedia]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileHiringLocation 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client digital profile details
* Invoked from : Profile_DigitalMedia.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
04Aug2014	Vijesh   

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileDigitalMedia NULL,14174,''www.celedon.com'',1,7
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileDigitalMedia]
	@inDigitalMediaId int=NULL,
	@inClientId int,
	@vcDomainUrl varchar(50)=NULL,
	@inSiteType int=NULL,
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN
BEGIN TRY
		IF @inDigitalMediaId is not null
		BEGIN	
			Update CWI_ClientProfileDigitalMedia 
			set [SiteTypeId]=@inSiteType,[DomainUrl]=@vcDomainUrl,
				[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
			where Id=@inDigitalMediaId

			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)				
		END
		else
		BEGIN												
					
			INSERT INTO [dbo].[CWI_ClientProfileDigitalMedia]
			([ClientID],[SiteTypeId],[DomainUrl],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy],[IsDelete])					
			values
			(@inClientId,@inSiteType,@vcDomainUrl,
			GETDATE(),@inUserId,GETDATE(),@inUserId,0)	
				
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
				
		END				
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

' 
END
GO
