/****** Object:  StoredProcedure [dbo].[prc_CWI_AddDivisionBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_AddDivisionBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_AddDivisionBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_AddDivisionBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_AddDivisionBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_AddDivisionBudget  
* Purpose : This PROC would be called to Create the Division budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec [prc_CWI_AddDivisionBudget] @ClientId=13957,@DivisionId=,@Costcenter=,@BudgetName=,@BudgetForecast=,@BudgetUsed=,@BudgetCommitted=,@BudgetFrom=,@BudgetTo=,@RevisionId=,@ModifiedBy=
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_AddDivisionBudget] 
		@ClientBudgetID INT
		,@DivisionID  INT
		,@BudgetName VARCHAR(MAX)
		,@BudgetForecast MONEY
		,@BudgetUsed MONEY
		,@BudgetCommitted MONEY		  
		,@BudgetFrom DATETIME
		,@BudgetTo DATETIME
		,@RevisionId INT
		,@CreatedBy INT
		,@ModifiedBy INT
		,@RowCount int output
		,@OutDivisionId int output
AS
BEGIN
BEGIN TRY
DECLARE @DivisionBudgetRowCount int;
IF NOT EXISTS(select * from CWI_DivisionBudget where  CWI_DivisionBudget.DivisionID=@DivisionID)-- CWI_DivisionBudget.BudgetFrom >=@BudgetFrom and CWI_DivisionBudget.BudgetTo<=@BudgetTo and)
	BEGIN
	DECLARE @BudgetAvailable MONEY;
	SET @BudgetAvailable=@BudgetForecast-(@BudgetUsed+@BudgetCommitted);

	INSERT INTO [dbo].[CWI_DivisionBudget]
           ([ClientBudgetID]
           ,[DivisionID]
           ,[BudgetName]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetTo]
           ,[RevisionId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
           ,[BudgetCommitted]
          -- ,[BudgetAvailable]
           ,[BudgetFrom])
     VALUES
           (@ClientBudgetID
           ,@DivisionID
           ,@BudgetName
           ,@BudgetForecast
           ,@BudgetUsed
           ,@BudgetTo
           ,@RevisionId
		   ,@CreatedBy
		   ,GETDATE()
		   ,@ModifiedBy
		   ,GETDATE()
		   ,@BudgetCommitted
		  -- ,@BudgetAvailable
		   ,@BudgetFrom)

		 SET @RowCount = (SELECT @@ROWCOUNT as RowAffected)
		 set @OutDivisionId= SCOPE_IDENTITY();
END
ELSE		 SET @RowCount=0;
END TRY
BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
END
' 
END
GO
