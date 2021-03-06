/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobApproval]    Script Date: 4/23/2014 6:17:49 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobApproval]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobApproval]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobApproval]    Script Date: 4/23/2014 6:17:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobApproval]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetJobApproval]  
* Purpose : This PROC would be called TO get all the contacts for the client AND division id
* Invoked from : jobs.aspx
* CREATED: BALA
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetJobApproval] 14212
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetJobApproval]
    @ClientId int 

AS
	SET NOCOUNT ON
	DECLARE @TBL_DIVISION TABLE(DIVISIONID INT)
	
	INSERT INTO @TBL_DIVISION
	SELECT ID FROM CWI_Client  (NOLOCK) 
	WHERE ID=@ClientId 
		OR ID = (SELECT PARENTID as ID FROM CWI_Client (NOLOCK)  WHERE ID=@ClientId)
	
	SELECT
		CC.Email, 
		CC.Id as ContactID,
		CC.Name,
		CC.Title,
		CC.ContactTypeLookupId,
		ISNULL(L.LookupName,'''') ContactType,
		dbo.fnc_FormatRemovalPhone(PhoneWork,default) as PhoneWork,
		dbo.fnc_FormatRemovalPhone(PhoneCell,default) as PhoneCell,
		dbo.fnc_FormatRemovalPhone(PhoneOther,default) as PhoneOther,
		CC.IsCWPortalUser,
		CASE 
		WHEN C.PArentID IS NULL THEN ''Client''
		ELSE ''Division''
		END AS ''ClientDivision''

	FROM CWI_ClientContact  (NOLOCK) CC
	INNER JOIN @TBL_DIVISION  DV ON DV.DIVISIONID = CC.ClientId
	INNER JOIN CWI_CLIENT  (NOLOCK) C ON CC.ClientId = C.Id
	LEFT OUTER JOIN  vw_CWI_ClientContactType  L ON L.Id = CC.ContactTypeLookupId
	WHERE CC.IsDeleted = 0 AND ISNULL(CC.Email,'''')<>''''


	SET NOCOUNT OFF




' 
END
GO


