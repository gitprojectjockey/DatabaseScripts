IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientProfileBenefit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientProfileBenefit]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientProfileBenefit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientProfileBenefit 
* Purpose : This PROC would be called to retrieve the profile benefit settings details for a specific client/division
* Invoked from : Profile_BenefitSetting.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetClientProfileBenefit 14174
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetClientProfileBenefit]       
@inClientId int
AS
BEGIN

	BEGIN TRY
		
		SELECT P.[ID] as [ProfileID],[BenefitID],B.Benefit
		FROM [dbo].[CWI_ClientProfileBenefit] AS P
		INNER JOIN [dbo].[CWI_CPL_Benefit] AS B ON B.ID=P.BenefitID
		WHERE [ClientID]=@inClientId	
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
	' 
END
GO


