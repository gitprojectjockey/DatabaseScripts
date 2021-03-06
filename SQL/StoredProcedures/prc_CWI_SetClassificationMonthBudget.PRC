/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClassificationMonthBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClassificationMonthBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClassificationMonthBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClassificationMonthBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClassificationMonthBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClassificationMonthBudget  
* Purpose : This PROC would be called to Create, Update the Classification Month budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 
EXEC prc_CWI_SetClassificationMonthBudget

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetClassificationMonthBudget] 
	@ID int OUT
	,@BudgetMonthID int
	,@ClassificationLookupID int
    --,@DivisionBudgetID int   
    ,@BudgetForecast decimal(18,2)
    ,@BudgetUsed decimal(18,2)
    ,@BudgetCommitted decimal(18,2)
    ,@BudgetAvailable decimal(18,2)
    ,@UserId int,
	@ErrorMsg varchar(1000) out
    
AS
BEGIN
	
	
	Declare @count int;
	Declare @MonthAvailableBudget decimal(18,2), @ClientBudgetID int=0, @MonthBudget decimal(18,2)=0,@ClassificationBudget decimal(18,2)=0, @ClassificationExistinBudget decimal(18,2)=0,@ServiceBudget decimal(18,2)=0;
	declare @DivisionBudgetID int;
	Set @count = (SELECT COUNT(*) FROM CWI_BudgetMonthClassification WHERE BudgetMonthID=@BudgetMonthID AND [ClassificationLookupID]=@ClassificationLookupID);
	SET @MonthBudget=(select  ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonth where ID=@BudgetMonthID);
	SET @ClassificationExistinBudget=(select ISNULL(BudgetForecast,0)  from CWI_BudgetMonthClassification where ID=@ID);
	SET @ClassificationBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthClassification where BudgetMonthID=@BudgetMonthID);
	SET @ClassificationBudget=(ISNULL(@ClassificationBudget,0)-ISNULL(@ClassificationExistinBudget,0));
	Set @ServiceBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthService where BudgetMonthID=@BudgetMonthID)
	SET @MonthAvailableBudget=(@MonthBudget-(@ClassificationBudget + @ServiceBudget));
	 SET  @DivisionBudgetID= (Select DivisionBudgetID from CWI_BudgetMonth where ID=@BudgetMonthID);
	 SET @ClientBudgetID=(Select ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetID);

IF( @ID=0 and @count=0)
BEGIN

IF( @MonthAvailableBudget>=@BudgetForecast )
BEGIN

  INSERT INTO [dbo].[CWI_BudgetMonthClassification]
				   ([BudgetMonthID]
				   ,[ClassificationLookupID]
				   ,[BudgetForecast]
				   ,[BudgetUsed]
				   ,[BudgetCommitted]
				  -- ,[BudgetAvailable]
				   ,[CreatedBy]
				   ,[CreatedOn]
				   ,[ModifiedBy]
				   ,[ModifiedOn])
			 VALUES
				   (@BudgetMonthID
				   ,@ClassificationLookupID
				   ,@BudgetForecast
				   ,@BudgetUsed
				   ,@BudgetCommitted
				  -- ,@BudgetForecast-(@BudgetUsed+@BudgetCommitted)
				   ,@UserId
				   ,GETDATE()
				   ,@UserId
				   ,GETDATE());
				   SET @ID=SCOPE_IDENTITY();

END
ELSE 
	BEGIN
	SET @ID=0;
					SET @ErrorMsg = ''Budget is more than avialable month budget.''
					RETURN
	END

	
		

				   /*Updating BudgetMonth Table */
	--IF(@ID>0)
	--BEGIN
	--EXEC prc_CWI_SetClassificationMonthBudgetHistory @BudgetForecast,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
	--END


END
	
	ELSE 
	--SET @BudgetForecast =(select sum(BudgetForecast)  from CWI_BudgetMonthClassification where ID=@ID) 
	--SET @MonthAvailableBudget=(select sum(BudgetForecast-(BudgetUsed+BudgetCommitted))  from CWI_BudgetMonthClassification where ID=@ID) 
		BEGIN
IF(@MonthAvailableBudget>= @BudgetForecast)
Begin
		INSERT INTO [dbo].[CWI_History_BudgetMonthClassification]
           ([BudgetMonthClassificationID]
           ,[BudgetMonthID]
           ,[ClassificationLookupID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
     
	 SELECT [ID],
			[BudgetMonthID]
           ,[ClassificationLookupID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
          ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
	 From CWI_BudgetMonthClassification Where ID=@ID;


			UPDATE [CWI_BudgetMonthClassification]
			SET
				[BudgetForecast]=@BudgetForecast,
				--[BudgetAvailable]=(@BudgetForecast-(BudgetUsed+BudgetCommitted)),
				--[BudgetUsed]=@BudgetUsed,
				--[BudgetCommitted]=@BudgetCommitted,
				[ModifiedBy]=@UserId,
				[ModifiedOn]=GETDATE()
			WHERE
				ID=@ID;

				 /*Updating BudgetMonth Table */
	--if(@ID>0)
	--		BEGIN
	--EXEC prc_CWI_SetClassificationMonthBudgetHistory @BudgetForecast,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
	--END
END
ELSE 
	BEGIN
	SET @ID=0;
					SET @ErrorMsg = ''Budget is more than available month budget.''
					RETURN
	END
END
END

' 
END
GO
