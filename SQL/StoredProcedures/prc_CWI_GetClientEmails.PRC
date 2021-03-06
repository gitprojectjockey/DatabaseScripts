/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientEmails]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientEmails' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientEmails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientEmails]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientEmails
* Purpose : This PROC would be called TO get all the emails related to Client
* Invoked from : Client.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetClientEmails 2318
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientEmails]
    @ClientId int  
AS

SELECT distinct Email [Name], 'EMail' NameType   FROM CWI_ClientContact
WHERE ClientId = @ClientId
AND LTRIM(RTRIM(ISNULL(Email,''))) <> ''
UNION 
SELECT distinct Fax, 'Fax' NameType   FROM CWI_ClientContact
WHERE ClientId = @ClientId
AND LTRIM(RTRIM(ISNULL(Fax,''))) <> ''
UNION 
SELECT WorkFax, 'Fax' NameType FROM CWI_Client C INNER JOIN  CWI_Address A ON C.AddressID = A.ID
WHERE C.Id = @ClientId
AND LTRIM(RTRIM(ISNULL(WorkFax,''))) <> ''

GO
