/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientStatus]    Script Date: 3/25/2014 2:06:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientStatus]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientStatus]    Script Date: 3/25/2014 2:06:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientStatus  
* Purpose : This PROC would be called to Get the Client status
* Invoked from : Client.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_GetClientStatus] 
**********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetClientStatus]
	@ClientId int,
	@StatusId	int = NULL out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT 
			@StatusId = ClientStatusLookupID
			
	FROM CWI_Client
	WHERE 
		Id = @ClientId
	SET NOCOUNT ON;
END


' 
END
GO


