/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientService]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientService' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientService]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientService]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientService
* Purpose : This PROC would be called TO get Client Accounting Information (from Client Accounting Tab)
* Invoked from : Client_Accounting.ascx
* CREATED: Ajay Thacker
* CREATED ON : 2Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetClientService @inClientID=42
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetClientService]
    @inClientID int
as
BEGIN
	BEGIN TRY
				
			--To populate Service Grid
			SELECT isnull(cs.id,0) as ClientServiceID,
						S.ID as ServiceID,
						S.ServiceName,
						S.ServiceDefaultFee as ServiceDefaultFee,
						case when ISNULL(CS.ServiceFee,-1.00)=-1.00 then 'Default'
									when CS.ServiceFee = S.ServiceDefaultFee then 'Default'
									else convert(varchar(50),CS.ServiceFee)
						end as ClientServiceFee
			FROM CWI_Service S
			left join CWI_ClientService CS
					on S.ID = CS.ServiceID
				and cs.ClientID = @inClientID
			WHERE S.IsDeleted = 0	AND S.IsActive = 1	
END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END


GO
