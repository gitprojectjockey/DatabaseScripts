/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileSocialMedia]    Script Date: 7/24/2014 4:22:13 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientProfileSocialMedia]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileSocialMedia]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileSocialMedia]    Script Date: 7/24/2014 4:22:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientProfileSocialMedia]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileSocialMedia 
* Purpose : This PROC would be called to retrieve the profile social media details for a specific client/division
* Invoked from : Profile_SocialMedia.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileSocialMedia 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileSocialMedia]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		
		SELECT [ID] as ProfileID,
			ISNULL(FBEmail,'''') as FBEmail,
			ISNULL(FBPageUrl,'''') AS FBPageUrl,
			isnull(FBGmailAddress,'''') as FBGmailAddress,
			isnull(FBGmailPassword,'''') as FBGmailPassword,
			isnull(FBAdId,'''') as FBAdId,
			isnull(FBAdAccountPassword,'''') as FBAdAccountPassword,
			isnull(TwitterHandle,'''') as TwitterHandle,
			isnull(TwitterEmail,'''') as TwitterEmail,
			isnull(TwitterPassword,'''') as TwitterPassword,
			isnull(LinkedInUrl,'''') as LinkedInUrl,
			isnull(YoutubeChannelUrl,'''') as YoutubeChannelUrl,
			isnull(YoutubeUserName,'''') as YoutubeUserName,
			isnull(YoutubeEmail,'''') as YoutubeEmail,
			isnull(YoutubePassword,'''') as YoutubePassword,
			isnull(YoutubeRecoveryEmail,'''') as YoutubeRecoveryEmail,
			isnull(BlogUrl,'''') as BlogUrl
		FROM [dbo].[CWI_ClientProfile]
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	

' 
END
GO
