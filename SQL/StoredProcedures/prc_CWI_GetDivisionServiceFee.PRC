/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionServiceFee]    Script Date: 6/4/2014 3:12:51 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionServiceFee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDivisionServiceFee]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionServiceFee]    Script Date: 6/4/2014 3:12:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionServiceFee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetDivisionServiceFee] 
* Purpose : This PROC would be called to retrieve the service details for a specific service
* Invoked from : JobService.aspx
* CREATED: Mohan
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec [prc_CWI_GetDivisionServiceFee] 9 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetDivisionServiceFee]       
@inServiceId int,
@divisionId int
AS
BEGIN

	BEGIN TRY
		SELECT S.[Id] as ServiceId, [ServiceCode],[ServiceDescription],[ServiceName],
		ISNULL([ClassificationLookupId],'''') as [ClassificationLookupId],S.[IsActive],[AvailableOnDate],
		[ServiceFinanceCode], COALESCE(CS.ServiceFee,[ServiceDefaultFee],0.00) as [ServiceDefaultFee],ISNULL([InvoiceItemDescription],'''') AS InvoiceItemDescription,
		[ServiceDetail],[ServiceLastUsed],ISNULL(L.LookupName,'''') AS LookupName
		FROM [dbo].[CWI_Service] as S
		LEFT OUTER JOIN [dbo].Lookup as L ON S.ClassificationLookupId=L.Id
		LEFT OUTER JOIN CWI_ClientService CS
			ON CS.ServiceID = S.Id
				AND CS.ClientID = @divisionId
		WHERE S.[Id]=@inServiceId		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	


' 
END
GO
