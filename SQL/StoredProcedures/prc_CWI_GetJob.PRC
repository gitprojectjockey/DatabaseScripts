/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJob]    Script Date: 10/14/2014 6:52:24 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJob]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJob]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJob]    Script Date: 10/14/2014 6:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**************************************************************************************************
* PROCEDURE: prc_CWI_GetJob
* Purpose : This Proc would be called to retrieve the Job Summary details for a specific JobId
* Invoked from : Jobs.aspx
* CREATED: Bala
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetJob 12001
exec prc_CWI_GetJob 1
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetJob]       
@inJobId bigint
AS
BEGIN
	BEGIN TRY
		SELECT * FROM
		( 
		(
		SELECT J.ID,
		J.MarketingPlanID,
		J.ClassificationId,
		J.JobName,
		J.JobSummary,
		J.InvoiceDate,
		J.JobDueBy,
		J.JobAssignedTo,
		J.IsQuote,
		J.IsPickup,
		J.PickupJobNumber,
		J.AdDescription,
		ISNULL(J.JobStatusLookupId,'''') as JobStatusLookupId ,
		ISNULL(J.InvoiceId,0) as InvoiceId,
		J.PONumber,
		ISNULL(L.LookupName,'''') AS LookupName,
		J.IsCancelled,
		J.CancelledDateTime,
		J.IsSelectiveCancel,
		ISNULL(I.InvoiceNo,0) as InvoiceNumber,
		J.IsCreativeAdCopy,
		J.IsClientView,
		J.EstimatedJobStartDate,
		J.EstimatedCompletion,
		ISNULL(J.EstimatedPeriodLookupId,'''') as EstimatedPeriodLookupId ,
		J.EstimatedPeriod,
		J.TemplateId,
		TT.Name,
		 
			M.ID AS MPlanId,
			M.PlanName,
			M.PlanDescription,
			M.PlanFrom,
			M.PlanTo,
			M.PlanBudget,
			M.PlanBudgetAvailable,
			M.PlanBudgetUsed,
			M.DivisionID,
			C.ClientCode DivisionCode,
			C.ClientName DivisionName,
			CP.ID ClientId,
			CP.ClientCode ClientCode,
			CP.ClientName ClientName

			FROM [dbo].CWI_Job as J
			LEFT OUTER JOIN CWI_TaskTemplate TT	ON TT.Id=J.TemplateID
			LEFT OUTER JOIN [dbo].Lookup as L ON J.JobStatusLookupId=L.Id 
			INNER JOIN CWI_MarketingPlan M (NOLOCK) ON M.ID=J.MarketingPlanId
			inner join CWI_Client C (NOLOCK) on M.DivisionID = C.ID
			inner join CWI_Client CP (NOLOCK) on c.ParentID = CP.ID
			LEFT JOIN CWI_Invoice I ON I.ID=J.InvoiceId
			WHERE J.[Id]=@inJobId		
			)P
	
			CROSS APPLY [dbo].[fnc_GetDivisionMonthlyBudget](P.DivisionId, P.PlanFrom, P.PlanTo)

			)
		
		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	


' 
END
GO
