/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionBudgetDetailByDivisionID]    Script Date: 8/7/2014 10:18:36 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionBudgetDetailByDivisionID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDivisionBudgetDetailByDivisionID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionBudgetDetailByDivisionID]    Script Date: 8/7/2014 10:18:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionBudgetDetailByDivisionID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************  
* PROCEDURE: prc_CWI_GetDivisionBudgetDetailByDivisionID  
* Purpose : This PROC would be called to get the details with division budget
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetDivisionBudgetDetailByDivisionID] @DivisionId=15644
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetDivisionBudgetDetailByDivisionID] 
	@DivisionId int=null,
	@BudgetId int=null
	
AS
BEGIN

Declare @BudId Int;
Declare @TempBudget table
(
  Id int
)
	INSERT INTO @TempBudget SELECT distinct(CWI_ClientBudget.[ID]) FROM [dbo].[CWI_ClientBudget]
	Inner join
		CWI_Client on 	[CWI_ClientBudget].ClientID=CWI_Client.ParentID AND CWI_Client.ID=@DivisionId 
	LEFT OUTER JOIN
		CWI_DivisionBudget ON CWI_Client.ID=CWI_DivisionBudget.DivisionID order by CWI_ClientBudget.id desc;
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
		SELECT 
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
		 FROM [dbo].[CWI_ClientBudget] CB

		INNER JOIN
			CWI_Client C
		ON
			CB.ClientID=C.ParentID AND CB.ID IN (Select Id From @TempBudget)
		 LEFT JOIN
			CWI_DivisionBudget DB
		ON
			C.ID=DB.DivisionID	WHERE   DB.Id IS NULL;

IF( ISNULL(@DivisionId,0)>0 AND ISNULL(@BudgetId,0)=0)
BEGIN	

	
	SELECT 
		TOP 1 --ISNULL([CWI_DivisionBudget].[ID],0) as DivisionBudgetId
		CWI_DivisionBudget.ID as DivisionBudgetId
      ,CWI_ClientBudget.Id as BudgetId
      ,[CWI_Client].[ID] as DivisionID
      ,ISNULL([CWI_DivisionBudget].[BudgetName], CWI_ClientBudget.BudgetName) BudgetName
	  ,CWI_Client.ClientCode  +'' - ''+  CWI_Client.ClientName as DivisionName
      ,ISNULL([CWI_DivisionBudget].[BudgetForecast],0.00) as BudgetForecast
      ,ISNULL([CWI_DivisionBudget].[BudgetUsed],0.00) as BudgetUsed
	  ,ISNULL([CWI_ClientBudget].[SalesForecast],0.00) as SalesForecast
      ,CWI_DivisionBudget.[BudgetTo]
      ,ISNULL([CWI_DivisionBudget].[RevisionId],0) as RevisionId
      ,ISNULL([CWI_DivisionBudget].[BudgetCommitted],0.00) as BudgetCommitted
      ,ISNULL([CWI_DivisionBudget].[BudgetAvailable],0.00) as BudgetAvailable
      ,CWI_DivisionBudget.[BudgetFrom]

 
  FROM [dbo].[CWI_DivisionBudget]

Inner join
	CWI_ClientBudget
on
	[CWI_ClientBudget].ID=[CWI_DivisionBudget].ClientBudgetID
	Inner join CWI_Client
	ON 
	CWI_Client.ID=CWI_DivisionBudget.DivisionID --AND GETDATE() BETWEEN [CWI_ClientBudget].[BudgetFrom] AND [CWI_ClientBudget].[BudgetTo]
	AND CWI_DivisionBudget.DivisionID= @DivisionId ORDER BY CWI_ClientBudget.ID desc;

END

	
ELSE
BEGIN
		
	SELECT 
		--TOP 1 --ISNULL([CWI_DivisionBudget].[ID],0) as DivisionBudgetId
		CWI_DivisionBudget.ID as DivisionBudgetId
      ,CWI_ClientBudget.Id as BudgetId
      ,[CWI_Client].[ID] as DivisionID
      ,ISNULL([CWI_DivisionBudget].[BudgetName], CWI_ClientBudget.BudgetName) BudgetName
	  ,CWI_Client.ClientCode  +'' - ''+  CWI_Client.ClientName as DivisionName
      ,ISNULL([CWI_DivisionBudget].[BudgetForecast],0.00) as BudgetForecast
      ,ISNULL([CWI_DivisionBudget].[BudgetUsed],0.00) as BudgetUsed
	  ,ISNULL([CWI_ClientBudget].[SalesForecast],0.00) as SalesForecast
      ,CWI_DivisionBudget.[BudgetTo]
      ,ISNULL([CWI_DivisionBudget].[RevisionId],0) as RevisionId
      ,ISNULL([CWI_DivisionBudget].[BudgetCommitted],0.00) as BudgetCommitted
      ,ISNULL([CWI_DivisionBudget].[BudgetAvailable],0.00) as BudgetAvailable
      ,CWI_DivisionBudget.[BudgetFrom]

 
  FROM [dbo].[CWI_DivisionBudget]

Inner join
	CWI_ClientBudget
on
	[CWI_ClientBudget].ID=[CWI_DivisionBudget].ClientBudgetID
	Inner join CWI_Client
	ON 
	CWI_Client.ID=CWI_DivisionBudget.DivisionID --AND GETDATE() BETWEEN [CWI_ClientBudget].[BudgetFrom] AND [CWI_ClientBudget].[BudgetTo]
	AND CWI_DivisionBudget.DivisionID= @DivisionId AND (CWI_ClientBudget.ID=@BudgetId OR CWI_DivisionBudget.ID=@BudgetId) ORDER BY CWI_ClientBudget.ID desc;
END
	

	
END
 
	

	


' 
END
GO
