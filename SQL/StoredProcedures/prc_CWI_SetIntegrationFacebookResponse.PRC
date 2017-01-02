/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationFacebookResponse]    Script Date: 8/26/2014 1:46:11 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetIntegrationFacebookResponse' )
 DROP PROCEDURE [dbo].[prc_CWI_SetIntegrationFacebookResponse]
GO


/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationFacebookResponse]    Script Date: 8/26/2014 1:46:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************************************************************  
* PROCEDURE: prc_CWI_SetIntegrationFacebookResponse
* Purpose : This PROC would be called to insert/update a row into [CWI_Integration_Facebook] table
* Invoked from : <TBD>
* CREATED: Jorge Maldonado
* MODIFICATION HISTORY  
* DATE            AUTHOR          DESCRIPTION              
  08/20/2014
**********************************************************************  
Execution example :
********************************************************************** 

********************************************************************************************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetIntegrationFacebookResponse]
	-- Add the parameters for the stored procedure here
	@ClientName	VARCHAR(500)
	,@ProductName	VARCHAR(500)
	,@Date	DATETIME
	,@Impressions	INT
	,@Clicks	Decimal(17,2)
	,@Spend	Money
	,@PageLike	INT
	,@PageLike28d	INT
	,@PageLike1d	INT
	,@CostPerPageLike	Money
	,@ClickToPageLike	Decimal(17,2)
	,@PostLike	Decimal(17,2)
	,@PostLike28d	INT
	,@PostLike1d	INT
	,@CostPerPostLike	Money
	,@ClickToPostLike	Decimal(17,2)
	,@LeadConversion	Decimal(17,2)
	,@Visits	INT
	,@Leads	INT
	,@Calls	INT
	,@LeadConversion28dPostClick	INT
	,@LeadConversion1dPostImpression	INT
	,@CostPerLeadConversion	Money
	,@ClicktoLeadConversionPercent	Decimal(17,2)
	,@LeadConversionValue	Decimal(17,2)
	,@UserID INT
AS
BEGIN

	BEGIN TRY

		SET NOCOUNT ON;

		DECLARE @Count INT
	
		SELECT @Count=COUNT(1) 
			FROM [dbo].[CWI_Integration_Facebook] 
			WHERE ClientName=@ClientName 
				AND [Date]=@DATE 
				AND ProductName=@ProductName

		IF @Count=0
		BEGIN
			INSERT INTO [dbo].[CWI_Integration_Facebook]
					   ([ClientName]
					   ,[ProductName]
					   ,[Date]
					   ,[Impressions]
					   ,[Clicks]
					   ,[Spend]
					   ,[PageLike]
					   ,[PageLike28d]
					   ,[PageLike1d]
					   ,[CostPerPageLike]
					   ,[ClickToPageLike]
					   ,[PostLike]
					   ,[PostLike28d]
					   ,[PostLike1d]
					   ,[CostPerPostLike]
					   ,[ClickToPostLike]
					   ,[LeadConversion]
					   ,[Visits]
					   ,[Leads]
					   ,[Calls]
					   ,[LeadConversion28dPostClick]
					   ,[LeadConversion1dPostImpression]
					   ,[CostPerLeadConversion]
					   ,[ClicktoLeadConversionPercent]
					   ,[LeadConversionValue]
					   ,[CreatedBy]
					   ,[CreatedOn]
					   )
				 VALUES
					   (@ClientName
				,@ProductName
				,@Date
				,@Impressions
				,@Clicks
				,@Spend
				,@PageLike
				,@PageLike28d
				,@PageLike1d
				,@CostPerPageLike
				,@ClickToPageLike
				,@PostLike
				,@PostLike28d
				,@PostLike1d
				,@CostPerPostLike
				,@ClickToPostLike
				,@LeadConversion
				,@Visits
				,@Leads
				,@Calls
				,@LeadConversion28dPostClick
				,@LeadConversion1dPostImpression
				,@CostPerLeadConversion
				,@ClicktoLeadConversionPercent
				,@LeadConversionValue
				,@UserID
					  ,getdate()
				 )



		END
		ELSE
		BEGIN
			UPDATE [dbo].[CWI_Integration_Facebook]
				SET
				Impressions=@Impressions
				,Clicks=@Clicks
				,Spend=@Spend
				,PageLike=@PageLike
				,PageLike28d=@PageLike28d
				,PageLike1d=@PageLike1d
				,CostPerPageLike=@CostPerPageLike
				,ClickToPageLike=@ClickToPageLike
				,PostLike=@PostLike
				,PostLike28d=@PostLike28d
				,PostLike1d=@PostLike1d
				,CostPerPostLike=@CostPerPostLike
				,ClickToPostLike=@ClickToPostLike
				,LeadConversion=@LeadConversion
				,Visits=@Visits
				,Leads=@Leads
				,Calls=@Calls
				,LeadConversion28dPostClick=@LeadConversion28dPostClick
				,LeadConversion1dPostImpression=@LeadConversion1dPostImpression
				,CostPerLeadConversion=@CostPerLeadConversion
				,ClicktoLeadConversionPercent=@ClicktoLeadConversionPercent
				,LeadConversionValue=@LeadConversionValue
				,ModifiedOn=GETDATE()
				,ModifiedBy=@UserID
				WHERE 
					ClientName=@ClientName 
					AND	[Date]=@DATE 
					AND	ProductName=@ProductName
		END

	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END

GO


