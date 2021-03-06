IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorInfoByClassificationId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorInfoByClassificationId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorInfoByClassificationId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetVendorInfoByClassificationId]  
* Purpose : This PROC would be called to get the details with Vednor info
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_GetVendorInfoByClassificationId @VendorID=6913,@ClassificationId=401

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetVendorInfoByClassificationId] 
	@VendorID int,
	@ClassificationId int
AS
BEGIN
	SELECT [CWI_BudgetMonthClassVendor].ID as BudgetMonthVendorId
  FROM [CWI_BudgetMonthClassVendor]
  INNER JOIN
  [dbo].[CWI_Vendor] on CWI_BudgetMonthClassVendor.VendorID=CWI_Vendor.Id
  
	INNER JOIN
  [dbo].[CWI_BudgetMonthClassification] 
ON
	[CWI_BudgetMonthClassVendor].BudgetMonthClassificationID=[CWI_BudgetMonthClassification].ID
	INNER JOIN
		[dbo].[CWI_BudgetMonth] 
ON
	[CWI_BudgetMonth].ID=[CWI_BudgetMonthClassification].BudgetMonthID			
	INNER JOIN
	CWI_DivisionBudget
ON
	CWI_DivisionBudget.ID=CWI_BudgetMonth.DivisionBudgetID WHERE CWI_BudgetMonthClassVendor.VendorID=@VendorId
	 and CWI_BudgetMonthClassVendor.BudgetMonthClassificationID=@ClassificationId;
END
' 
END
GO
