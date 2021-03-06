/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorBudgetInvoiceUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorBudgetInvoiceUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorBudgetInvoiceUpdate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorBudgetInvoiceUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorBudgetInvoiceUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorBudgetInvoiceUpdate  
* Purpose : This PROC would be called to Create, Update the Vendor budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_SetVendorBudgetInvoiceUpdate]
@BudgetMonthClassificationID= 
,@VendorID = 
,@BudgetForecast= 
,@BudgetUsed = 
,@BudgetCommitted = 
,@BudgetAvailable= 
,@CreatedBy = 
,@ModifiedBy= 
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetVendorBudgetInvoiceUpdate] 
	@ID INT = 0 OUT
	,@BudgetMonthClassificationID INT
    ,@VendorID INT
    ,@BudgetForecast MONEY=0.00
    ,@BudgetUsed	MONEY = 0.00
    ,@BudgetCommitted MONEY = 0.00
    ,@BudgetAvailable MONEY = 0.00
    ,@UserId int
    
AS
BEGIN
	


 IF @ID=0
	BEGIN
		INSERT INTO [dbo].[CWI_BudgetMonthClassVendor]
			   ([BudgetMonthClassificationID]
			   ,[VendorID]
			   ,[BudgetForecast]
			   ,[BudgetUsed]
			   ,[BudgetCommitted]
			   ,[BudgetAvailable]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn])
		 VALUES
				(@BudgetMonthClassificationID
			   ,@VendorID
			   ,@BudgetForecast
			   ,@BudgetUsed
			   ,@BudgetCommitted
			   ,(@BudgetForecast-(@BudgetUsed+@BudgetCommitted))
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE())
			   SET @ID=SCOPE_IDENTITY();
		
			   RETURN;
			   END

else	
BEGIN
	BEGIN TRANSACTION
INSERT INTO [dbo].[CWI_History_BudgetMonthClassVendor]
           ([BudgetMonthClassVendorId]
           ,[BudgetMonthClassificationID]
           ,[VendorID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
           ,[IsCommitted])
		   SELECT ID,
		   [BudgetMonthClassificationID]
           ,[VendorID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
           ,[IsCommitted]
		   FROM [CWI_BudgetMonthClassVendor] WHERE ID=@ID;
 
	UPDATE [dbo].[CWI_BudgetMonthClassVendor] SET
			  
			   [BudgetForecast]=@BudgetForecast
			  ,[BudgetUsed]=@BudgetUsed
			   ,[BudgetCommitted]=@BudgetCommitted
			   ,[BudgetAvailable]=(@BudgetForecast-(@BudgetUsed+@BudgetCommitted))			  
			   ,[ModifiedBy]=@UserId
			   ,[ModifiedOn]=getDate() WHERE ID=@ID ;
			   SET @ID=@ID;
			   IF( @@ROWCOUNT>0 )
		BEGIN

			COMMIT; 
			return;
		END
ELSE
		BEGIN
		
			ROLLBACK Transaction;
			SET @ID=0;
			RETURN;
		END
		
	END
	

				END


--END
--end' 
END
GO
