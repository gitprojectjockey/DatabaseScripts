/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMonthInvoiceBudget]    Script Date: 9/16/2014 2:49:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMonthInvoiceBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetMonthInvoiceBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMonthInvoiceBudget]    Script Date: 9/16/2014 2:49:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMonthInvoiceBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorBudget  
* Purpose : This PROC would be called to Create, Update the Vendor budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_SetMonthInvoiceBudget]
@BudgetMonthClassificationID= 
,@VendorID = 
,@BudgetForecast= 
,@CreatedBy = 
,@ModifiedBy= 
 **********************************************************************/
Create PROCEDURE [dbo].[prc_CWI_SetMonthInvoiceBudget] 
	@ID INT = 0 OUT
	,@BudgetMonthClassificationID INT
    ,@BudgetForecast MONEY=0.00   
    ,@UserId int
    ,@ErrorMsg varchar(max) Out
AS
BEGIN
	--BEGIN TRY
--	IF @ID=0
--BEGIN
--declare @cnt int;
Declare @ClassificationAvailableBudget decimal(18,2);
declare @BudgetMonthID int=0, @DivisionBudgetID int=0, @ClientBudgetID int=0,@ClassBudget decimal(18,2),@InvoiceBudget decimal(18,2)=0, @InvoiceExistingBudget  decimal(18,2)=0;

SET @ClassBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthClassification where ID=@BudgetMonthClassificationID);

SET @InvoiceBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthInvoice where ClassificationLookupID=@BudgetMonthClassificationID);

SET @InvoiceExistingBudget=(select ISNULL(BudgetForecast,0)  from CWI_BudgetMonthInvoice where ID=@ID)

SET @InvoiceBudget=(ISNULL(@InvoiceBudget,0)- Isnull(@InvoiceExistingBudget,0));
SET @ClassificationAvailableBudget=(ISNULL(@ClassBudget,0)-ISNULL(@InvoiceBudget,0));

SET @BudgetMonthID=(Select BudgetMonthID from CWI_BudgetMonthClassification where ID=@BudgetMonthClassificationID);
SET  @DivisionBudgetID= (Select DivisionBudgetID from CWI_BudgetMonth where ID=@BudgetMonthID);
SET @ClientBudgetID=(Select ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetID);

IF(@ClassificationAvailableBudget>=@BudgetForecast )
BEGIN

 IF @ID>0
	
BEGIN
	BEGIN TRANSACTION
INSERT INTO [dbo].[CWI_History_BudgetMonthInvoice]
           ([BudgetMonthInvoiceID]		   
           ,[BudgetMonthID]
		   ,InvoiceDate
           ,[ClassificationLookupID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
		SELECT
			BMI.ID				   
           ,BMI.[BudgetMonthID]
		   ,BMI.InvoiceDate
           ,BMI.[ClassificationLookupID]
           ,BMI.[BudgetForecast]
           ,BMI.[BudgetUsed]
           ,BMI.[BudgetCommitted]         
           ,BMI.[CreatedBy]
           ,BMI.[CreatedOn]
           ,BMI.[ModifiedBy]
           ,BMI.[ModifiedOn]
		FROM CWI_BudgetMonthInvoice BMI WHERE BMI.ID=@ID;
 
	UPDATE [dbo].[CWI_BudgetMonthInvoice] SET
			  
			   [BudgetForecast]=@BudgetForecast
					  
			   ,[ModifiedBy]=@UserId
			   ,[ModifiedOn]=getDate() WHERE ID=@ID ;
			   
			   IF( @@ROWCOUNT>0 )
		BEGIN

			COMMIT; 

		END
ELSE
		BEGIN
		
			ROLLBACK Transaction;
			SET @ID=0;
			RETURN;
		END
		
	END
	END
ELSE 
	 
	BEGIN
	SET @ID=0;
					SET @ErrorMsg = ''Budget is more than available classification budget.''
					return
				END
END

--END
--end' 
END
GO
