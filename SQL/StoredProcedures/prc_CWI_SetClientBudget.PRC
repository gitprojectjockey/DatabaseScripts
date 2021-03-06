/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientBudget]') AND type in (N'P', N'PC'))
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

exec [prc_CWI_SetClientBudget] @ClientId=13957,@BudgetName=,@BudgetForecast=,@BudgetUsed=,@BudgetCommitted=,@BudgetFrom=,@BudgetTo=,@RevisionId=,@RevisionId=,@ModifiedBy=
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetClientBudget] 
			@BudgetId INT
		   ,@ClientId INT  
           ,@BudgetName VARCHAR(MAX)
           ,@BudgetForecast MONEY
           ,@BudgetUsed MONEY
           ,@BudgetCommitted MONEY
		   ,@SalesForecast decimal(18,0)		  
           ,@BudgetFrom DATETIME
           ,@BudgetTo DATETIME
           ,@RevisionId INT
		   ,@CreatedBy INT
           ,@ModifiedBy INT
		   ,@RowCount int output
		   ,@ErrorMsg varchar(max) OUT
AS
BEGIN

IF ((select BudgetTo from CWI_ClientBudget where  ID=@BudgetId)<=@BudgetTo) 
BEGIN

 


Declare @AffectedID int=0;
DECLARE @Count int;

set @Count=(select count(*) from CWI_ClientBudget 
			where ((CWI_ClientBudget.BudgetFrom between  @BudgetFrom  and @BudgetTo)
			OR ( CWI_ClientBudget.BudgetTo between  @BudgetFrom  and @BudgetTo )
			)
			AND CWI_ClientBudget.ID<>@BudgetId 
			AND [ClientID]=@ClientId);--((@BudgetFrom  between CWI_ClientBudget.BudgetFrom  and CWI_ClientBudget.BudgetTo) or (@BudgetTo  between CWI_ClientBudget.BudgetFrom  and CWI_ClientBudget.BudgetTo)) and ([ClientID]=@ClientId))
IF(@Count=0)
Begin
IF EXISTS(select * from CWI_ClientBudget where CWI_ClientBudget.ClientID=@ClientId and ID=@BudgetId)
BEGIN
DECLARE @BudgetAvailable MONEY;
	SET @BudgetAvailable=@BudgetForecast-(@BudgetUsed+@BudgetCommitted);

BEGIN
	INSERT INTO 
		[dbo].[CWI_History_ClientBudget]
           ([ClientBudgetId]
           ,[ClientID]
           ,[BudgetName]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           --,[BudgetAvailable]
		   ,[SalesForecast]
           ,[BudgetFrom]
           ,[BudgetTo]
           ,[RevisionId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
	SELECT [ID]
		  ,[ClientID]
		  ,[BudgetName]
		  ,[BudgetForecast]
		  ,[BudgetUsed]
		  ,[BudgetCommitted]
		  --,[BudgetAvailable]
		  ,[SalesForecast]
		  ,[BudgetFrom]
		  ,[BudgetTo]
		  ,[RevisionId]
		  ,[CreatedBy]
		  ,[CreatedOn]
		  ,[ModifiedBy]
		  ,GETDATE()
  FROM [dbo].[CWI_ClientBudget] WHERE ID=@BudgetId;
  SET @AffectedID=SCOPE_IDENTITY();

IF( @AffectedID>0 )
BEGIN

 UPDATE CWI_ClientBudget 
	SET	
		 [BudgetName]=@BudgetName
		--,[BudgetForecast]=@BudgetForecast
		--,[BudgetUsed]=@BudgetUsed
		--,[BudgetCommitted]=@BudgetCommitted
		--,[BudgetAvailable]=@BudgetAvailable
		,[SalesForecast]=@SalesForecast
		,[BudgetFrom]=@BudgetFrom
		,[BudgetTo]=@BudgetTo
		,[RevisionId]=@RevisionId
		,[CreatedBy] =@CreatedBy          
		,[ModifiedBy]=@ModifiedBy
	WHERE
		ID=@BudgetId;
		SET @RowCount = (SELECT @@ROWCOUNT as RowAffected);

		/* Updating Division Budget*/
		INSERT INTO 
		[dbo].[CWI_History_DivisionBudget]
           ([ClientBudgetId]
           ,[DivisionBudgetId]
           ,[DivisionID]
           ,[BudgetName]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
          -- ,[BudgetAvailable]
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
     -- ,[BudgetAvailable]
      ,[BudgetFrom]
      ,[BudgetTo]
      ,[RevisionId]
      ,[CreatedBy]
      ,[CreatedOn]
      ,[ModifiedBy]
      ,[ModifiedOn]
    
  FROM [dbo].[CWI_DivisionBudget] WHERE ClientBudgetID=@BudgetId ;

  UPDATE [dbo].[CWI_DivisionBudget]
   SET 
		[BudgetFrom]=@BudgetFrom
		,[BudgetTo]=@BudgetTo 
      ,[RevisionId] = RevisionId+1     
      ,[ModifiedBy] =@ModifiedBy
      ,[ModifiedOn] = GETDATE()
     
      
 WHERE
		ClientBudgetID =@BudgetId;



END

	
		END
		END
	ELSE		 SET @RowCount=0;
END
ELSE
begin
	SET @RowCount=0;
					set @ErrorMsg = ''Already budget avialable for selected months''
					return
				end
				END
				ELSE
begin
	SET @RowCount=0;
					set @ErrorMsg = ''Already budget avialable for selected months''
					return
				end

END' 
END
GO
