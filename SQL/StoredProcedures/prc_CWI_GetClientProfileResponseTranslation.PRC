/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileResponseTranslation]    Script Date: 9/22/2014 7:38:20 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientProfileResponseTranslation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileResponseTranslation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileResponseTranslation]    Script Date: 9/22/2014 7:38:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientProfileResponseTranslation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileResponseTranslation 
* Purpose : This PROC would be called to bind the profile response translation details 			
* Invoked from : Profile_ResponseTranslation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE         AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileResponseTranslation 13957
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileResponseTranslation]       
@inClientId int
AS
BEGIN

	BEGIN TRY 

		SELECT RT.Id as TranslationId,
			ClientId,
			ChannelId,
			RC.Channel,
			ClientTranslation
			
		FROM CWI_ClientProfileResponseTranslation RT
		INNER JOIN CWI_CPL_ResponseChannel RC 
			ON RC.Id=RT.ChannelId
		WHERE RT.ClientId=@inClientId
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	


' 
END
GO
