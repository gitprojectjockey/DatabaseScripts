/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientContact]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientContact' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientContact]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientContact]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientContact  
* Purpose : This PROC would be called TO get the contact details to edit
* Invoked from : Client.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClientContact
  
**********************************************************************/ 
  
CREATE PROC [dbo].[prc_CWI_GetClientContact]
	@ContactId int = NULL
AS

IF @ContactId IS NOT NULL
BEGIN
	SELECT	
		ClientId,
		Name,
		ContactTypeLookupId,
		ISNULL(Title,'') Title,
		ISNULL(Address,'') Address,
		Email,
		dbo.fnc_FormatRemovalPhone(PhoneWork,default) as PhoneWork,
		dbo.fnc_FormatRemovalPhone(PhoneCell,default) as PhoneCell,
		dbo.fnc_FormatRemovalPhone(PhoneOther,default) as PhoneOther,
		dbo.fnc_FormatRemovalPhone(Fax,default) as Fax,
		DOB,
		ISNULL(Interests,'') Interests,
		ISNULL(Notes,'') Notes,
		LC.LookupName ContactType,
		IsCWPortalUser
	FROM	CWI_ClientContact CC
	INNER JOIN  vw_CWI_ClientContactType LC
		ON CC.ContactTypeLookupId = LC.Id

	WHERE 	CC.Id = @ContactId
		
	RETURN
END

	SELECT	
		ClientId,
		Name,
		ContactTypeLookupId,
		ISNULL(Title,'') Title,
		ISNULL(Address,'') Address,
		Email,
		dbo.fnc_FormatRemovalPhone(PhoneWork,default) as PhoneWork,
		dbo.fnc_FormatRemovalPhone(PhoneCell,default) as PhoneCell,
		dbo.fnc_FormatRemovalPhone(PhoneOther,default) as PhoneOther,
		dbo.fnc_FormatRemovalPhone(Fax,default) as Fax,
		DOB,
		ISNULL(Interests,'') Interests,
		ISNULL(Notes,'') Notes,
		LC.LookupName ContactType,
		IsCWPortalUser
	FROM	CWI_ClientContact CC
	INNER JOIN  vw_CWI_ClientContactType LC
		ON CC.ContactTypeLookupId = LC.Id

GO		











