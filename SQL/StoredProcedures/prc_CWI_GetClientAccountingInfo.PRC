/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientAccountingInfo]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientAccountingInfo' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientAccountingInfo]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientAccountingInfo]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientAccountingInfo
* Purpose : This PROC would be called TO get Client Accounting Information (from Client Accounting Tab)
* Invoked from : Client_Accounting.ascx
* CREATED: Ajay Thacker
* CREATED ON : 5Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetClientAccountingInfo @inClientID=13030
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetClientAccountingInfo]
    @inClientID int
as
BEGIN
	BEGIN TRY
			
			declare @bitIsClientMarkupSetupAtClientLevel bit

			if exists (select id from CWI_ClientClassification where ClientID = (select isnull(ParentID,0) from CWI_Client 
																																					where ID = @inClientID)
							 )
						set @bitIsClientMarkupSetupAtClientLevel = 1
			else
				set @bitIsClientMarkupSetupAtClientLevel = 0
			
			SELECT 
						case when IsPOReqd is null then 'Select'
								 when IsPOReqd = 0 then 'No'
								 else 'Yes'
								 end as IsPoReqd	,
							 isnull(ActgXref,'') as ActgXref,
							case when MarkupPct is null then ''
								else convert(varchar(20),MarkupPct)
										end as MarkupPct,

							case when [ClientStatusLookupID] = 501 --prospect
										then 'YES'
							else 'NO'
							end as ShowActivateClientButton,
							HierarchyTypeLookupID,
							case when [IsUsingClientMarkupAndFee] is null then 'NO'
									 when [IsUsingClientMarkupAndFee] = 0 then 'NO'
									 else 'YES'
							end as UseClientMarkupAndFee,
							case when @bitIsClientMarkupSetupAtClientLevel = 1 then 'YES'
								else 'NO'
							end as ClientMarkupSetAtClientLevel,
							case when @bitIsClientMarkupSetupAtClientLevel = 1 then ''
									else 'Cannot use this feature as Client Accounting has not been setup'
							end as ClientMarkupCheckboxTooltip
								
			From CWI_Client
			WHERE ID = @inClientID 
			
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END

GO
