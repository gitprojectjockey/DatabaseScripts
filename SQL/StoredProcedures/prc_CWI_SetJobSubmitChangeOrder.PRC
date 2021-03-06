/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobSubmitChangeOrder]    Script Date: 5/1/2014 9:15:44 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobSubmitChangeOrder]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobSubmitChangeOrder]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobSubmitChangeOrder]    Script Date: 5/1/2014 9:15:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobSubmitChangeOrder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobSubmitChangeOrder 
* Purpose : This PROC would be called TO UPDATE the expected and actual cost & invoice for the selected media buy in submit change order
* Invoked from : JobMediaBuy.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :,
**********************************************************************  
exec prc_CWI_SetJobSubmitChangeOrder 111,8
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobSubmitChangeOrder]	
	@inJobId bigint,	
	@inUserId int,
	@inRowCount int OUTPUT ,
	@vcResponseMsg varchar(max) OUT 
AS
BEGIN	
BEGIN TRAN
	BEGIN TRY	
		UPDATE 	[dbo].[CWI_Job]
			SET 
				IsChangeOrder=1 WHERE ID=@inJobId;

		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	
		SET @vcResponseMsg=''''
		EXEC prc_CWI_SetJobGenerateInsertion @inJobId,1,@inUserId,@vcResponseMsg out;
		
	END TRY	
	BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW
	END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ;
	END
	

	


' 
END
GO


