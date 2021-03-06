/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobInsertionOrder]    Script Date: 8/25/2014 9:06:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobInsertionOrder]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobInsertionOrder]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobInsertionOrder]    Script Date: 8/25/2014 9:06:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobInsertionOrder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobInsertionOrder]  
* Purpose : This PROC would be called to get the client budget details with organization budget
* Invoked from : Jobs.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              
2/4/2014	Mohan			rundates taken from template fields nased on mapping fields
14/08/2014  Vijesh			Included Tear sheet and billing info
21/08/2014  Vijesh			Modified for rundates function to get in order
**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetJobInsertionOrder] @JobId=1906,@MMRPO=1468,@MediaBuyId=6380, @FilePath=''\\dcvwin2k12d02\FileServerDev\AdCopies\''
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetJobInsertionOrder] 
	@JobId BIGINT,
	@MMRPO BIGINT,
	@MediaBuyId BIGINT,---this is vendor id
	@FilePath Varchar(Max)
AS
BEGIN
	SET NOCOUNT ON


	/*Getting Media Buy RunDate */
	DECLARE @tblJobTemplate TABLE
	(
		MappingFieldId int,
		FieldValue varchar(1000),
		LookupId int,
		LookupValue varchar(100)
	)
	insert into @tblJobTemplate
	select * from dbo.fnc_GetJobSummaryTemplateDataWithLookup(@jobId)	
	
	DECLARE @rundates varchar(max)='''';
	DECLARE @classified varchar(max)='''';
	
	
	SELECT top 1  @classified = ISNULL(t.LookupValue,t.FieldValue) FROM @tblJobTemplate t
		where t.MappingFieldId = 20209;

		/*****************To get the virtual card details******************/
		DECLARE @CCNumber varchar(25) = NULL,
		@Expiry varchar(10),
		@cvc varchar(10),
		@paymethodlookupId int,
		@inMediaBuyId bigint

		select @inMediaBuyId=ID from CWI_JobMediaBuy where MMRPO=@MMRPO

		select @CCNumber= CCNumber, @Expiry = ExpirationDate, @cvc = cast(CVC2Number as varchar(10)) from SettlementcomDataccnumber
		WHERE SettlementID = @inMediaBuyId

		select @paymethodlookupId=PayMethodLookupId from CWI_JobMediaBuy where ID=@inMediaBuyId

		SET @rundates=(select dbo.fnc_CWI_GetJobMediabuyRundatesScalar(@JobId,@inMediaBuyId))
	
		/**********************************/		

	Select MMRPO,JobId,IsChangeOrder,
		VendorName,
		AddressLine1,
		AddressLine2,
		City,
		WorkFax,
		ImagePath,
		 @rundates as RunDate,
		case when @classified=''0'' then '''' else @classified end Classification,		
		case when TearSheet='''' then ''Unavailable'' else TearSheet end as TearSheet,
		case when @paymethodlookupId=852 --Virtual Card lookup id - 852
			then replace(replace(replace(BillingInfo,''{CCNO}'',@CCNumber+''CHR(13)''),''{EXP}'',@Expiry+''CHR(13)''),''{CVC}'',@cvc+''CHR(13)'') 
			else BillingInfo end as BillingInfo,
		GrossCost,
		NetCost,
		AgencyDisc
		from 
	
	(SELECT 
		distinct(JM.MMRPO),
		J.ID as JobId,
		J.IsChangeOrder,
		V.VendorName,
		A.AddressLine1,
		isnull(A.AddressLine2,'''') AddressLine2,
		A.City,
		A.WorkFax,
		@FilePath + Cast(J.id as varchar(50)) + ''\'' + JN.AdCopyFileName AS ImagePath,
		isnull(TS.TearName,'''') +''CHR(13)''+isnull(TS.TearContact,'''')+''CHR(13)''+isnull(AD.AddressLine1,'''')+''CHR(13)''+isnull(AD.City,'''')+''CHR(13)''+isnull(ST.StateCode,'''')+'' ''+isnull(AD.Zip,'''') as TearSheet,		
		isnull(PM.PayMsg1,'''')+''CHR(13)''+isnull(PM.PayMsg2,'''')+''CHR(13)''+isnull(PM.PayMsg3,'''')+''CHR(13)''+isnull(PM.PayMsg4,'''') as BillingInfo
		,ISNULL(JM.QuotedCost,0) AS GrossCost
		,ISNULL(JM.ActualCost,0) AS NetCost
		,V.AgencyDisc as AgencyDisc
	FROM 
		CWI_Vendor V
	INNER JOIN
		CWI_JobMediaBuy JM ON V.Id=JM.VendorId
	INNER JOIN 
		CWI_Address A ON A.ID=V.AddressId_Billing
	INNER JOIN
		CWI_Job J ON j.ID=JM.JobId
	INNER JOIN
		CWI_JobNewspaper JN ON J.ID = JN.JobId

	LEFT OUTER JOIN
		CWI_ClientTearSheet TS ON TS.ClientId=J.DivisionId
	left outer JOIN 
		CWI_Address AD ON TS.AddressId=AD.ID
	left outer JOIN 
		State ST ON AD.StateID=ST.ID
	LEFT OUTER JOIN CWI_PayMethodMessage PM
		ON JM.PayMethodLookupId = PM.PayMethodLookupId



	where ISNULL(JM.MMRPO,0) >0 AND JM.MMRPO=@MMRPO ) as JobSummary  




SET NOCOUNT OFF
	
END





' 
END
GO
