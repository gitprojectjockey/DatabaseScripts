/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientDivision]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientDivision' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientDivision]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientDivision]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetClientSearchChildDetails]
* Purpose : This PROC would be called TO get Client Search
* Invoked from : Client.aspx
* CREATED: Saravanan M
* CREATED ON : 08 Apr 2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec dbo.[prc_CWI_GetClientSearchChildDetails] @ClientCode='',@ClientName='',@DivisionCode='',@DivisionName='',@ClientStatus='All'
**********************************************************************/ 
--[prc_CWI_GetClientDivision] 14218
CREATE PROCEDURE [dbo].[prc_CWI_GetClientDivision] 
	@inClientId int
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT DISTINCT
			C.Id as ClientID,
			C.ClientCode+'-'+C.ClientName as Division			
	FROM dbo.CWI_Client AS C			
		WHERE ISNULL( C.ParentID,0)<>0 and C.ParentID=@inClientId

END


GO
