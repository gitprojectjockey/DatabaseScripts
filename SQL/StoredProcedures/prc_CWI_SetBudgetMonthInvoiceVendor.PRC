/****** Object:  StoredProcedure [dbo].[prc_CWI_SetBudgetMonthInvoiceVendor]    Script Date: 9/16/2014 2:49:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetBudgetMonthInvoiceVendor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetBudgetMonthInvoiceVendor]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetBudgetMonthInvoiceVendor]    Script Date: 9/16/2014 2:49:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetBudgetMonthInvoiceVendor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetBudgetMonthInvoiceVendor  
* Purpose : This PROC would be called to Create, Update the Invoice Vendor budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_SetBudgetMonthInvoiceVendor]
@@BudgetMonthInvoiceID= 
,@VendorID = 
,@BudgetForecast= 
,@BudgetUsed = 
,@BudgetCommitted = 
,@BudgetAvailable= 
,@CreatedBy = 
,@ModifiedBy= 
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetBudgetMonthInvoiceVendor] 
	@ID INT = 0 OUT
	,@BudgetMonthInvoiceID INT
    ,@VendorID INT
    ,@BudgetForecast MONEY=0.00
    ,@BudgetUsed	MONEY = 0.00
    ,@BudgetCommitted MONEY = 0.00
    ,@BudgetAvailable MONEY = 0.00
    ,@UserId int
    ,@ErrorMsg varchar(max) Out
AS
BEGIN
	--BEGIN TRY
--	IF @ID=0
--BEGIN
--declare @cnt int;
Declare @ClassificationAvailableBudget decimal(18,2);
declare @BudgetMonthID int=0, @DivisionBudgetID int=0, @ClientBudgetID int=0,@ClassBudget decimal(18,2),@VendorBudget decimal(18,2)=0, @VendorExistingBudget  decimal(18,2)=0;

SET @ClassBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthInvoice where ID=@BudgetMonthInvoiceID);

SET @VendorBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthInvoiceVendor where BudgetMonthInvoiceID=@BudgetMonthInvoiceID);

SET @VendorExistingBudget=(select ISNULL(BudgetForecast,0)  from CWI_BudgetMonthInvoiceVendor where ID=@ID)

SET @VendorBudget=(ISNULL(@VendorBudget,0)- Isnull(@VendorExistingBudget,0));
SET @ClassificationAvailableBudget=(ISNULL(@ClassBudget,0)-ISNULL(@VendorBudget,0));

SET @BudgetMonthID=(Select BudgetMonthID from CWI_BudgetMonthInvoice where ID=@BudgetMonthInvoiceID);
SET  @DivisionBudgetID= (Select DivisionBudgetID from CWI_BudgetMonth where ID=@BudgetMonthID);
SET @ClientBudgetID=(Select ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetID);

IF(@ClassificationAvailableBudget>=@BudgetForecast )
BEGIN

 IF @ID=0
	BEGIN
		INSERT INTO [dbo].[CWI_BudgetMonthInvoiceVendor]
			   ([BudgetMonthInvoiceID]
			   ,[VendorID]
			   ,[BudgetForecast]
			   ,[BudgetUsed]
			   ,[BudgetCommitted]
			   --,[BudgetAvailable]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn])
		 VALUES
				(@BudgetMonthInvoiceID
			   ,@VendorID
			   ,@BudgetForecast
			   ,@BudgetUsed
			   ,@BudgetCommitted
			   --,(@BudgetForecast-(@BudgetUsed+@BudgetCommitted))
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE())
			   SET @ID=SCOPE_IDENTITY();
		--IF(@ID>0)
		--	EXEC prc_CWI_SetVendorBudgetHistory @BudgetForecast,@BudgetMonthClassificationID,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
			   RETURN;
			   END

else	
BEGIN
	BEGIN TRANSACTION
INSERT INTO [dbo].[CWI_History_BudgetMonthInvoiceVendor]
           ([BudgetMonthInvoiceVendorId]
           ,[BudgetMonthInvoiceID]
           ,[VendorID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           --,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
           ,[IsCommitted])
		   SELECT ID,
		   [BudgetMonthInvoiceID]
           ,[VendorID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           --,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
           ,[IsCommitted]
		   FROM [CWI_BudgetMonthInvoiceVendor] WHERE ID=@ID;
 
	UPDATE [dbo].[CWI_BudgetMonthInvoiceVendor] SET
			  
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
					SET @ErrorMsg = ''Budget is more than available Invoice budget.''
					return
				END
END

--END
--end' 
END
GO
