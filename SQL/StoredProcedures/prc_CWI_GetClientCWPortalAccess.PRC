/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientCWPortalAccess]    Script Date: 10/1/2014 5:18:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientCWPortalAccess]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientCWPortalAccess]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientCWPortalAccess]    Script Date: 10/1/2014 5:18:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientCWPortalAccess]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientCWPortalAccess 
* Purpose : This PROC would be called TO get the client portal access details
* Invoked from : ClientPortalAccess.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  02SEP14	Mohankumar	    New table CWI_ClientContactPortal used to get the data
  30SEP14	Mohankumar	    Phone number added

**********************************************************************  
Execution example :
********************************************************************** 
exec [prc_CWI_GetClientCWPortalAccess] 5
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientCWPortalAccess]   
	@clientContactId int 
AS
BEGIN
	BEGIN TRY
		--DECLARE @tblOrder TABLE
		--(
		--	hierarchyTypeId int,
		--	hierarchyOrder int
		--)

		--INSERT INTO @tblOrder
		--SELECT Id,  
		--	CASE Id WHEN 523 /* Corporate */ THEN 1000
		--			WHEN 521 /* Client */ THEN 900
		--			WHEN 522 /* Division */ THEN 800
		--	ELSE SortOrder END,*
		--FROM Lookup 
		--WHERE 
		--LookupTypeId = 6 /* ClientHierarchyType */ 
		--AND IsActive  = 1
		
		--SELECT top 1  * FROM CWI_ClientContact CC
		--INNER JOIN CWI_Client C
		--ON CC.ClientId  =C.ID
		--	AND CC.IsDeleted = 0
		--	AND C.ClientStatusLookupID <>  504 /* InActive */
		--INNER JOIN @tblOrder t
		--	ON t.hierarchyOrder = C.HierarchyTypeLookupID
		--WHERE Email  = @email
		--ORDER BY hierarchyOrder desc

		DECLARE @email varchar(100), @Name varchar(100), @PhoneWork varchar(50)

		SELECT TOP 1 @email = Email, @Name = Name, @PhoneWork = PhoneWork
		FROM CWI_ClientContact
		WHERE Id = @clientContactId

		SELECT 
		@Name Name, 
		Id,
		Email,
		@PhoneWork PhoneWork,
		dbo.fnc_CWI_DecryptPortalPassword([Password]) [Password],
		IsLocked,
		IsExpired,
		IsEnabled,
		IsPasswordReset,
		LoginAttempts,
		IsLastLoginSuccess,
		LastLoginDate,
		PasswordChangeDate,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn
		FROM [dbo].[CWI_ClientContactPortal]
		WHERE email = @email
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	







' 
END
GO
