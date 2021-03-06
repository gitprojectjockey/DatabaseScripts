/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCPLResponseChannel]    Script Date: 9/23/2014 6:21:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCPLResponseChannel]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCPLResponseChannel]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCPLResponseChannel]    Script Date: 9/23/2014 6:21:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCPLResponseChannel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetCPLResponseChannel 
* Purpose : This PROC would be called TO INSERT a new response channel
* Invoked from : Profile_ResponseTranslation.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE       AUTHOR          DESCRIPTION  
 
**********************************************************************  
Execution example :
**********************************************************************  

exec prc_CWI_SetCPLResponseChannel ''Feedback'',7
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetCPLResponseChannel]
	@Channel varchar(250),	
	@Author int 
AS
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION TRAN1
			BEGIN TRY				

				begin try
				IF EXISTS(SELECT top 1 1 FROM [dbo].[CWI_CPL_ResponseChannel] WHERE 
				[Channel] = @Channel)
				begin
					declare @message NVARCHAR(2000) = ''Channel - ''+ @Channel +'' already exists'';
					THROW 50000,@message , 1; 
				end						
				end try
				begin catch
					throw;
				end catch

				INSERT INTO [dbo].[CWI_CPL_ResponseChannel]
				(Channel, [IsActive], CreatedOn, CreatedBy)
				VALUES 
				(@Channel,1, GETDATE(), @Author)				
				
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT >0 
					ROLLBACK TRANSACTION TRAN1;
				EXEC prc_CWI_AppRaiseError;
				THROW;
			END CATCH
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION TRAN1;
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END


' 
END
GO
