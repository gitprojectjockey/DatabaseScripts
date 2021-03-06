/****** Object:  StoredProcedure [dbo].[prc_CWI_SetDivisionBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetDivisionBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetDivisionBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetDivisionBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetDivisionBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientBudget  
* Purpose : This PROC would be called to Update the client budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_SetDivisionBudget] @ClientId=13957,@BudgetName=,@BudgetForecast=,@BudgetUsed=,@BudgetCommitted=,@BudgetFrom=,@BudgetTo=,@RevisionId=,@RevisionId=,@ModifiedBy=
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetDivisionBudget] 
			@DivisionBudgetId INT
			,@ClientBudgetId INT
			,@DivisionId INT  
			,@BudgetName VARCHAR(MAX)
			--,@BudgetForecast MONEY
			--,@BudgetUsed MONEY
			--,@BudgetCommitted MONEY				
			,@RevisionId INT
			,@CreatedBy INT
			,@ModifiedBy INT
			--,@RowCount int output
			,@OutDivisionId int output
AS
BEGIN

IF EXISTS(select * from CWI_DivisionBudget where CWI_DivisionBudget.DivisionID=@DivisionID)
	BEGIN
--DECLARE @BudgetAvailable MONEY;
	--SET @BudgetAvailable=@BudgetForecast-(@BudgetUsed+@BudgetCommitted);

BEGIN
	INSERT INTO 
		[dbo].[CWI_History_DivisionBudget]
           ([ClientBudgetId]
           ,[DivisionBudgetId]
           ,[DivisionID]
           ,[BudgetName]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[BudgetFrom]
           ,[BudgetTo]
           ,[RevisionId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
	SELECT 
      [ClientBudgetID]
	  ,[ID]
      ,[DivisionID]
      ,[BudgetName]
      ,[BudgetForecast]
      ,[BudgetUsed]
	  ,[BudgetCommitted]
      ,[BudgetAvailable]
      ,[BudgetFrom]
      ,[BudgetTo]
      ,[RevisionId]
      ,[CreatedBy]
      ,[CreatedOn]
      ,[ModifiedBy]
      ,[ModifiedOn]
    
  FROM [dbo].[CWI_DivisionBudget] WHERE ID=@DivisionBudgetId; --and  [DivisionID]=@DivisionId;
END
	UPDATE [dbo].[CWI_DivisionBudget]
   SET [ClientBudgetID] = @ClientBudgetID
      ,[DivisionID] = @DivisionId
      ,[BudgetName] =@BudgetName
      --,[BudgetForecast] = @BudgetForecast
      --,[BudgetUsed] = @BudgetUsed   //need to check   
      ,[RevisionId] = @RevisionId     
      ,[ModifiedBy] =@ModifiedBy
      ,[ModifiedOn] = GETDATE()
      --,[BudgetCommitted] = @BudgetCommitted
      --,[BudgetAvailable] = @BudgetAvailable
      
 WHERE
		[ID] =@DivisionBudgetId; --and DivisionID=@DivisionId;
		 --SET @RowCount = (SELECT @@ROWCOUNT as RowAffected)
		set @OutDivisionId=@DivisionId;--( select CWI_DivisionBudget.DivisionID from CWI_DivisionBudget where CWI_DivisionBudget.DivisionID= @DivisionId);
END
ELSE		

	INSERT INTO [dbo].[CWI_DivisionBudget]
           ([ClientBudgetID]
           ,[DivisionID]
           ,[BudgetName]
          -- ,[BudgetForecast]
           --,[BudgetUsed]
          
           ,[RevisionId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
          -- ,[BudgetCommitted]
           --,[BudgetAvailable]
          )
     VALUES
           (@ClientBudgetID
           ,@DivisionID
           ,@BudgetName
          -- ,@BudgetForecast
          -- ,@BudgetUsed
           --,@BudgetTo
           ,0
		   ,@CreatedBy
		   ,GETDATE()
		   ,@ModifiedBy
		   ,GETDATE()
		  -- ,@BudgetCommitted
		   --,@BudgetAvailable
		   --,@BudgetFrom
		   )

		 --SET @RowCount = (SELECT @@ROWCOUNT as RowAffected)
		 set @OutDivisionId= SCOPE_IDENTITY();
END' 
END
GO
