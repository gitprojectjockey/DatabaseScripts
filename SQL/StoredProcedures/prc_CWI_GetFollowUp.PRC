/****** Object:  StoredProcedure [dbo].[prc_CWI_GetFollowUp]    Script Date: 11/10/2014 9:32:26 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetFollowUp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetFollowUp]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetFollowUp]    Script Date: 11/10/2014 9:32:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetFollowUp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetFollowUp
* Purpose : This PROC would be called TO get the alert details 
* Invoked from : Multiple pages
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetFollowUp 0,215,30
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetFollowUp]
	@Id int = 0,
	@ObjectlookupId int,
	@ObjectId int
AS
	
	BEGIN
		SELECT a.Id,a.Title,a.Summary,a.OriginURL,a.AlertOn,a.EndDate,
		UA.Names CreatedUser,a.CreatedOn,UM.Names ModifiedUser,a.ModifiedOn,A.IsCompleted
		FROM CWI_Alert a		
		INNER JOIN CWI_User UA
		ON UA.Id = a.CreatedBy
		INNER JOIN CWI_User UM
		ON UM.Id = a.ModifiedBy
		WHERE a.ObjectlookupId = @ObjectlookupId AND a.ObjectId=@ObjectId and IsCompleted=0;
	END

	' 
END
GO
