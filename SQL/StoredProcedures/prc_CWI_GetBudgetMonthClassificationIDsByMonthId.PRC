/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetMonthClassificationIDsByMonthId]    Script Date: 7/2/2013 3:04:47 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthClassificationIDsByMonthId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetBudgetMonthClassificationIDsByMonthId]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgetMonthClassificationIDsByMonthId]    Script Date: 7/2/2013 3:04:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthClassificationIDsByMonthId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetBudgetMonthClassificationIDsByMonthId]  
* Purpose : This PROC would be called to get the Classification Ids
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_GetBudgetMonthClassificationsByMonthId @BudgetMonthId=1

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetBudgetMonthClassificationIDsByMonthId] 
	@BudgetMonthID INT
AS
BEGIN
	SELECT ID,ClassificationLookupID FROM CWI_BudgetMonthClassification WHERE BudgetMonthID=@BudgetMonthID;
END
' 
END
GO
