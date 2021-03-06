/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID]    Script Date: 9/16/2014 2:49:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID]    Script Date: 9/16/2014 2:49:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID]  
* Purpose : This PROC would be called to get the details with Division budget
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
[prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID] 2210

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID]
	@BudgetMonthClassID INT
	--@InvoiceDate DATETIME
AS
BEGIN
	Select BMI.ID as BudgetMonthInvoiceId from CWI_BudgetMonthInvoice BMI
INNER JOIN 
	CWI_BudgetMonthClassification BMC ON BMI.ClassificationLookupID=BMC.ID
INNER JOIN [dbo].[CWI_BudgetMonth] 
		ON
			[CWI_BudgetMonth].ID=BMC.BudgetMonthID WHERE BMC.ID=@BudgetMonthClassID --AND Convert(datetime, BMI.InvoiceDate,103)=Convert(datetime, @InvoiceDate,103);
END

' 
END
GO
