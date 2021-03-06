/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMarketingPlansByDivision]    Script Date: 1/27/2014 2:12:10 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMarketingPlansByDivision]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetMarketingPlansByDivision]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMarketingPlansByDivision]    Script Date: 1/27/2014 2:12:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMarketingPlansByDivision]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/******************************************************************* 
* PROCEDURE: prc_CWI_GetMarketingPlansByDivision 
* Purpose : This PROC would be called to retrieve the all the plans for the given division
* Invoked from : CopyJob.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY 
* DATE      AUTHOR          DESCRIPTION  

********************************************************************** 
Execution example :
********************************************************************** 
exec prc_CWI_GetMarketingPlansByDivision 14836
**********************************************************************/  
CREATE PROCEDURE [dbo].[prc_CWI_GetMarketingPlansByDivision]
@inDivisionId int
AS
BEGIN
	BEGIN TRY

		SELECT ID AS MarketingPlanId,PlanName,PlanDescription,PlanFrom,PlanTo,
		PlanName+'' [''+CONVERT(VARCHAR,MONTH(PlanFrom),103)+''/''+CONVERT(VARCHAR,YEAR(PlanFrom),103)+'' - ''+CONVERT(VARCHAR,MONTH(PlanTo),103)+''/''+CONVERT(VARCHAR,YEAR(PlanTo),103)+'']'' AS MarketingPlanName,
		PlanBudget,PlanBudgetUsed,PlanBudgetAvailable,PlanBudgetCommitted
		FROM CWI_MarketingPlan
		WHERE DivisionID=@inDivisionId AND IsDeleted=0
		--AND PlanTo > GETDATE()

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW; 
	END CATCH
END

	' 
END
GO
