/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID]    Script Date: 7/19/2013 1:35:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID]    Script Date: 7/19/2013 1:35:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID 
* Purpose : This PROC would be called TO get all the active vendors 
* Invoked from : Client_Budget.ascx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID @BudgetMonthClassificationID="25,73,"
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID] 
	@BudgetMonthClassificationID varchar(MAX)
AS
BEGIN
	SELECT VendorID, ID, BudgetMonthClassificationID From CWI_BudgetMonthClassVendor WHERE BudgetMonthClassificationID in(Select items From fnc_SplitCommaSeparatedValuesIntoTable(@BudgetMonthClassificationID,'',''))
END
' 
END
GO
