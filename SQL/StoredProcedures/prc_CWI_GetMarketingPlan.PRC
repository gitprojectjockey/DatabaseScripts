/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMarketingPlan]    Script Date: 1/7/2014 9:37:26 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMarketingPlan]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetMarketingPlan]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetMarketingPlan]    Script Date: 1/7/2014 9:37:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetMarketingPlan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetMarketingPlan  
* Purpose : This PROC would be called TO get the marketing plan details
* Invoked from : MarketingPlan.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetMarketingPlan 1
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetMarketingPlan] 
    @planid int =0
AS
BEGIN

	SELECT * FROM
	(
	(
	    SELECT 
		M.ID,
		M.PlanName,
		M.PlanDescription,
		M.PlanFrom,
		M.PlanTo,
		M.PlanBudget,
		M.PlanBudgetAvailable,
		M.PlanBudgetUsed,
		M.PlanBudgetCommitted,
		M.DivisionID,
		M.JobCount,
		C.ClientCode DivisionCode,
		C.ClientName DivisionName,
		CP.ID ClientId,
		CP.ClientCode ClientCode,
		CP.ClientName ClientName,
		LastInvoiceDate = dbo.fnc_GetLastInvoiceGeneratedDate(M.DivisionID)
	
	FROM CWI_MarketingPlan M (NOLOCK)
		inner join CWI_Client C (NOLOCK)
				on M.DivisionID = C.ID
		inner join CWI_Client CP (NOLOCK)
			on c.ParentID = CP.ID

				WHERE 					M.ID = @planid
				)P
	
	CROSS APPLY [dbo].[fnc_GetDivisionMonthlyBudget](P.DivisionId, P.PlanFrom, P.PlanTo)

	)

END

' 
END
GO
