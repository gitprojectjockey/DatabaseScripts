/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileDigitalMedia]    Script Date: 8/5/2014 5:25:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientProfileDigitalMedia]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileDigitalMedia]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientProfileDigitalMedia]    Script Date: 8/5/2014 5:25:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientProfileDigitalMedia]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileDigitalMedia 
* Purpose : This PROC would be called to retrieve the profile digital media details for a specific client/division
* Invoked from : Profile_DigitalMedia.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE         AUTHOR          DESCRIPTION              
08-Aug-2014    Vijesh
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileDigitalMedia 13957
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileDigitalMedia]       
@inClientId int
AS
BEGIN

	BEGIN TRY 

		Select DM.Id,ISNULL(DM.SiteTypeId,0) AS SiteTypeId,ISNULL(ST.SiteType,'''') AS SiteType,DM.DomainUrl 
		from CWI_ClientProfileDigitalMedia as DM
		left outer join [dbo].[CWI_CPL_SiteTypes] as ST on ST.Id=DM.SiteTypeId
		where ClientId=@inClientId and [IsDelete]=0
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	

' 
END
GO
