/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgets]    Script Date: 8/7/2014 6:48:01 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgets]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetBudgets]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetBudgets]    Script Date: 8/7/2014 6:48:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetBudgets]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetBudgets  
* Purpose : This PROC would be called to get the client budgets
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetBudgets] @ClientId=0,@DivisionId=15644
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetBudgets] 
	@ClientId int=0,
	@DivisionId Int=0
AS
BEGIN

IF( ISNUll(@ClientId,0)>0 AND ISNULL(@DivisionId,0)=0 )
	BEGIN

		SELECT 
			distinct (CB.[ID]) as BudgetId
			,CB.BudgetName
			,RIGHT(CONVERT(varchar(10), CB.BudgetFrom,103),7)+'' - '' + RIGHT(CONVERT(varchar(50),CB.BudgetTo,103),7) as BudgetTerm
			,ISNULL(CAST( (CB.[BudgetForecast]) as decimal(20,2)) ,0.00) as BudgetForecast
			,ISNULL(CAST( (CB.BudgetUsed) as decimal(20,2)),0.00) as BudgetUsed
			,ISNULL(CAST((CB.BudgetCommitted) as decimal(20,2)),0.00) as BudgetCommitted
			,ISNULL(CAST((CB.BudgetAvailable)as decimal(20,2)),0.00) as BudgetAvailable
			,CONVERT(VARCHAR(20), CB.CreatedOn, 22)CreatedOn
			,U.Names CreatedBy
		FROM 
			[dbo].[CWI_ClientBudget] CB
		INNER JOIN
			[dbo].CWI_Client C ON C.ID=CB.ClientID
		INNER JOIN 
			CWI_User U	ON U.Id=CB.CreatedBy
		WHERE ClientID=@ClientId ORDER BY CB.ID DESC

	END
ELSE
	BEGIN
		SELECT 
		distinct (CB.[ID]) as BudgetId
		,DB.BudgetName
		,RIGHT(CONVERT(varchar(10), DB.BudgetFrom,103),7)+'' - '' + RIGHT(CONVERT(varchar(50),DB.BudgetTo,103),7) as BudgetTerm
		,ISNULL(CAST( (DB.[BudgetForecast]) as decimal(20,2)) ,0.00) as BudgetForecast
		,ISNULL(CAST( (DB.BudgetUsed) as decimal(20,2)),0.00) as BudgetUsed
		,ISNULL(CAST((DB.BudgetCommitted) as decimal(20,2)),0.00) as BudgetCommitted
		,ISNULL(CAST((DB.BudgetAvailable)as decimal(20,2)),0.00) as BudgetAvailable
		,CONVERT(VARCHAR(20), DB.CreatedOn, 22)CreatedOn
		,U.Names CreatedBy
	FROM 
		CWI_ClientBudget CB
	INNER JOIN
		[dbo].[CWI_DivisionBudget] DB ON CB.ID=DB.ClientBudgetID
	INNER JOIN
		[dbo].CWI_Client C ON C.ID=DB.DivisionID
	INNER JOIN 
		CWI_User U	ON U.Id=DB.CreatedBy
	WHERE DivisionID=@DivisionId ORDER BY CB.ID DESC
	END
	
	
END
' 
END
GO
