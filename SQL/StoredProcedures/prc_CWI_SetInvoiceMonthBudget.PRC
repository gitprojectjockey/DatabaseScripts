/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceMonthBudget]    Script Date: 9/16/2014 2:49:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceMonthBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetInvoiceMonthBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceMonthBudget]    Script Date: 9/16/2014 2:49:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceMonthBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*******************************************************************  
* PROCEDURE: prc_CWI_SetInvoiceMonthBudget  
* Purpose : This PROC would be called to Create, Update the Classification Month budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 
EXEC prc_CWI_SetInvoiceMonthBudget

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetInvoiceMonthBudget] 
	
    @InvoiceData XML	
    ,@UserId int
	--@ErrorMsg varchar(1000) out
    
AS
BEGIN
	Declare @tblInvoiceData table(
									ID int,
									BudgetMonthId int,
									ClassId Int,
									InvoiceDate datetime,
									budgetForecast decimal(18,3)
									)
	
	INSERT INTO @tblInvoiceData 
	SELECT 
		COLX.value(''(./ID)[1]'',''Int'') Id,
		COLX.value(''(./BudgetMonthId)[1]'',''int'') BudgetMonthId,
		COLX.value(''(./ClassificationLookupID)[1]'',''int'') BudgetMonthId,
		COLX.value(''(./InvoiceDate)[1]'',''datetime'') InvoiceDate,
		COLX.value(''(./BudgetForecast)[1]'',''decimal(18,3)'') BudgetForecast
	FROM @InvoiceData.nodes(''DocumentElement/InvoiceClass'') AS TABX(COLX);
	
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
		FROM CWI_BudgetMonthInvoice BMI
	INNER JOIN 
		@tblInvoiceData T ON T.ID=BMI.ID;

	UPDATE [CWI_BudgetMonthInvoice]
	SET
		[BudgetForecast]=T.budgetForecast,				
		[ModifiedBy]=@UserId,
		[ModifiedOn]=GETDATE()
	FROM 
		CWI_BudgetMonthInvoice BMI
	INNER JOIN 
		@tblInvoiceData T ON T.ID=BMI.ID

	INSERT INTO [dbo].[CWI_BudgetMonthInvoice]
				   ([BudgetMonthID]
				   ,InvoiceDate
				   ,[ClassificationLookupID]
				   ,[BudgetForecast]			  
				   ,[CreatedBy]
				   ,[CreatedOn]
				   ,[ModifiedBy]
				   ,[ModifiedOn])
			SELECT 
					T.BudgetMonthId,
					T.InvoiceDate,
					T.ClassId,
					T.budgetForecast,
					@UserId,
					GETDATE(),
					@UserId,
					GETDATE()
			FROM
				@tblInvoiceData T
			LEFT OUTER JOIN 
				CWI_BudgetMonthInvoice BMI ON BMI.BudgetMonthID=t.BudgetMonthId AND BMI.ClassificationLookupID=t.ClassId WHERE BMI.ID IS NULL;
END




' 
END
GO
