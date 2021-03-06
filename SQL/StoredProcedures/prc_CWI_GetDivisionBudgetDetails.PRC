/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionBudgetDetails]    Script Date: 7/23/2014 2:13:03 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionBudgetDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDivisionBudgetDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionBudgetDetails]    Script Date: 7/23/2014 2:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionBudgetDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_GetDivisionBudgetDetails  
* Purpose : This PROC would be called to get the details with Division budget
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
exec [prc_CWI_GetDivisionBudgetDetails] @BudgetId=1152
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetDivisionBudgetDetails] 
	@BudgetId int
AS
BEGIN
	
	/* The following insert statement creates division budget if the division budget is not available for the passed client budget*/
	INSERT INTO [dbo].[CWI_DivisionBudget]
           ([ClientBudgetID]
           ,[DivisionID]
           ,[BudgetName]
           ,[BudgetForecast]
           ,[BudgetUsed]
		   ,[BudgetCommitted]
		   ,[BudgetFrom]
           ,[BudgetTo]
           ,[RevisionId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn] 
           ,[IsActive])
	(SELECT 
		CB.[ID]	
		,C.Id as DivisionID     
		,CB.[BudgetName]
		,0
		,0
		,0
		,CB.[BudgetFrom]
		,CB.[BudgetTo]
		,0		
		,CB.CreatedBy
		,CB.CreatedOn
		,CB.ModifiedBy
		,CB.ModifiedOn
		,1
	FROM CWI_DivisionBudget DB
	INNER JOIN CWI_ClientBudget CB
		ON CB.Id = DB.ClientBudgetID
	RIGHT OUTER JOIN 	CWI_Client C
		ON CB.ClientID = C.ParentID 
	WHERE ClientBudgetID = @BudgetId AND DB.Id IS NULL);

	
	SELECT 
	[CWI_DivisionBudget].[ID] as DivisionBudgetId
      ,ISNULL([CWI_DivisionBudget].[ClientBudgetID],0) as BudgetId
      ,[CWI_DivisionBudget].[DivisionID]
      ,[CWI_ClientBudget].[BudgetName]
	  ,CWI_Client.ClientCode  +'' - ''+  CWI_Client.ClientName as DivisionName
      ,ISNULL(CWI_DivisionBudget.[BudgetForecast],0.00) as BudgetForecast
      ,ISNULL([CWI_DivisionBudget].[BudgetUsed],0.00) as BudgetUsed
      ,[CWI_ClientBudget].[BudgetTo]
      ,ISNULL([CWI_DivisionBudget].[RevisionId],0) as RevisionId      
      ,ISNULL([CWI_DivisionBudget].[BudgetCommitted],0.00) as BudgetCommitted
      ,ISNULL([CWI_DivisionBudget].[BudgetAvailable],0.00) as BudgetAvailable
      ,[CWI_ClientBudget].[BudgetFrom]
	  ,[CWI_DivisionBudget].CreatedBy
		,[CWI_DivisionBudget].CreatedOn
	 ,[CWI_DivisionBudget].ModifiedBy
	  ,[CWI_DivisionBudget].ModifiedOn
 
  FROM [dbo].[CWI_ClientBudget]

	Inner join
		CWI_Client
	on
		[CWI_ClientBudget].ClientID=CWI_Client.ParentID AND [CWI_ClientBudget].ID=@BudgetId --AND GETDATE() BETWEEN [CWI_ClientBudget].[BudgetFrom] AND [CWI_ClientBudget].[BudgetTo]
	inner join
		CWI_DivisionBudget
	ON
		CWI_Client.ID=CWI_DivisionBudget.DivisionID and CWI_ClientBudget.ID=CWI_DivisionBudget.ClientBudgetID ;
	

	
END
 
	

	





' 
END
GO
