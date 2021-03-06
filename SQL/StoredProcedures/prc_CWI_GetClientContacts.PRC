/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientContacts]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientContacts' )
 
DROP PROCEDURE [dbo].[prc_CWI_GetClientContacts]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientContacts]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientContacts  
* Purpose : This PROC would be called TO get all the contacts for the client id
* Invoked from : Client.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClientContacts 2
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientContacts]
    @ClientId int 

AS
    SELECT 
		CC.Id,
		CC.Name,
		CC.Title,
		CC.Email,
		CC.ContactTypeLookupId,
		L.LookupName ContactType,
		dbo.fnc_FormatRemovalPhone(PhoneWork,default) as PhoneWork,
		dbo.fnc_FormatRemovalPhone(PhoneCell,default) as PhoneCell,
		dbo.fnc_FormatRemovalPhone(PhoneOther,default) as PhoneOther,
		CC.IsCWPortalUser
	FROM CWI_ClientContact CC
	INNER JOIN  vw_CWI_ClientContactType  L ON L.Id = CC.ContactTypeLookupId
	WHERE ClientId = @ClientId
	and CC.IsDeleted = 0

GO
