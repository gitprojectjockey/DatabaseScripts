/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCostCenter]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetCostCenter' )
 DROP PROCEDURE [dbo].[prc_CWI_SetCostCenter]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCostCenter]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_SetCostCenter
* Purpose : This PROC would be called TO Insert/Update Cost Center Information
						 for either Client or Division (from Cost Center Tab)
* Invoked from : Client_CostCenter.ascx
* CREATED: Ajay Thacker
* CREATED ON : 29Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

**********************************************************************/ 
  

/*******************************************************************  
* PROCEDURE: prc_CWI_SetCostCenter
* Purpose : This PROC would be called TO Insert/Update Cost Center Information
						 for either Client or Division (from Cost Center Tab)
* Invoked from : Client_CostCenter.ascx
* CREATED: Ajay Thacker
* CREATED ON : 29Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetCostCenter]    
    @inCostCenterID int = null,
	@inClientID int,
	@vcCostCenterName varchar(255),
	@vcCostCenterNumber varchar(50),
	@vcBusinessUnit varchar(50),
	@inUserID int,
	@vcErrorMsg varchar(1000) out

AS
BEGIN
	BEGIN TRY

		set @vcErrorMsg = ''

		

		if @inCostCenterID is null --new Cost Center record to be inserted
		BEGIN
				--Validate if Cost Center already exists for the division or for the client
				if exists(select ID From CWI_CostCenter
								 where CostCenterNumber = @vcCostCenterNumber
								 and (ClientID = @inClientID or ClientID = (Select isnull(ParentID,0) from cwi_Client
																															where ID = @inClientID)
											)
								 and IsDeleted = 0)
				begin
					set @vcErrorMsg = 'Cost Center ' + @vcCostCenterNumber + ' already exists. Save Failed.'
					return
				end

				Insert into CWI_CostCenter
				(
					ClientID,
					CostCenterName,
					CostCenterNumber,
					BusinessUnit,
					IsDeleted,
					CreatedBy,
					CreatedOn,
					ModifiedBy,
					ModifiedOn
				)
				values
				(
					@inClientID,
					@vcCostCenterName,
					@vcCostCenterNumber,
					@vcBusinessUnit,
					0,
					@inUserID,
					getdate(),
					@inUserID,
					getdate()
				)

				set @inCostCenterID = @@IDENTITY


		END
		
		ELSE
		BEGIN
				if exists(select ID From CWI_CostCenter
								 where CostCenterNumber = @vcCostCenterNumber
								 and (ClientID = @inClientID or ClientID = (Select isnull(ParentID,0) from cwi_Client
																															where ID = @inClientID)
											)
								and ID <> @inCostCenterID
								 and IsDeleted = 0)
				begin
					set @vcErrorMsg = 'Cost Center ' + @vcCostCenterNumber + ' already exists. Save Failed.'
					return
				end

			Update CWI_CostCenter
				Set CostCenterName = @vcCostCenterName,
						CostCenterNumber = @vcCostCenterNumber,
						BusinessUnit = @vcBusinessUnit,
						ModifiedBy = @inUserID,
						ModifiedOn = getdate()
				where ID = @inCostCenterID	
		END

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
				@inCostCenterID,
				ClientID,
				CostCenterName,
				CostCenterNumber,
				BusinessUnit,
				IsDeleted,
				CreatedBy,
				getdate()
			from CWI_CostCenter 
			where ID = @inCostCenterID
			

	
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	

	
GO
