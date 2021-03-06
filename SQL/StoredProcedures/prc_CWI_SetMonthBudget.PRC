/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMonthBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMonthBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetMonthBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMonthBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMonthBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetMonthBudget  
* Purpose : This PROC would be called to Create, Update the Month budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 
EXEC prc_CWI_SetMonthBudget 236,9,2013,364,7007,0,0,0,8

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetMonthBudget] 
	@ID int OUT
	,@Month int
	,@Year int
    ,@DivisionBudgetID int   
    ,@BudgetForecast decimal(18,2)
    ,@BudgetUsed decimal(18,2)
    ,@BudgetCommitted decimal(18,2)
    ,@BudgetAvailable decimal(18,2)
    ,@UserId int
	,@ErrorMsg varchar(max) OUT
    
AS
BEGIN
Declare @count int,@ClientBudgetID int=0,@ClientID int =0,@ClassificationBudget decimal(18,2)=0,@ServiceBudget decimal(18,2)=0,@ExistingBudget decimal(18,2)=0, @MonthBudget decimal(18,2)=0;

SET @ClassificationBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthClassification where BudgetMonthID=@ID);
SET @ServiceBudget=(select ISNULL(sum(BudgetForecast),0)  from CWI_BudgetMonthService where BudgetMonthId=@ID);

SET @MonthBudget=(@ClassificationBudget+@ServiceBudget);

	SET @ClientBudgetID=(Select ClientBudgetID from CWI_DivisionBudget where ID=@DivisionBudgetID);
	SET @ClientID=(Select ClientID from CWI_ClientBudget  where ID=@ClientBudgetID);
	
IF( @MonthBudget<=@BudgetForecast )
BEGIN

 


	IF @ID=0
	BEGIN

	Set @count = (SELECT COUNT(*) FROM CWI_BudgetMonth WHERE Month=@Month AND [Year]=@Year AND DivisionBudgetID=@DivisionBudgetID);
	


IF(@count=0 )
BEGIN


 INSERT INTO [dbo].[CWI_BudgetMonth]
           (
           [DivisionBudgetID]
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
     VALUES
          (
           @DivisionBudgetID
           ,@Month
           ,@Year
           ,@BudgetForecast
           ,@BudgetUsed
           ,@BudgetCommitted
          --- ,@BudgetForecast-(@BudgetUsed+@BudgetCommitted)
           ,@UserId
           ,GETDATE()
           ,@UserId
           ,GETDATE())
		   --set identity_insert [CWI_BudgetMonth] OFF
		   SET @ID=SCOPE_IDENTITY();

IF( @ID>0 )
BEGIN
EXEC prc_CWI_SetMonthBudgetHistory @UserId, @DivisionBudgetID,@ClientBudgetID

END	 

END

	
	END
	ELSE
		BEGIN
		Declare @ExistForecast decimal(18,2);
		SET @ExistForecast = (select sum( [BudgetCommitted]+[BudgetUsed]) from CWI_BudgetMonth where ID=@ID);
		IF( @BudgetForecast>=@ExistForecast)
BEGIN

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
		   FROM CWI_BudgetMonth WHERE ID=@ID;


 UPDATE CWI_BudgetMonth
			SET
				[BudgetForecast]=@BudgetForecast,
				--[BudgetAvailable]=@BudgetForecast,--@BudgetForecast-(BudgetUsed+BudgetCommitted),
							
				[ModifiedBy]=@UserId,
				[ModifiedOn]=GETDATE()
			WHERE
				ID=@ID;


IF( @ID>0 )
	BEGIN
EXEC prc_CWI_SetMonthBudgetHistory @UserId, @DivisionBudgetID,@ClientBudgetID

END	 

		

END

		ELSE
		BEGIN
		 SET @ID=0;
		 RETURN;
		END	
		END
END
else
begin
	SET @ID=0;
					set @ErrorMsg = ''Month Budget should be grater than classification & service budget''
					return
				end
END
' 
END
GO
