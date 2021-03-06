/****** Object:  StoredProcedure [dbo].[prc_CWI_AddClientBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_AddClientBudget]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_AddClientBudget]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_AddClientBudget]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_AddClientBudget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_AddClientBudget  
* Purpose : This PROC would be called to Create the client budget details 
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
declare @RowCount int;
exec [prc_CWI_AddClientBudget] @ClientId=13957,@BudgetName=Test,@BudgetForecast=0.00,@BudgetUsed=0.00,@BudgetCommitted=0.00,@BudgetFrom=''2013-06-01 00:00:00.000'',@BudgetTo=''2014-06-01 00:00:00.000'',@RevisionId=1,@ModifiedBy=8
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_AddClientBudget] 
			@ClientId INT  
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
		   ,@ErrorMsg varchar(max) out
AS
BEGIN
BEGIN TRY
DECLARE @BudgetRowCount int;
DECLARE @Count int;
set @Count=(select count(*) from CWI_ClientBudget 
			where 
			((@BudgetFrom  between  CWI_ClientBudget.BudgetFrom  and CWI_ClientBudget.BudgetTo)
			OR (@BudgetTo between  CWI_ClientBudget.BudgetFrom  and CWI_ClientBudget.BudgetTo )
			)
			
			AND [ClientID]=@ClientId
			)
			--((@BudgetFrom  between CWI_ClientBudget.BudgetFrom  and CWI_ClientBudget.BudgetTo) or (@BudgetTo  between CWI_ClientBudget.BudgetFrom  and CWI_ClientBudget.BudgetTo)) and ([ClientID]=@ClientId))

IF (@Count=0)

BEGIN

 DECLARE @BudgetAvailable MONEY;
	SET @BudgetAvailable=@BudgetForecast-(@BudgetUsed+@BudgetCommitted);
	Declare @Id int=0;

	INSERT INTO 
	[dbo].[CWI_ClientBudget]
            ([ClientID]
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
		   ,[ModifiedOn]
           )
     VALUES
           (@ClientId
           ,@BudgetName
           ,@BudgetForecast
           ,@BudgetUsed
           ,@BudgetCommitted
		   --,@BudgetAvailable
		   ,@SalesForecast
           ,@BudgetFrom
           ,@BudgetTo
           ,@RevisionId
		   ,@CreatedBy
		   ,GETDATE()
           ,@ModifiedBy
		   ,GETDATE()		   
           )
		   SET @RowCount = (SELECT @@ROWCOUNT as RowAffected);
		  SET @Id=SCOPE_IDENTITY();

		  IF(@Id>0)
		  INSERT INTO [dbo].[CWI_DivisionBudget]
           ([ClientBudgetID]
           ,[DivisionID]
           ,[BudgetName]
           ,[BudgetForecast]
           ,[BudgetUsed]
		   ,[BudgetCommitted]
           --,[BudgetAvailable]
		   ,[BudgetFrom]
           ,[BudgetTo]
           ,[RevisionId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn] 
           ,[IsActive])
     
        SELECT
			CWI_ClientBudget.[ID]	
			,CWI_Client.ID as DivisionID     
			,[CWI_ClientBudget].[BudgetName]
			,[CWI_ClientBudget].[BudgetForecast]
			,[CWI_ClientBudget].[BudgetUsed]
			,[CWI_ClientBudget].[BudgetCommitted]
			--,[CWI_ClientBudget].[BudgetAvailable]
			,[CWI_ClientBudget].[BudgetFrom]
			,[CWI_ClientBudget].[BudgetTo]
			,0		
			,[CWI_ClientBudget].CreatedBy
			,[CWI_ClientBudget].CreatedOn
			,[CWI_ClientBudget].ModifiedBy
			,[CWI_ClientBudget].ModifiedOn
			,1
  FROM [dbo].[CWI_ClientBudget]

Inner join
	CWI_Client
on
	[CWI_ClientBudget].ClientID=CWI_Client.ParentID AND [CWI_ClientBudget].ID=@Id --AND CWI_Client.ParentID=13957
LEFT OUTER JOIN
	CWI_DivisionBudget
ON
	CWI_ClientBudget.ID=CWI_DivisionBudget.ClientBudgetID



END
ELSE
begin
	SET @RowCount=0;
					set @ErrorMsg = ''Client budget already avilable for the selected term period!!!!!''
					return;
				
				END
END TRY
BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
END
' 
END
GO
