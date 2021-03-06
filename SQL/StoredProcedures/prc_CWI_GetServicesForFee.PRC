/****** Object:  StoredProcedure [dbo].[prc_CWI_GetServicesForFee]    Script Date: 6/5/2014 5:48:08 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetServicesForFee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetServicesForFee]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetServicesForFee]    Script Date: 6/5/2014 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetServicesForFee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetServicesForFee 
* Purpose : This PROC would be called TO get all the services available to add/edit
* Invoked from : JobService.aspx
* CREATED: Mohankumar 30MAY14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetServicesForFee 
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetServicesForFee]
	@inJobId bigint,
	@inServiceId int = NULL
AS  
BEGIN
	select									
		S.[Id] as ServiceId,[ServiceCode],S.ServiceDescription,[ServiceName],[AvailableOnDate],[ClassificationLookupId],
		S.[IsActive],[ServiceFinanceCode],[ServiceDefaultFee],[InvoiceItemDescription],[ServiceDetail],
		[ServiceLastUsed],ISNULL(L.LookupName,'''') AS LookupName
	from 
	(SELECT * FROM CWI_Service
	WHERE IsActive = 1 AND AvailableOnDate <=  getdate() AND IsDeleted=0
	) S
	LEFT OUTER JOIN
	(
	SELECT * FROM CWI_JobService
	WHERE JobId = @inJobId
	) JS
		ON S.Id  = JS.ServiceId
	LEFT OUTER JOIN [dbo].Lookup AS L 
		ON S.ClassificationLookupId=L.Id
	WHERE JS.Id IS NULL OR JS.ServiceId = ISNULL(@inServiceId,0) OR JS.IsDeleted = 1


END



' 
END
GO
