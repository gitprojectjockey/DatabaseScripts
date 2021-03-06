/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPasswordHistoryValidation]    Script Date: 9/2/2014 5:22:26 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPasswordHistoryValidation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetPasswordHistoryValidation]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetPasswordHistoryValidation]    Script Date: 9/2/2014 5:22:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetPasswordHistoryValidation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetPasswordHistoryValidation  
* Purpose : This PROC would be called TO return the flag based on password''s availability in the old password history
* Invoked from : ClientPortalAccess.aspx
* CREATED: MohanKumar Sundaram 02SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
declare @isValid bit
exec prc_CWI_GetPasswordHistoryValidation @userId=1, @password = ''test'', @isValid = @isValid out
  print @isValid
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetPasswordHistoryValidation]
	@userId int,
	@password varchar(50),
	@isValid bit OUT
AS
	DECLARE @PasswordHistoryCount int = 1
	SELECT TOP 1  @PasswordHistoryCount = PasswordHistoryCount  FROM CWI_PasswordRule

	IF EXISTS 
		(
		SELECT TOP 1  1 FROM
		(
		SELECT TOP (@PasswordHistoryCount) [Password] FROM CWI_History_PortalUserPassword
		WHERE PortalUserID = @userId
		ORDER BY CreatedOn DESC
		) a
		WHERE 
			dbo.fnc_CWI_DecryptPortalPassword([Password]) = @password
			)
			Begin
				SET @isValid = 1
			End
			Else
			Begin
				SET @isValid = 0
			End


' 
END
GO


