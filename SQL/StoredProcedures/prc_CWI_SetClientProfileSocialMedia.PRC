/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileSocialMedia]    Script Date: 7/24/2014 4:22:13 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileSocialMedia]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileSocialMedia]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileSocialMedia]    Script Date: 7/24/2014 4:22:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileSocialMedia]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileSocialMedia 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile company description
* Invoked from : Profile_SocialMedia.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileSocialMedia NULL,1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileSocialMedia]	
	@inClientId int,
	@vcFBEmail varchar(100),
	@vcFBPageUrl varchar(100),
	@vcFBGmailAddress varchar(100),
	@vcFBGmailPassword varchar(50),
	@vcFBAdId varchar(50),
	@vcFBAdAccountPassword varchar(50),
	@vcTwitterHandle varchar(max),
	@vcTwitterEmail varchar(100),
	@vcTwitterPassword varchar(50),
	@vcLinkedInUrl varchar(100),
	@vcYoutubeChannelUrl varchar(100),
	@vcYoutubeUserName varchar(50),
	@vcYoutubeEmail varchar(100),
	@vcYoutubePassword varchar(50),
	@vcYoutubeRecoveryEmail varchar(100),
	@vcBlogUrl varchar(100),
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY		
			IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfile] WHERE ClientID=@inClientId)
			BEGIN				
					INSERT INTO [dbo].[CWI_ClientProfile]
					([ClientID],
					FBEmail,
					FBPageUrl,
					FBGmailAddress,
					FBGmailPassword,
					FBAdId,
					FBAdAccountPassword,
					TwitterHandle,
					TwitterEmail,
					TwitterPassword,
					LinkedInUrl,
					YoutubeChannelUrl,
					YoutubeUserName,
					YoutubeEmail,
					YoutubePassword,
					YoutubeRecoveryEmail,
					BlogUrl,
					[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
					VALUES
					(@inClientId,
					@vcFBEmail,
					@vcFBPageUrl,
					@vcFBGmailAddress,
					@vcFBGmailPassword,
					@vcFBAdId,
					@vcFBAdAccountPassword,
					@vcTwitterHandle,
					@vcTwitterEmail,
					@vcTwitterPassword,
					@vcLinkedInUrl,
					@vcYoutubeChannelUrl,
					@vcYoutubeUserName,
					@vcYoutubeEmail,
					@vcYoutubePassword,
					@vcYoutubeRecoveryEmail,
					@vcBlogUrl,
					GETDATE(),@inUserId,GETDATE(),@inUserId)												
			END
			ELSE
			BEGIN
				UPDATE [dbo].[CWI_ClientProfile]
				SET FBEmail=@vcFBEmail,
					FBPageUrl=@vcFBPageUrl,
					FBGmailAddress=@vcFBGmailAddress,
					FBGmailPassword=@vcFBGmailPassword,
					FBAdId=@vcFBAdId,
					FBAdAccountPassword=@vcFBAdAccountPassword,
					TwitterHandle=@vcTwitterHandle,
					TwitterEmail=@vcTwitterEmail,
					TwitterPassword=@vcTwitterPassword,
					LinkedInUrl=@vcLinkedInUrl,
					YoutubeChannelUrl=@vcYoutubeChannelUrl,
					YoutubeUserName=@vcYoutubeUserName,
					YoutubeEmail=@vcYoutubeEmail,
					YoutubePassword=@vcYoutubePassword,
					YoutubeRecoveryEmail=@vcYoutubeRecoveryEmail,
					BlogUrl=@vcBlogUrl,
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
	

	

' 
END
GO
