/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID]  
* Purpose : This PROC would be called to insert(copy) the Budget details from one Vendor to another Vendor
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************
Declare  @OutMonthServiceID int
prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID @MonthServiceID=431,2,477,8,
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID] 
	@MonthServiceID  INT,
	@ServiceID Int,	
	@BudgetMonthID INT,
	@UserID int,
	@OutMonthServiceID  int Out
AS
BEGIN

DECLARE @DivisionBudgetID int=0,@UpdateMonthServiceID int=0, @Count int=0,@ClientBudgetID int =0 ;
SET @UpdateMonthServiceID=(Select ID from CWI_BudgetMonthService where BudgetMonthId=@BudgetMonthID AND ServiceID=@ServiceID);
--SET @Count=(Select Count(*) from CWI_BudgetMonthService where BudgetMonthId=@BudgetMonthID AND ServiceID=@ServiceID);
SET  @DivisionBudgetID= (Select DivisionBudgetID from CWI_BudgetMonth where ID=@BudgetMonthID);
SET @ClientBudgetID=(Select ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetID); 
IF( (NOT EXISTS(SELECT ID from CWI_BudgetMonthService Where BudgetMonthID=@BudgetMonthID AND  ServiceID=@ServiceID)) AND @OutMonthServiceID=0)--ServiceID=@ServiceID and 
BEGIN
	INSERT INTO [dbo].[CWI_BudgetMonthService]
			   ([BudgetMonthId]
			   ,[ServiceID]
			   ,[BudgetForecast]
			   ,[BudgetUsed]
			   ,[BudgetCommitted]
			  -- ,[BudgetAvailable]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn])
	SELECT		@BudgetMonthID
			   ,@ServiceID
			   ,[BudgetForecast]
			   ,0
			   ,0
			  -- ,[BudgetForecast]
			   ,@UserID
			   ,[CreatedOn]
			   ,@UserID
			   ,[ModifiedOn]
	  FROM [dbo].[CWI_BudgetMonthService] WHERE ID=@MonthServiceID;

  Set @OutMonthServiceID=SCOPE_IDENTITY();


END

ELSE IF( @MonthServiceID=0 AND @OutMonthServiceID>0)
BEGIN
	INSERT INTO [dbo].[CWI_BudgetMonthService]
			   ([BudgetMonthId]
			   ,[ServiceID]
			   ,[BudgetForecast]
			   ,[BudgetUsed]
			   ,[BudgetCommitted]
			   --,[BudgetAvailable]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn])
	SELECT		@BudgetMonthID
			   ,@ServiceID
			   ,[BudgetForecast]
			   ,0
			   ,0
			  -- ,[BudgetForecast]
			   ,@UserID
			   ,[CreatedOn]
			   ,@UserID
			   ,[ModifiedOn]
	  FROM [dbo].[CWI_BudgetMonthService] WHERE ID=@MonthServiceID;

  Set @OutMonthServiceID=SCOPE_IDENTITY();

END

ELSE 
BEGIN
BEGIN TRANSACTION
	INSERT INTO [dbo].[CWI_History_BudgetMonthService]
			   ([BudgetMonthServiceId]
			   ,[BudgetMonthId]
			   ,[ServiceID]
			   ,[BudgetForecast]
			   ,[BudgetUsed]
			   ,[BudgetCommitted]
			   ,[BudgetAvailable]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn])
			   SELECT ID,		  
				[BudgetMonthId]
			   ,[ServiceID]
			   ,[BudgetForecast]
			   ,[BudgetUsed]
			   ,[BudgetCommitted]
			   ,[BudgetAvailable]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn]
			   FROM  [dbo].[CWI_BudgetMonthService] WHERE ID=@UpdateMonthServiceID;

IF( @OutMonthServiceID=0 )
BEGIN

 SET @OutMonthServiceID=@MonthServiceID;

END

 
UPDATE [dbo].[CWI_BudgetMonthService] SET
				[BudgetMonthId]=@BudgetMonthID
			   ,[ServiceID]=@ServiceID
			   ,[BudgetForecast]=(select  sum(BudgetForecast) from CWI_BudgetMonthService where ID=@OutMonthServiceID)			 
			   --,[BudgetAvailable]=(select  sum(BudgetForecast) from CWI_BudgetMonthService where ID=@OutMonthServiceID)- BudgetCommitted+BudgetUsed		  
			   ,[ModifiedBy]=@UserId
			   ,[ModifiedOn]=getDate() 
			WHERE
				 id=@UpdateMonthServiceID;

			   SET @OutMonthServiceID=@UpdateMonthServiceID;

		IF( @@ROWCOUNT>0 )
			BEGIN
				COMMIT;
			END

		ELSE 
			BEGIN
			ROLLBACK;
			SET @OutMonthServiceID=0;
			END



	--		    IF(@OutMonthServiceID>0)
	--BEGIN
	--			 /*below sp will be common for both class and service*/
	--			EXEC prc_CWI_SetClassificationMonthBudgetHistory 0,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
	--END
 
END
END
' 
END
GO
