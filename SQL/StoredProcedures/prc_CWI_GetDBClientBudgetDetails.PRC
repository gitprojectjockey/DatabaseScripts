/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDBClientBudgetDetails]    Script Date: 7/9/2014 7:25:11 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDBClientBudgetDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDBClientBudgetDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDBClientBudgetDetails]    Script Date: 7/9/2014 7:25:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDBClientBudgetDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetDBClientBudgetDetails  
* Purpose : This PROC would be called to get the details with Division budget
* Invoked from : Dashboard.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
exec [prc_CWI_GetDBClientBudgetDetails] @UserId=8
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetDBClientBudgetDetails] 
	@UserId Int
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @StartDate DATETIME, @EndDate DATETIME
	SET @StartDate = DATEADD(yy, DATEDIFF(yy,0,getdate()), 0);
	SET @EndDate=DATEADD(yy, DATEDIFF(yy,0,getdate()) + 1, -1);

	SELECT
		DB.DivisionID,		
		C.ClientCode +'' - ''+ C.ClientName DivisionCode,
		C.ClientName as DivisionName,
		SUM(ISNULL(CAST(BM.[BudgetForecast] as decimal(18,2)) ,00000000.00)) as BudgetForecast
		,SUM(ISNULL(CAST(BM.[BudgetUsed] as decimal(18,2)),00000000.00)) as BudgetUsed
		,SUM(ISNULL(CAST(BM.[BudgetCommitted]as decimal(18,2)),00000000.00)) as BudgetCommitted
		,SUM(ISNULL(CAST(BM.[BudgetAvailable]as decimal(18,2)),00000000.00)) as BudgetAvailable
	FROM 
		CWI_BudgetMonth BM
	RIGHT JOIN
		CWI_DivisionBudget DB ON DB.ID=BM.DivisionBudgetID AND BM.BudgetMonthStartDate>=@StartDate AND BM.BudgetMonthStartDate<=@EndDate
		
	INNER JOIN 
		dbo.fnc_GetClientsForUser(@UserId, ''D'') C	ON DB.DivisionID = C.ClientId AND  DB.IsActive=1
	GROUP BY 
		DB.ID,DivisionID,c.ClientCode,c.ClientName,DB.BudgetFrom,DB.BudgetTo;

   END
' 
END
GO
