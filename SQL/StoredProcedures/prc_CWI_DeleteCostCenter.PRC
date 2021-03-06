/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteCostCenter]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_DeleteCostCenter' )
 DROP PROCEDURE [dbo].[prc_CWI_DeleteCostCenter]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteCostCenter]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteCostCenter
* Purpose : This PROC would be called TO Remove Cost Center Information for either Client or Division (from Cost Center Tab)
* Invoked from : Client_CostCenter.ascx
* CREATED: Ajay Thacker
* CREATED ON : 29Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetCostCentersByClientID @inClientID=42
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_DeleteCostCenter]    
	@inCostCenterID int,
    @inClientID int,
	@inUserID int
	
AS
BEGIN
	BEGIN TRY
		Update CWI_CostCenter
		Set IsDeleted = 1,
				ModifiedBy = @inUserID,
				ModifiedOn = getdate()
		where
		ID = @inCostCenterID
			
		Insert into CWI_History_CostCenter
		(
		CostCenterID,
		ClientID,
		CostCenterName,
		CostCenterNumber,
		BusinessUnit,
		IsDeleted,
		CreatedBy,
		CreatedOn
		)
		Select 
			ID,
			ClientID,
			CostCenterName,
			CostCenterNumber,
			BusinessUnit,
			IsDeleted,
			CreatedBy,
			getdate()
		From CWI_CostCenter
		where ID = @inCostCenterID
		



	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO
