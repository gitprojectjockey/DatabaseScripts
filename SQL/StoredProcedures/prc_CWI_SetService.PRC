

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetService]    Script Date: 4/25/2013 2:40:33 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetService')
DROP PROCEDURE [dbo].[prc_CWI_SetService]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetService]    Script Date: 4/25/2013 2:40:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_SetService 
* Purpose : This PROC would be called TO INSERT OR UPDATE the service details
* Invoked from : Service.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetService 7,201,1, 1, 'TEST',@inRowCount output
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetService]
	@inServiceId int=NULL,
	@vcServiceCode varchar(50),
	@vcServiceDescription varchar(max),
	@vcServiceName varchar(100),
	@inClassificationId int=NULL,
	@bitIsActive bit,
	@dtAvailableOnDate datetime,
	@vcServiceFinanceCode varchar(50)=NULL,
	@numServiceDefaultFee numeric(18,3)=NULL,
	@vcInvoiceItemDescription varchar(max)=NULL,
	@vcServiceDetail varchar(max)=NULL, 
	@bitIsDeleted bit,
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY		
			IF @inServiceId IS NULL
			BEGIN
				IF NOT EXISTS(SELECT [ServiceCode] FROM [dbo].[CWI_Service] WHERE [ServiceCode]=@vcServiceCode)
				BEGIN
					INSERT INTO [dbo].[CWI_Service]
					([ServiceCode],[ServiceDescription],[ServiceName],[ClassificationLookupId],[IsActive],[AvailableOnDate],
					[ServiceFinanceCode],[ServiceDefaultFee],[InvoiceItemDescription],[ServiceDetail],[IsDeleted],[CreatedOn],
					[CreatedBy],[ModifiedOn],[ModifiedBy])
					VALUES
					(@vcServiceCode,@vcServiceDescription,@vcServiceName,@inClassificationId,@bitIsActive,@dtAvailableOnDate,
					@vcServiceFinanceCode,@numServiceDefaultFee,@vcInvoiceItemDescription,@vcServiceDetail,@bitIsDeleted,
					GETDATE(),@inUserId,GETDATE(),@inUserId)	
					SET @inRowCount = (SELECT @@IDENTITY AS rowaffected)
				END
				ELSE
				BEGIN
					SET @inRowCount = -1
				END			
			END
			ELSE
			BEGIN
				UPDATE [dbo].[CWI_Service]
				SET [ServiceCode]=@vcServiceCode,[ServiceDescription]=@vcServiceDescription,[ServiceName]=@vcServiceName,
				[ClassificationLookupId]=@inClassificationId,[IsActive]=@bitIsActive,[AvailableOnDate]=@dtAvailableOnDate,
				[ServiceFinanceCode]=@vcServiceFinanceCode,[ServiceDefaultFee]=@numServiceDefaultFee,
				[InvoiceItemDescription]=@vcInvoiceItemDescription,[ServiceDetail]=@vcServiceDetail,[IsDeleted]=@bitIsDeleted,
				[ModifiedOn]=GETDATE(),[ModifiedBy]=@inUserId
				WHERE [Id]=@inServiceId
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
			END			
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	
GO