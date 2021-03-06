/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientListforCorporate]    Script Date: 9/16/2014 2:34:54 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientListforCorporate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientListforCorporate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientListforCorporate]    Script Date: 9/16/2014 2:34:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientListforCorporate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: [prc_CWI_GetClientListforCorporate]
* Purpose : This PROC would be called TO bind the list of clients for a corporate 
* Invoked from : Client.aspx
* CREATED: Vijesh Mahi
* CREATED ON : 3 Sep 2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

********************************************************************** 
exec dbo.prc_CWI_GetClientListforCorporate 
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetClientListforCorporate] 
	
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT 
				C.Id as ClientId,			
				C.ClientCode as ClientCode,
				C.ClientCode+'' - ''+C.ClientName as ClientName
							
		FROM 
				dbo.CWI_Client AS C	
				INNER JOIN 
					dbo.vw_CWI_Address A
				ON
					C.AddressID = A.ID	
				--left outer join 
					--dbo.CWI_ClientAssociation CA
				--ON
					--C.ID=CA.ClientId
						
				
		WHERE 
				C.HierarchyTypeLookupID=521 ---521 IS Client heirarchy LOOKUP
				and C.Id not in (select distinct ClientId from CWI_ClientAssociation where IsRemoved=0)
				and C.ClientStatusLookupID=502
				order by ClientName 


	SET NOCOUNT OFF;

END	




	







' 
END
GO
