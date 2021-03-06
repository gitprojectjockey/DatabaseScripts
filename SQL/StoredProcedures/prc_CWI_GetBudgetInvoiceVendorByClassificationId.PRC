/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetInvoiceVendorByClassificationId]    Script Date: 9/16/2014 2:49:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetInvoiceVendorByClassificationId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetBudgetInvoiceVendorByClassificationId]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetInvoiceVendorByClassificationId]    Script Date: 9/16/2014 2:49:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetInvoiceVendorByClassificationId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetBudgetInvoiceVendorByClassificationId]  
* Purpose : This PROC would be called to get the details with Vednor info
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
[prc_CWI_GetBudgetInvoiceVendorByClassificationId] @VendorID=6913,@ClassificationId=401

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetBudgetInvoiceVendorByClassificationId] 
	@VendorID int,
	@ID int
AS
BEGIN
	SELECT BMIV.ID as BudgetMonthVendorId
	FROM		
		[CWI_BudgetMonthInvoiceVendor] BMIV
	INNER JOIN
		[dbo].[CWI_Vendor] V on BMIV.VendorID=V.Id
	INNER JOIN
		CWI_BudgetMonthInvoice  BMI ON BMI.ID=BMIV.BudgetMonthInvoiceId  
	INNER JOIN
		[dbo].[CWI_BudgetMonthClassification] BMC ON BMI.ClassificationLookupID=BMC.ID
	INNER JOIN
		[dbo].[CWI_BudgetMonth] BM ON BM.ID=BMC.BudgetMonthID			
	INNER JOIN
		CWI_DivisionBudget DB ON DB.ID=BM.DivisionBudgetID 
	WHERE BMIV.VendorID=@VendorId AND BMI.ID=@ID;
END
' 
END
GO
