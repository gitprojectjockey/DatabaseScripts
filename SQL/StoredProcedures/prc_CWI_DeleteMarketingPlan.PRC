IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteMarketingPlan]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteMarketingPlan]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteMarketingPlan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_DeleteMarketingPlan
* Purpose : This PROC would be called TO Remove Marketing Plan
* Invoked from : MarketingPlan.aspx
* CREATED: Ajay Thacker
* CREATED ON : 13May2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_DeleteMarketingPlan @inMarketingPlanID = 1,@inUserID = 21
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_DeleteMarketingPlan]    
	@inMarketingPlanID int,
    @inUserID int
	
AS
BEGIN
	BEGIN TRY
		Update CWI_MarketingPlan
		Set IsDeleted = 1,
				ModifiedBy = @inUserID,
				ModifiedOn = getdate()
		where
		ID = @inMarketingPlanID
			
	

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	' 
END
GO


