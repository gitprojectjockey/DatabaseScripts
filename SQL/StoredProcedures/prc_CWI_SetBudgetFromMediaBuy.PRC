/****** Object:  StoredProcedure [dbo].[prc_CWI_SetBudgetFromMediaBuy]    Script Date: 8/1/2014 4:04:15 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetBudgetFromMediaBuy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetBudgetFromMediaBuy]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetBudgetFromMediaBuy]    Script Date: 8/1/2014 4:04:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetBudgetFromMediaBuy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE:  prc_CWI_SetBudgetFromMediaBuy
* Purpose : This PROC would be called TO UPDATE committed and used budget based on invoice amount
* Invoked from : trigger for the tables CWI_JobMediaBuy & CWI_JobService
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION 
1/3/2014    VIJESH
17Jun2014   Vijesh			Modified procedure for updating in marketing plan based on media buy & service fee changes
********************************************************************** 
Execution example :,
**********************************************************************  
exec prc_CWI_SetBudgetFromMediaBuy 1343
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetBudgetFromMediaBuy]	
	@inJobId bigint
AS
BEGIN	
	BEGIN TRY
		DECLARE @inMarketingPlanId int
		DECLARE @tblCost TABLE(
		[Committed] DECIMAL,
		Used DECIMAL
       
	)
	
	DECLARE @tblPlanJobs TABLE
	(
		Id bigint,
		InvoiceGeneratedDate datetime,
		InvoiceId bigint
	)

	 
	SELECT @inMarketingPlanId = MarketingPlanId FROM CWI_Job WHERE  Id = @inJobId
	INSERT INTO @tblPlanJobs
	SELECT Id, InvoiceGeneratedDate,InvoiceId FROM CWI_Job 
	WHERE  MarketingPlanId = @inMarketingPlanId

	/*  Get the cost details at media buy level and keep in table variable */
	INSERT INTO @tblCost
	SELECT

		CASE WHEN JMB.DNR=1 OR JMB.IsCancelled = 1 OR JMB.IsRemoved = 1 OR JMB.IsComplimentaryInvoice = 1 THEN 0
			ELSE 
				CASE WHEN InvoiceGeneratedDate IS NULL THEN ISNULL(ActualInvoice,0) ELSE 0 END
		END Commited,  
		CASE WHEN JMB.DNR=1 OR JMB.IsCancelled = 1 OR JMB.IsRemoved = 1 OR JMB.IsComplimentaryInvoice = 1 THEN 0
			ELSE
				CASE WHEN InvoiceGeneratedDate IS NULL THEN 0 ELSE ISNULL(ActualInvoice,0) END 
		END Used
	FROM @tblPlanJobs J
		   INNER JOIN CWI_JobMediaBuy  JMB
				  ON J.Id = JMB.JobId
 
		  
	/*  Get the cost details at service fee level and keep in table variable */
	INSERT INTO @tblCost
	
	SELECT 
		CASE WHEN JS.IsDeleted = 1 OR JS.IsComplimentary = 1 THEN 0
			ELSE
				CASE WHEN J.InvoiceId IS NULL THEN ServiceFee ELSE 0 END 
		END Commited,  
		CASE WHEN JS.IsDeleted = 1 OR JS.IsComplimentary = 1 THEN 0
			ELSE
				CASE WHEN J.InvoiceId IS NULL THEN 0 ELSE ServiceFee END 
		END Used
	FROM @tblPlanJobs J
		   INNER JOIN CWI_JobService JS
				  ON J.Id = JS.JobId
	
	DECLARE @Commited decimal(18,2),  @Used decimal(18,2)
	SELECT @Commited = SUM([Committed]) , @Used = SUM(Used)   FROM @tblCost

		UPDATE [dbo].[CWI_MarketingPlan]	
			SET PlanBudgetUsed=@Used,
			PlanBudgetCommitted=@Commited
			WHERE ID=@inMarketingPlanId
		
	END TRY
	BEGIN CATCH
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
END





' 
END
GO
