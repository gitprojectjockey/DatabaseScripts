/****** Object:  StoredProcedure [dbo].[prc_CWI_SetServiceBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetServiceBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetServiceBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetServiceBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetServiceBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**************************************************************
*****  
* PROCEDURE: prc_CWI_SetServiceBudget  
* Purpose : This PROC would be called to Create, Update the Service budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_SetServiceBudget]
@ServiceID= 
,@BudgetMonthId = 
,@BudgetForecast= 
,@BudgetUsed = 
,@BudgetCommitted = 
,@BudgetAvailable= 
,@CreatedBy = 
,@ModifiedBy= 
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetServiceBudget] 
@ID int OUT
,@ServiceID int
,@BudgetMonthId int
,@BudgetForecast MONEY=0.00
,@BudgetUsed	MONEY = 0.00
,@BudgetCommitted MONEY = 0.00
,@BudgetAvailable MONEY = 0.00
,@UserId int	
,@ErrorMsg varchar(max) Out
AS
BEGIN
	--BEGIN TRY
	

declare @cnt int=0,@DivisionBudgetID int=0,@ClientBudgetID int=0,@ServiceBudget decimal(18,2)=0,@MonthBudget decimal(18,2)=0,@ClassificationBudget decimal(18,2)=0;
DECLARE @MonthAvailableBudget decimal(18,2)=0,@ServiceExistingBudget decimal(18,2)=0;

SET @ClassificationBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthClassification where BudgetMonthID=@BudgetMonthID);

SET @ServiceExistingBudget=(select ISNULL(BudgetForecast,0)  from CWI_BudgetMonthService where ID=@ID);
set @ServiceBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthService where BudgetMonthId=@BudgetMonthID);

SET @ServiceBudget=((ISNULL(@ServiceBudget,0))-(ISNULL(@ServiceExistingBudget,0)))

SET @MonthBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonth where ID=@BudgetMonthID);
--SET @MonthAvailableBudget=(select sum(BudgetForecast-(BudgetUsed+BudgetCommitted))  from CWI_BudgetMonth where ID=@BudgetMonthID);
SET @MonthAvailableBudget=(@MonthBudget-(@ServiceBudget + @ClassificationBudget));
SET  @DivisionBudgetID= (Select DivisionBudgetID from CWI_BudgetMonth where ID=@BudgetMonthID);
SET @ClientBudgetID=(Select ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetID); 

IF(@MonthAvailableBudget>=@BudgetForecast )
BEGIN

  IF @ID=0
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
     VALUES		 
			(@BudgetMonthId
			,@ServiceID
			,@BudgetForecast
			,@BudgetUsed
			,@BudgetCommitted
			--,(@BudgetForecast -(@BudgetUsed+@BudgetCommitted))
			,@UserId
			,GETDATE()
			,@UserId
			,GETDATE())
			SET @ID=SCOPE_IDENTITY();	
			
			 /*Updating BudgetMonth Table */
	--		 IF(@ID>0)
	--BEGIN
	--/*below sp will be common for both class and service*/
	--			EXEC prc_CWI_SetClassificationMonthBudgetHistory @BudgetForecast,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
	--END

				   
			RETURN;
			   END
			 	

ELSE
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
		   FROM  [dbo].[CWI_BudgetMonthService] WHERE ID=@ID;
 
UPDATE [dbo].[CWI_BudgetMonthService] SET
			 
			   [BudgetForecast]=@BudgetForecast
			  -- ,[BudgetUsed]=@BudgetUsed// need to check
			  -- ,[BudgetCommitted]=@BudgetCommitted
			  -- ,[BudgetAvailable]=(@BudgetForecast -(@BudgetUsed+@BudgetCommitted))			  
			   ,[ModifiedBy]=@UserId
			   ,[ModifiedOn]=getDate() WHERE ID=@ID ;

			    /*Updating BudgetMonth Table */

--IF( @ID>0 )
--	BEGIN
--			/*below sp will be common for both class and service*/
--				EXEC prc_CWI_SetClassificationMonthBudgetHistory @BudgetForecast,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId

--	END
END

	ELSE 
	begin
	SET @ID=0;
					set @ErrorMsg = ''Budget is more than available month budget.''
					return
				end
	END
		   
	

' 
END
GO
