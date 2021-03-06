/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVCLimitAndTransCount]    Script Date: 11/4/2014 2:45:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVCLimitAndTransCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVCLimitAndTransCount]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVCLimitAndTransCount]    Script Date: 11/4/2014 2:45:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVCLimitAndTransCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/**********************************************************************************************  
* PROCEDURE: [prc_CWI_SetVCLimitAndTransCount]
* Purpose : This PROC would be called to update the virtaul card CC limit and transaction count details
* Invoked from : ManageVirtualCard.aspx
* CREATED: Vijesh 24JUL14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
 10/28/2014 Vijesh			Modified @TransCount parameter to accept null           

*************************************************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetVCLimitAndTransCount] @MediaBuyID  = 3294,@CCLimit=11,@TransCount =2,@Comment=''test'',@Author=7
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetVCLimitAndTransCount] 
	@MediaBuyID bigint,
	@CCLimit numeric(18,2),
	@TransCount smallint=NULL,
	@Comment Varchar(max),
	@Author int,
	@inRowCount int OUTPUT 
AS
BEGIN
	BEGIN TRY

		DECLARE @InvoiceId Bigint=0,@message NVARCHAR(2000)='''',@PaymentLookupId int

		SELECT
			@InvoiceId=ISNULL(InvoiceId,0) ,
			@PaymentLookupId=PayMethodLookupId
		FROM
			CWI_Job J
			INNER JOIN 	 CWI_JobMediaBuy JMB
				ON J.Id = JMB.JobId
		WHERE
			JMB.Id = @MediaBuyID

		BEGIN TRY	
			IF (ISNULL(@InvoiceId,0)<>0)
			BEGIN
				SET @message = ''Invoice processing has been started. Please refresh the page.''; 
				THROW 50000,@message , 1; 
			END
		END TRY
		BEGIN CATCH
			THROW;
		END CATCH

		BEGIN TRY	
			IF (@PaymentLookupId<>852)/*852 is Virtual Card Lookup Id*/
			BEGIN
				SET @message = ''Payment method has been changed. Please refresh the page.''; 
				THROW 50000,@message , 1; 
			END
		END TRY
		BEGIN CATCH
			THROW;
		END CATCH

		BEGIN TRANSACTION Trans1
		BEGIN TRY

			DECLARE @InsertAction varchar(8000)
			DECLARE @InsertActionLink varchar(8000)
			DECLARE @AuthorName varchar(1000)
			DECLARE @dtModifiedBy varchar(50)		

			INSERT INTO COMDATACommunicationControl
			(SettlementID,ComDataTemplateID,Created,ResponseCode,CCLimit,TransCount)
			SELECT @MediaBuyID,2,GETDATE(),0,@CCLimit,@TransCount		
			
			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
			
			EXEC prc_CWI_SetComment @author,  216/* Adjust Virtual Card credit limit*/, @MediaBuyID, NULL, @Comment, 1
			
			--Inserting into Action table to track History
			SELECT @AuthorName = Names FROM CWI_User WHERE Id = @author
			SET @dtModifiedBy = FORMAT(GETDATE(), ''MM/dd/yyyy hh:mm tt'')
			SET @InsertAction = ''Credit Limit and Transaction Count updated by ''  + @AuthorName + '' on '' + @dtModifiedBy
			SET @InsertActionLink = ''Credit Limit and Transaction Count updated by ''  + @AuthorName + '' on '' + @dtModifiedBy
		
			EXEC prc_CWI_SetAction @ObjectLookupId = 211,/*Virtual Card*/  
				@ObjectId = @MediaBuyID,
				@ActionLookupId = 10026,/*Virtual Card Limit Updated*/
				@Action = @InsertAction,
				@ActionWithLink = @InsertActionLink,
				@CreatedBy = @Author	
		
		END TRY
		BEGIN CATCH	  
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
			EXEC prc_CWI_AppRaiseError;
			THROW;
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END









' 
END
GO
