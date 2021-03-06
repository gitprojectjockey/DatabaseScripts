/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetMonthInvoiceVendorID]    Script Date: 9/16/2014 2:49:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthInvoiceVendorID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetBudgetMonthInvoiceVendorID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetMonthInvoiceVendorID]    Script Date: 9/16/2014 2:49:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthInvoiceVendorID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetBudgetMonthInvoiceVendorID]  
* Purpose : This PROC would be called to get the details with vendorId
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
[prc_CWI_GetBudgetMonthInvoiceVendorID] 2209,401

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetBudgetMonthInvoiceVendorID]
	@BudgetMonthClassID INT,
	@ClassificationId INT
AS
BEGIN
	select V.Id as VendorId from CWI_BudgetMonthClassVendor BCV
INNER JOIN CWI_BudgetMonthClassification BMC ON BCV.BudgetMonthClassificationID=BMC.ID
INNER JOIN CWI_Vendor V ON V.id=BCV.VendorID and V.ClassificationLookupId=@ClassificationId where BMC.ID=@BudgetMonthClassID;
END

' 
END
GO
