/****** Object:  StoredProcedure [dbo].[prc_APAS_GetSubmitCostResults]    Script Date: 8/19/2014 3:17:30 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetSubmitCostResults]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_GetSubmitCostResults]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_GetSubmitCostResults]    Script Date: 8/19/2014 3:17:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetSubmitCostResults]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*********************************************************************************************************************  
* PROCEDURE  : dbo.prc_APAS_GetSubmitCostResults  
* Purpose : This PROC would be called TO get the details od job and media buy after submitting the cost 
* Invoked from : PaperCostWizard.aspx
* CREATED: MohanKumar Sundaram 31JUL14
* CHANGE HISTORY:   
* DATE      AUTHOR   DESCRIPTION   

**********************************************************************************************************************/  
  
CREATE   PROCEDURE [dbo].[prc_APAS_GetSubmitCostResults]  
 @MediaBuyId as bigint
AS  

DECLARE @CCNumber varchar(25) = NULL,
		@Expiry varchar(10),
		@cvc varchar(10)

select @CCNumber= CCNumber, @Expiry = ExpirationDate, @cvc = cast(CVC2Number as varchar(10)) from SettlementcomDataccnumber
WHERE SettlementID = @MediaBuyId

Select 
	JMB.PayMethodLookupId,
	ActualCost,
	PM.PayMsg1,
	PM.PayMsg2,
	PM.PayMsg3,
	PM.PayMsg4,
	@CCNumber CCNo, 
	@Expiry  Expiry, 
	@cvc  CVC,
	dbo.[fnc_GetUsersEmailsForClientScalar](j.DivisionId,''A'') EmailCC,
	UJC.Names AE,
	UJC.Email AEEmail,
	J.IsQuote
FROM
	CWI_job J
	INNER JOIN CWI_JobMediaBuy JMB
		ON J.Id = JMB.JobId
	inner join CWI_User UJC
		ON UJC.Id = J.CreatedBy
	LEFT OUTER JOIN CWI_PayMethodMessage PM
		ON JMB.PayMethodLookupId = PM.PayMethodLookupId
WHERE
	JMB.Id = @MediaBuyId


' 
END
GO


