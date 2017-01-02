

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetServices]    Script Date: 4/25/2013 2:40:15 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetServices')
DROP PROCEDURE [dbo].[prc_CWI_GetServices]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetServices]    Script Date: 4/25/2013 2:40:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_GetServices 
* Purpose : This PROC would be called TO get all the comments associated with a module/category
* Invoked from : Service.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetServices 
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetServices]       
AS
BEGIN
	BEGIN TRY
		SELECT S.[Id] as ServiceId,[ServiceCode],[ServiceDescription],[ServiceName],[AvailableOnDate],[ClassificationLookupId],
		S.[IsActive],[ServiceFinanceCode],[ServiceDefaultFee],[InvoiceItemDescription],[ServiceDetail],
		[ServiceLastUsed],ISNULL(L.LookupName,'') AS LookupName
		FROM [dbo].[CWI_Service] AS S
		LEFT OUTER JOIN [dbo].Lookup AS L ON S.ClassificationLookupId=L.Id
		WHERE [IsDeleted]=0
		ORDER BY ServiceId		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	

GO

