/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobSelectVendor]    Script Date: 6/18/2014 12:27:24 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobSelectVendor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobSelectVendor]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobSelectVendor]    Script Date: 6/18/2014 12:27:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobSelectVendor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetJobSelectVendor 
* Purpose : This PROC would be called TO INSERT OR UPDATE the selected vendor for media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :,
**********************************************************************  
exec prc_CWI_SetJobSelectVendor NULL,1
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetJobSelectVendor]	
	@inJobId bigint,	
	@inMediaBuyStatus int,		
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY
		UPDATE 	[dbo].[CWI_JobMediaBuy]		
		SET [StatusId]=@inMediaBuyStatus,ModifiedBy=@inUserId,ModifiedOn=GETDATE()
		WHERE [JobId]=@inJobId AND [StatusId]=20101				
				
		SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)	

		----BELOW PART ADDED FOR INSERTING INTO LIFE CYCLE TABLE--------		
		--INSERT INTO dbo.CWI_ClassificationJob_LifeCycle_Status([JobId],[LifeCycleLookupId],[Status],[CreatedBy],[CreatedOn],[ModifiedBy],[ModifiedOn])
		--VALUES(@inJobId,4000,@inMediaBuyStatus,@inUserId,GETDATE(),@inUserId,GETDATE())
		EXEC prc_CWI_SetClassificationLifeCycleStatus @inJobId,4000,4205,null,1,@inUserId
		------------------------END-----------------------
		
		--Inserting into Action table to track History
		DECLARE @InsertAction varchar(8000)
		DECLARE @AuthorName varchar(1000)
		DECLARE @dtModifiedBy varchar(50)

		SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
		SELECT @AuthorName = Names FROM CWI_User WHERE Id = @inUserId

		SET @InsertAction = ''Vendors selected by '' + @AuthorName + '' on '' + @dtModifiedBy
		EXEC prc_CWI_SetAction @ObjectLookupId = 205, @ObjectId = @inJobId,
			@ActionLookupId = 10009,
			@Action = @InsertAction,
			@ActionWithLink = @InsertAction,
			@CreatedBy = @inUserId			
			
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END
	

	


' 
END
GO


