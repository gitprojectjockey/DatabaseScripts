/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAssociatedClients]    Script Date: 9/12/2014 1:51:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAssociatedClients]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetAssociatedClients]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAssociatedClients]    Script Date: 9/12/2014 1:51:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAssociatedClients]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetAssociatedClients]
* Purpose : This PROC would be called TO bind the associated clients for a corporate 
* Invoked from : Client.aspx
* CREATED: Vijesh Mahi
* CREATED ON : 3 Sep 2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

********************************************************************** 
exec dbo.prc_CWI_GetAssociatedClients 15674
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetAssociatedClients] 
@inCorporateId int
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
			NULL as CorporateId,			
			C.ClientCode+'' - ''+ C.ClientName  as Name,
			Convert(varchar,C.Id) as Id
							
	FROM 
			dbo.CWI_Client AS C				
	WHERE 
			C.ID = @inCorporateId

	UNION ALL

	SELECT 
			Convert(varchar,CA.CoporateId) as CorporateId,			
			C.ClientCode+'' - ''+ C.ClientName  as Name,
			Convert(varchar,C.Id) as Id							
	FROM 
			dbo.CWI_Client AS C	
	INNER JOIN
			dbo.CWI_ClientAssociation CA
			ON CA.[ClientId]=C.ID		
	WHERE 
			CA.[CoporateId] = @inCorporateId
			and CA.IsRemoved=0
	ORDER BY Name



	SET NOCOUNT OFF;

END	






	





' 
END
GO
