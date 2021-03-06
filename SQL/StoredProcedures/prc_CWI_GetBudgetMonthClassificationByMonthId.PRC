IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthClassificationByMonthId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetBudgetMonthClassificationByMonthId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgetMonthClassificationByMonthId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetBudgetMonthClassificationByMonthId]  
* Purpose : This PROC would be called to get the details with Division budget
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_GetBudgetMonthClassificationByMonthId @BudgetMonthId=354, @DivisionBudgetID=413,@ClassificationLookupID=402

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetBudgetMonthClassificationByMonthId]
	@BudgetMonthId int,
	@DivisionBudgetID int,
	@ClassificationLookupID int
AS
BEGIN
	SELECT [CWI_BudgetMonthClassification].[ID]
      ,[CWI_BudgetMonthClassification].[BudgetMonthID]
      ,[CWI_BudgetMonthClassification].[ClassificationLookupID]      
     ,[CWI_BudgetMonth].DivisionBudgetID
  FROM [dbo].[CWI_BudgetMonthClassification] 
  INNER JOIN
		[dbo].[CWI_BudgetMonth] 
		ON
			[CWI_BudgetMonth].ID=[CWI_BudgetMonthClassification].BudgetMonthID
			 AND [CWI_BudgetMonthClassification].[ClassificationLookupID]=@ClassificationLookupID 
			AND [CWI_BudgetMonthClassification].BudgetMonthID=@BudgetMonthId
			 and [CWI_BudgetMonth].DivisionBudgetID=@DivisionBudgetID;
 
END
' 
END
GO
