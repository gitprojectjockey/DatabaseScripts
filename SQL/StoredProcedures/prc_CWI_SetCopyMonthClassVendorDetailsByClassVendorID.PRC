/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyMonthClassVendorDetailsByClassVendorID]    Script Date: 1/31/2014 7:24:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyMonthClassVendorDetailsByClassVendorID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCopyMonthClassVendorDetailsByClassVendorID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCopyMonthClassVendorDetailsByClassVendorID]    Script Date: 1/31/2014 7:24:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCopyMonthClassVendorDetailsByClassVendorID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_SetCopyClassificationDetailsByClassificationID]  
* Purpose : This PROC would be called to insert(copy) the Budget details from one Vendor to another Vendor
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************
Declare  @OutClassVendorID int
prc_CWI_SetCopyMonthClassVendorDetailsByClassVendorID @ClassVendorID=,
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetCopyMonthClassVendorDetailsByClassVendorID] 
	@ClassVendorID  INT,
	@VendorID Int,
	@UserId INT,
	@BudgetMonthClassificationID INT,
	@OutClassVendorID  int Out
AS
BEGIN
DECLARE @UpdateClassVendorID int,@count Int =0,@BudgetMonthID int=0, @DivisionBudgetID int=0, @ClientBudgetID int=0;
SET @UpdateClassVendorID=(Select ID FROM CWI_BudgetMonthClassVendor WHERE BudgetMonthClassificationID=@BudgetMonthClassificationID AND VendorID=@VendorID);
SET @BudgetMonthID=(Select BudgetMonthID from CWI_BudgetMonthClassification where ID=@BudgetMonthClassificationID);
SET  @DivisionBudgetID= (Select DivisionBudgetID from CWI_BudgetMonth where ID=@BudgetMonthID);
SET @ClientBudgetID=(Select ClientBudgetID from CWI_DivisionBudget where ID=@ClientBudgetID);
SET @count=(select COUNT(*) from CWI_BudgetMonthClassVendor WHERE BudgetMonthClassificationID=@BudgetMonthClassificationID AND VendorID=@VendorID)
IF (@count=0)
BEGIN
INSERT INTO [dbo].[CWI_BudgetMonthClassVendor]
           ([BudgetMonthClassificationID]
           ,[VendorID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           --,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
           ,[IsCommitted])
SELECT		@BudgetMonthClassificationID
           ,[VendorID]
           ,[BudgetForecast]
           ,0
           ,0
           --,[BudgetForecast]
           ,@UserId
           ,GETDATE()
           ,@UserId
           ,GETDATE()
           ,[IsCommitted]
  FROM [dbo].[CWI_BudgetMonthClassVendor] WHERE ID=@ClassVendorID;

  Set @OutClassVendorID=SCOPE_IDENTITY();


--IF( @OutClassVendorID>0 )
--BEGIN
--	EXEC prc_CWI_SetVendorBudgetHistory 0,@BudgetMonthClassificationID,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
--	END

END

ELSE
BEGIN
BEGIN TRAN
INSERT INTO [dbo].[CWI_History_BudgetMonthClassVendor]
           ([BudgetMonthClassVendorId]
           ,[BudgetMonthClassificationID]
           ,[VendorID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
          ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
           ,[IsCommitted])
		   SELECT ID,
		   [BudgetMonthClassificationID]
           ,[VendorID]
           ,[BudgetForecast]
           ,[BudgetUsed]
           ,[BudgetCommitted]
           ,[BudgetAvailable]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
           ,[IsCommitted]
		   FROM [CWI_BudgetMonthClassVendor] WHERE ID=@UpdateClassVendorID;

		    DECLARE @tblSourceBudgetMonthClassVendor TABLE
		   ( 
			id1 int,			
			BudgetForecast1	money

		   )

	  INSERT INTO @tblSourceBudgetMonthClassVendor
		   select @UpdateClassVendorID, sum(BudgetForecast) from [CWI_BudgetMonthClassVendor]
		    where ID=@ClassVendorID;
 
	UPDATE [dbo].[CWI_BudgetMonthClassVendor] SET
			[BudgetMonthClassificationID]=@BudgetMonthClassificationID
			,[VendorID]=@VendorID
			,[BudgetForecast]=MCV.BudgetForecast1			
			--,[BudgetAvailable]=MCV.BudgetForecast1- BudgetCommitted+BudgetUsed			  
			,[ModifiedBy]=@UserId
			,[ModifiedOn]=getDate() 
			From
				@tblSourceBudgetMonthClassVendor MCV
			WHERE
				ID=MCV.id1 and id=@UpdateClassVendorID;
	

IF( @@ROWCOUNT>0 )
		BEGIN

			COMMIT; 

		END
ELSE
		BEGIN
		
			ROLLBACK Transaction;
			RETURN;
		END

--IF( @UpdateClassVendorID>0)
--BEGIN
--EXEC prc_CWI_SetVendorBudgetHistory 0,@BudgetMonthClassificationID,@BudgetMonthID,@DivisionBudgetID,@ClientBudgetID,@UserId
 

--END

END

END

' 
END
GO
