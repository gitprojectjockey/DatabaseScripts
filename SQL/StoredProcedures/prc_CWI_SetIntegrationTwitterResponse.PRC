/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationTwitterResponse]    Script Date: 8/26/2014 1:49:44 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetIntegrationTwitterResponse' )
 DROP PROCEDURE [dbo].[prc_CWI_SetIntegrationTwitterResponse]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetIntegrationTwitterResponse]    Script Date: 8/26/2014 1:49:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************************************************************  
* PROCEDURE: prc_CWI_SetIntegrationTwitterResponse
* Purpose : This PROC would be called to insert/update a row into [CWI_Integration_Twitter] table
* Invoked from : <TBD>
* CREATED: Leonel Mejia
* MODIFICATION HISTORY  
* DATE            AUTHOR          DESCRIPTION              
  08/20/2014
**********************************************************************  
Execution example :
********************************************************************** 

********************************************************************************************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetIntegrationTwitterResponse]
	-- Add the parameters for the stored procedure here
	@ClientName varchar(100),
	@Date date ,
	@Impressions bigint ,
	@Clicks bigint ,
	@Spend money,
	@Engagements bigint ,
	@AccountFollows bigint ,
	@SpendMarkup money ,
	@Visits bigint,
	@Leads bigint,
	@Calls bigint ,
	@GrossMedia money
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Count Int
    -- Insert statements for procedure here
	SELECT @Count=COUNT(1) From CWI_Integration_Twitter Where ClientName=@ClientName And Date=@Date And Impressions=@Impressions
	If @Count=0
	Begin
		Insert into CWI_Integration_Twitter Values(
			@ClientName,
			@Date,
			@Impressions,
			@Clicks,
			@Spend,
			@Engagements,
			@AccountFollows,
			@SpendMarkup,
			@Visits,
			@Leads,
			@Calls,
			@GrossMedia,
			1,
			GETDATE(),
			null,
			null
		)
	End
	Else
	Begin
		Update CWI_Integration_Twitter set
			Clicks=@Clicks,
			Spend=@Spend,
			Engagements=@Engagements,
			AccountFollows=@AccountFollows,
			Visits=@Visits,
			SpendMarkup=@SpendMarkup,
			Leads=@Leads,
			Calls=@Calls,
			GrossMedia=@GrossMedia,
			ModifiedBy=1,
			ModifiedOn=GETDATE()
		Where ClientName=@ClientName And
			Date=@Date And
			Impressions=@Impressions
	End
END

GO


