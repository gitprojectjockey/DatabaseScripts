

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetService]    Script Date: 4/25/2013 2:39:57 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetService')
DROP PROCEDURE [dbo].[prc_CWI_GetService]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetService]    Script Date: 4/25/2013 2:39:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_GetService 
* Purpose : This PROC would be called to retrieve the service details for a specific service
* Invoked from : Service.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetService 9 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetService]       
@inServiceId int
AS
BEGIN

	BEGIN TRY
		SELECT S.[Id] as ServiceId, [ServiceCode],[ServiceDescription],[ServiceName],
		ISNULL([ClassificationLookupId],'') as [ClassificationLookupId],S.[IsActive],[AvailableOnDate],
		[ServiceFinanceCode],ISNULL([ServiceDefaultFee],0.00) as [ServiceDefaultFee],ISNULL([InvoiceItemDescription],'') AS InvoiceItemDescription,
		[ServiceDetail],[ServiceLastUsed],ISNULL(L.LookupName,'') AS LookupName
		FROM [dbo].[CWI_Service] as S
		LEFT OUTER JOIN [dbo].Lookup as L ON S.ClassificationLookupId=L.Id
		WHERE S.[Id]=@inServiceId		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	

GO

