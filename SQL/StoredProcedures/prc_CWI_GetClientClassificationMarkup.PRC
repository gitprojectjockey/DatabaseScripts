/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientClassificationMarkup]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetClientClassificationMarkup' )
 DROP PROCEDURE [dbo].[prc_CWI_GetClientClassificationMarkup]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientClassificationMarkup]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientClassificationMarkup
* Purpose : This PROC would be called TO get Client Accounting Information (from Client Accounting Tab)
* Invoked from : Client_Accounting.ascx
* CREATED: Ajay Thacker
* CREATED ON : 2Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetClientClassificationMarkup @inClientID=14178
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetClientClassificationMarkup]
    @inClientID int
as
BEGIN
	BEGIN TRY

		declare @numClientMarkup numeric(5,2)
		set @numClientMarkup = (Select isnull(MarkupPct,0) from CWI_Client
																where ID = @inClientID)

			--To Populate Classification Grid
			SELECT isnull(CC.ID,0) as ClientClassificationID,
						L1.Id as ClassificationLookupID,
						L1.LookupName as Classification,
						case when ISNULL(cc.MarkupPct,-1.00) = -1.00  then 'Default' 
									
									when cc.MarkupPct = @numClientMarkup then 'Default'
									else convert(varchar(10),CC.MarkupPct)
						end as MarkupPct,
					coalesce(cc.RoundToLookupID,3005) as RoundToLookupID --default is "Standard"
			FROM dbo.Lookup L1
					left join CWI_ClientClassification CC
							on L1.ID = CC.ClassificationLookupID
									and L1.LookupTypeId = 3 --Classification
									and CC.ClientID = @inClientID 
			WHERE L1.LookupTypeId = 3
			and L1.IsActive  = 1
			ORDER BY L1.LookupName
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END





GO
