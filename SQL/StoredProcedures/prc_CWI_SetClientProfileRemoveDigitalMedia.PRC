/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileRemoveDigitalMedia]    Script Date: 8/5/2014 5:25:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileRemoveDigitalMedia]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileRemoveDigitalMedia]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileRemoveDigitalMedia]    Script Date: 8/5/2014 5:25:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientProfileRemoveDigitalMedia]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileRemoveDigitalMedia 
* Purpose : This PROC would be called TO remove the selected digital media
* Invoked from : Profile_DigitalMedia.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  5/8/2014  Vijesh		        
  
**********************************************************************  
Execution example :
**********************************************************************  
declare @inRowCount int
exec prc_CWI_SetClientProfileRemoveDigitalMedia 1,7,@inRowCount
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileRemoveDigitalMedia]		
	@inDigitalMediaId int,
	@inUserId int,
	@inRowCount int OUTPUT 	   
AS
BEGIN
	BEGIN TRY	

		Update [dbo].[CWI_ClientProfileDigitalMedia] set [IsDelete]=1,
		[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
		where Id=@inDigitalMediaId

		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)

	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END











' 
END
GO
