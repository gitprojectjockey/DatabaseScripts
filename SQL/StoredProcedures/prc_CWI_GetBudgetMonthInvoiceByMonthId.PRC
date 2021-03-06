/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetMonthInvoiceByMonthId]    Script Date: 9/16/2014 2:49:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthInvoiceByMonthId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetBudgetMonthInvoiceByMonthId]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetMonthInvoiceByMonthId]    Script Date: 9/16/2014 2:49:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthInvoiceByMonthId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetBudgetMonthInvoiceByMonthId]  
* Purpose : This PROC would be called to get the Service Ids
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_GetBudgetMonthInvoiceByMonthId @BudgetMonthId=1939,@ClassificationId=2210

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetBudgetMonthInvoiceByMonthId] 
	@BudgetMonthID INT,
	@ClassificationId INT
AS
BEGIN
	SELECT 
		BMI.ID,
		BMI.BudgetForecast,
		BMI.BudgetMonthId,
		InvoiceDate,
		BMI.ClassificationLookupID 
		
	FROM CWI_BudgetMonthInvoice BMI
	INNER JOIN
		CWI_BudgetMonthClassification L ON L.Id=BMI.ClassificationLookupId
	WHERE BMI.BudgetMonthID=@BudgetMonthID and BMI.ClassificationLookupId=@ClassificationId;
END
' 
END
GO
