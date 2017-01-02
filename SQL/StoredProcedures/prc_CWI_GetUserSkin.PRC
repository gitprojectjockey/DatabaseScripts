/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUserSkin]    Script Date: 3/17/2014 12:39:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetUserSkin]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetUserSkin]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetUserSkin]    Script Date: 3/17/2014 12:39:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetUserSkin]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetUserSkin 
* Purpose : This PROC would be called TO get the skin value of the user
* Invoked from : Clientwise.master
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
DECLARE @vcSkinValue varchar(50)
exec prc_CWI_GetUserSkin 7,@vcSkinValue output  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetUserSkin]
    @inUserId int,
    @vcSkinValue varchar(50) OUTPUT 
AS
	SET @vcSkinValue = ''''
	SELECT top 1  @vcSkinValue = skinvalue FROM CWI_UserSkin
	INNER JOIN Lookup L ON L.LookupName = SkinValue AND L.IsActive = 1 AND L.LookupTypeId = 28
	WHERE UserID= @inUserId;
	
	IF ISNULL(@vcSkinValue,'''') = ''''
	Begin
		SET @vcSkinValue = ''Default''
	End
' 
END
GO


