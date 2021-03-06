/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMonthBudgetInvoiceUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMonthBudgetInvoiceUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetMonthBudgetInvoiceUpdate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMonthBudgetInvoiceUpdate]    Script Date: 1/27/2014 5:45:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMonthBudgetInvoiceUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetMonthBudgetInvoiceUpdate  
* Purpose : This PROC would be called to Create, Update the Month budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            
		
**********************************************************************  
Execution example :
********************************************************************** 
EXEC prc_CWI_SetMonthBudgetInvoiceUpdate 236,9,2013,364,7007,0,0,0,8

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetMonthBudgetInvoiceUpdate] 
	@ID int OUT
	,@Month int
	,@Year int
    ,@DivisionBudgetID int   
    ,@BudgetForecast decimal(18,2)
    ,@BudgetUsed decimal(18,2)
    ,@BudgetCommitted decimal(18,2)
    ,@BudgetAvailable decimal(18,2)
    ,@UserId int
	
    
AS
BEGIN




	IF @ID=0
	


BEGIN


 INSERT INTO [dbo].[CWI_BudgetMonth]
           (
           [DivisionBudgetID]
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
     VALUES
          (
           @DivisionBudgetID
           ,@Month
           ,@Year
           ,@BudgetForecast
           ,@BudgetUsed
           ,@BudgetCommitted
           ,@BudgetForecast-(@BudgetUsed+@BudgetCommitted)
           ,@UserId
           ,GETDATE()
           ,@UserId
           ,GETDATE())
		   --set identity_insert [CWI_BudgetMonth] OFF
		   SET @ID=SCOPE_IDENTITY();

 

END

	
	
	ELSE
		BEGIN
		Declare @ExistForecast decimal;
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
				[BudgetAvailable]=@BudgetForecast,--@BudgetForecast-(BudgetUsed+BudgetCommitted),
							
				[ModifiedBy]=@UserId,
				[ModifiedOn]=GETDATE()
			WHERE
				ID=@ID;



		

END

		
		END

END
' 
END
GO
