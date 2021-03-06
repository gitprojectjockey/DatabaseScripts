/****** Object:  StoredProcedure [dbo].[prc_CWI_SetBudgetUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetBudgetUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetBudgetUpdate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetBudgetUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetBudgetUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetBudgetUpdate 
* Purpose : This PROC would be called TO UPDATE the expected and actual cost & invoice for the selected media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Saravanan M
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :,
**********************************************************************  
exec prc_CWI_SetBudgetUpdate @JobId=155,@VendorId=6043,@Author=8,@ActualInvoice=400.00,@Status=''Committed''
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetBudgetUpdate]	
	@JobId int,	
	@VendorId int,	
	@Author INT,
	@ActualInvoice decimal,
	@Status Varchar(100)
AS
BEGIN	
	BEGIN TRY
	Declare 
		@EndDate datetime, @DivisionId int=0,@DivisionBudgetId INT=0,
		@Month INT=0,@BudgetMonthId Int=0,@Year INT=0,@ID INT=0,
		@ClassificationID INT=0,@BudgetMonthClassificationID Int=0,@BudgetMonthClassVendorID INT=0,
		@ClientBudgetID INT=0,@BudgetUsed decimal=0.00,@BudgetCommitted decimal=0.00;



	SELECT		
		@DivisionId = J.DivisionID,
		@EndDate = J.InvoiceDate ,		
		@ClassificationID = J.ClassificationId
	FROM CWI_Job J
	WHERE  J.ID=@JobId;

	select @DivisionBudgetId=ID from CWI_divisionBudget 
	where @EndDate between BudgetFrom and BudgetTo and DivisionID=@DivisionId;
	SET @Month=DATEPART(MM,@EndDate);
	SET @Year=DATEPART(YYYY,@EndDate);
	
	select @BudgetMonthId= ID from CWI_BudgetMonth 
	where DivisionBudgetID=@DivisionBudgetId and [Month]=@Month AND [Year]=@Year

	Select @ClientBudgetID=ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetID;


	IF( @Status=''Invoiced'' )
		BEGIN
		Set @BudgetUsed=@ActualInvoice;

		END
	ELSE IF( @Status=''Committed'' )
		BEGIN
		SET @BudgetCommitted=@ActualInvoice
		END

	IF( @BudgetMonthId>0 )
	BEGIN
		Select @BudgetMonthClassificationID=ID from CWI_BudgetMonthClassification 
		where BudgetMonthID=@BudgetMonthId and ClassificationLookupID=@ClassificationID;
 
		SELECT @BudgetMonthClassVendorID=ID FROM CWI_BudgetMonthClassVendor 
		where BudgetMonthClassificationID=@BudgetMonthClassificationID and VendorID=@VendorId;

		IF( @BudgetMonthClassificationID>0 )
		BEGIN

			IF( @BudgetMonthClassVendorID>0)
			BEGIN

				IF( @Status=''Committed'')
				BEGIN
					UPDATE CWI_BudgetMonthClassVendor
						SET
						BudgetCommitted=@ActualInvoice,
						BudgetAvailable=BudgetForecast-(BudgetUsed+@ActualInvoice),
						ModifiedBy=@Author,
						ModifiedOn=GETDATE() 
					WHERE ID=@BudgetMonthClassVendorID; 

				END
				ELSE IF(@Status=''Invoiced'')
				BEGIN
					UPDATE CWI_BudgetMonthClassVendor
					SET
						BudgetUsed=@ActualInvoice,
						BudgetCommitted=(BudgetCommitted-@ActualInvoice),
						BudgetAvailable=BudgetForecast-(@ActualInvoice+BudgetCommitted),
						ModifiedBy=@Author,
						ModifiedOn=GETDATE() 
					WHERE ID=@BudgetMonthClassVendorID;
				END

			END

			ELSE IF(@BudgetMonthClassVendorID=0 OR @BudgetMonthClassVendorID='''')
				BEGIN
					EXEC prc_CWI_SetVendorBudgetInvoiceUpdate @BudgetMonthClassVendorID output ,
						@BudgetMonthClassificationID,@VendorId,0.00,@BudgetUsed,@BudgetCommitted,0.00,
						@Author
   
				END
			ELSE
			BEGIN
			IF( @BudgetMonthId>0 and( @BudgetMonthClassificationID=0 OR @BudgetMonthClassificationID=''''))
				BEGIN
					EXEC prc_CWI_SetClassificationMonthBudgetInvoiveUpdate @BudgetMonthClassificationID OUTPUT,@BudgetMonthID,@ClassificationID,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
 				   
			IF( @BudgetMonthClassificationID >0 and (@BudgetMonthClassVendorID=0 OR @BudgetMonthClassVendorID=''''))
				BEGIN
					EXEC prc_CWI_SetVendorBudgetInvoiceUpdate @BudgetMonthClassVendorID output ,@BudgetMonthClassificationID,@VendorId,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
 
				END

				END
				END
				END

			ElSE IF( @BudgetMonthClassificationID=0 OR @BudgetMonthClassificationID='''')
				BEGIN
				IF( @BudgetMonthId>0 )
					BEGIN
						EXEC prc_CWI_SetClassificationMonthBudgetInvoiveUpdate @BudgetMonthClassificationID OUTPUT,@BudgetMonthID,@ClassificationID,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
					END	  
				   
				IF( @BudgetMonthClassificationID >0)
					BEGIN
						EXEC prc_CWI_SetVendorBudgetInvoiceUpdate @BudgetMonthClassVendorID output ,@BudgetMonthClassificationID,@VendorId,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
 
					END
				END
	
	END

ELSE IF(@BudgetMonthId=0 AND @DivisionBudgetId>0)
	
IF( @Status=''Committed'')
	BEGIN
		EXEC prc_CWI_SetMonthBudgetInvoiceUpdate @BudgetMonthId OUTPUT,@Month,@Year,@DivisionBudgetId,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
IF( @BudgetMonthId>0 )
	BEGIN

		EXEC prc_CWI_SetClassificationMonthBudgetInvoiveUpdate @BudgetMonthClassificationID OUTPUT,@BudgetMonthID,@ClassificationID,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
				  
				   
IF( @BudgetMonthClassificationID >0)
	BEGIN
		EXEC prc_CWI_SetVendorBudgetInvoiceUpdate @BudgetMonthClassVendorID output ,@BudgetMonthClassificationID,@VendorId,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
 
	END
	END
	END
ELSE IF ( @Status=''Invoiced'')
	BEGIN
		EXEC prc_CWI_SetMonthBudgetInvoiceUpdate @BudgetMonthId OUTPUT,@Month,@Year,@DivisionBudgetId,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
	
IF( @BudgetMonthId>0 )
	BEGIN

		EXEC prc_CWI_SetClassificationMonthBudgetInvoiveUpdate @BudgetMonthClassificationID OUTPUT,@BudgetMonthID,@ClassificationID,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
				  
				   
IF( @BudgetMonthClassificationID >0)
	BEGIN
		EXEC prc_CWI_SetVendorBudgetInvoiceUpdate @BudgetMonthClassVendorID output ,@BudgetMonthClassificationID,@VendorId,0.00,@BudgetUsed,@BudgetCommitted,0.00,@Author
 

	END
	END
	END
		
IF( @BudgetMonthClassVendorID>0 )
	BEGIN

  EXEC prc_CWI_SetVendorBudgetUpdate @BudgetMonthClassificationID,@BudgetMonthId,@DivisionBudgetId,@ClientBudgetID,@Author

	END
   
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END
	

	

' 
END
GO
