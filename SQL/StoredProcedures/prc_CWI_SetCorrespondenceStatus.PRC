/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceStatus]    Script Date: 5/6/2014 12:13:12 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceStatus]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceStatus]    Script Date: 5/6/2014 12:13:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetCorrespondenceStatus
* Purpose : This PROC would be called TO set correspondence status
* Invoked from : CorrespondenceService
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetCorrespondenceStatus @correspondenceid= 1, 3104, ''Erro while creating correspondence''
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetCorrespondenceStatus]
	@correspondenceid bigint,
	@statuslookupid int,
	@Comment varchar(max) = NULL
AS
	IF @statuslookupid = 3104 /* Error */
	BEGIN
		IF ISNULL(@Comment,'''')=''''
		BEGIN
			UPDATE CWI_Correspondence SET StatusLookupId = @statuslookupid, AttemptNo = AttemptNo + 1
			WHERE Id = @correspondenceid
		END
		ELSE
		BEGIN
			UPDATE CWI_Correspondence SET StatusLookupId = @statuslookupid, AttemptNo = AttemptNo + 1, ErrorMsg = @Comment
			WHERE Id = @correspondenceid
		END
		RETURN
	END

	IF ISNULL(@Comment,'''')=''''
	BEGIN
		UPDATE CWI_Correspondence SET StatusLookupId = @statuslookupid
		WHERE Id = @correspondenceid
	END
	ELSE
	BEGIN
		UPDATE CWI_Correspondence SET StatusLookupId = @statuslookupid, ErrorMsg = @Comment
		WHERE Id = @correspondenceid
	END

' 
END
GO


