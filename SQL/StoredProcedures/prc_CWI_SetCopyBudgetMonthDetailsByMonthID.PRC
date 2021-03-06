/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyBudgetMonthDetailsByMonthID]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyBudgetMonthDetailsByMonthID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCopyBudgetMonthDetailsByMonthID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyBudgetMonthDetailsByMonthID]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyBudgetMonthDetailsByMonthID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_SetCopyBudgetMonthDetailsByMonthID]  
* Purpose : This PROC would be called to insert(copy) the details from one month to another month
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
prc_CWI_SetCopyBudgetMonthDetailsByMonthID @BudgetMonthID=105,@Month=9,@UserID=8,@OutMonthID=0
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetCopyBudgetMonthDetailsByMonthID] 
	@BudgetMonthID INT,
	--@DivisionBudgetID INT,
	@Month Int,
	@Year Int,
	@UserID Int,
	@OutMonthID int Out
AS
BEGIN
DECLARE @DivisionBudgetId INT=0, @UpdateBudgetMonthID int=0, @RowAffected int=0,@ClientBudgetID int =0;
 set @DivisionBudgetId=(SELECT DivisionBudgetID from CWI_BudgetMonth WHERE ID=@BudgetMonthID);
 SET @ClientBudgetID=(SELECT ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetId);
set @UpdateBudgetMonthID=(select ID from CWI_BudgetMonth where DivisionBudgetID=@DivisionBudgetID and MONTH=@Month AND [Year]=@Year);
IF( NOT EXISTS(select ID from CWI_BudgetMonth where DivisionBudgetID=@DivisionBudgetID and MONTH=@Month AND [Year]=@Year))
BEGIN

 INSERT INTO [dbo].[CWI_BudgetMonth]
           ([DivisionBudgetID]
           ,[Month]
           ,[Year]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           --,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
SELECT [DivisionBudgetID]
      ,@Month
      ,@Year
      ,[BudgetForecast]
      ,0
      ,0
     -- ,[BudgetForecast]
      ,@UserID
      ,GETDATE()
      ,@UserID
      ,GETDATE()
  FROM [dbo].[CWI_BudgetMonth] WHERE ID=@BudgetMonthID;

  Set @OutMonthID=SCOPE_IDENTITY();
 
 
IF( @OutMonthID>0 )
set @DivisionBudgetId=(SELECT DivisionBudgetID from CWI_BudgetMonth WHERE ID=@OutMonthID);
 SET @ClientBudgetID=(SELECT ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetId);
	EXEC prc_CWI_SetMonthBudgetHistory @UserId, @DivisionBudgetID,@ClientBudgetID
END

ELSE

BEGIN 
BEGIN TRANSACTION
INSERT INTO [dbo].[CWI_History_BudgetMonth]
           ([BudgetMonthId]
           ,[DivisionBudgetID]
           ,[Month]
           ,[Year]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
		SELECT [ID]
		   ,[DivisionBudgetID]
           ,[Month]
           ,[Year]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
		FROM CWI_BudgetMonth WHERE ID=@UpdateBudgetMonthID;

		   DECLARE @tblSourceMonth TABLE
		   ( 
			id1 int,
			[Month1] int,
			[year1] int,
			BudgetForecast1	money

		   )

		   INSERT INTO @tblSourceMonth
		   select @UpdateBudgetMonthID, Month, Year, sum(BudgetForecast) from CWI_BudgetMonth
		    where ID=@BudgetMonthID
			GROUP BY Month, Year


		UPDATE CWI_BudgetMonth
		SET
			[DivisionBudgetID]= @DivisionBudgetId
			,[Month]=@Month
			,[Year]=@Year--t.year1
			,[BudgetForecast]=t.BudgetForecast1
			--,[BudgetAvailable]= t.BudgetForecast1 - BudgetCommitted + BudgetUsed
			,[ModifiedBy]=@UserID
			,[ModifiedOn]=GETDATE() 
		FROM
			 @tblSourceMonth t 
		WHERE  ID = t.id1 AND ID=@UpdateBudgetMonthID;


		SET @OutMonthID=@UpdateBudgetMonthID;

		IF( @OutMonthID>0)
		BEGIN
		EXEC prc_CWI_SetMonthBudgetHistory @UserId, @DivisionBudgetID,@ClientBudgetID
		END
		
IF( @@rowcount>0 )

	BEGIN 
		COMMIT TRANSACTION;
	END
ELSE
	BEGIN	
		ROLLBACK TRANSACTION;
		SET @OutMonthID=0;
	END
	
	--END TRAN
	
END

		  

   
END

' 
END
GO
