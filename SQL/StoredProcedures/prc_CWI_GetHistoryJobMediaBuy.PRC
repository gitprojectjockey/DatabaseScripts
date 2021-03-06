/****** Object:  StoredProcedure [dbo].[prc_CWI_GetHistoryJobMediaBuy]    Script Date: 8/19/2014 3:10:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetHistoryJobMediaBuy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetHistoryJobMediaBuy]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetHistoryJobMediaBuy]    Script Date: 8/19/2014 3:10:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetHistoryJobMediaBuy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetHistoryJobMediaBuy 
* Purpose : This PROC would be called to retrieve the history details of the media buy
* Invoked from : JobMediaBuy.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION              
  16May14   Vijesh			Modified parameter datatype from int to bigint
  13AUG14	Mohankumar		Returned Modified Name (users other than CWI) if modified by is system
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetHistoryJobMediaBuy 3097
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetHistoryJobMediaBuy]
	@inJobMediaBuyId bigint
AS
BEGIN
	BEGIN TRY
		SELECT JMB.ID as HistoryId,JMB.JobMediaBuyId,JMB.JobId,JMB.VendorId,JMB.MMRPO,OldStatusId,NewStatusId,
		ISNULL(OldExpectedCost,0) AS OldExpectedCost,ISNULL(NewExpectedCost,0) AS NewExpectedCost,
		ISNULL(OldExpectedInvoice,0) AS OldExpectedInvoice,ISNULL(NewExpectedInvoice,0) AS NewExpectedInvoice,
		ISNULL(OldActualCost,0) AS OldActualCost,ISNULL(NewActualCost,0) AS NewActualCost,
		ISNULL(OldActualInvoice,0) AS OldActualInvoice,ISNULL(NewActualInvoice,0) AS NewActualInvoice,
		ISNULL(OldIsActualCostFreeze,0) AS OldIsActualCostFreeze,ISNULL(NewIsActualCostFreeze,0) AS NewIsActualCostFreeze,
		ISNULL(OldIsActualInvoiceFreeze,0) AS OldIsActualInvoiceFreeze,
		ISNULL(NewIsActualInvoiceFreeze,0) AS NewIsActualInvoiceFreeze,
		ISNULL(OldIsComplimentary,0) AS OldIsComplimentary,ISNULL(NewIsComplimentary,0) AS NewIsComplimentary,
		ISNULL(OldIsComplimentaryInvoice,0) AS OldIsComplimentaryInvoice,
		ISNULL(NewIsComplimentaryInvoice,0) AS NewIsComplimentaryInvoice,
		ISNULL(OldIsRemoved,0) AS OldIsRemoved,ISNULL(NewIsRemoved,0) AS NewIsRemoved,ISNULL(OldDNR,0) AS OldDNR,
		ISNULL(NewDNR,0) AS NewDNR, 
		CASE WHEN JMB.ModifiedBy=1/*system*/ THEN JMB.ModifiedByEmail ELSE U.Names END as ModifiedBy,
		JMB.ModifiedOn,L.[LookupName] AS OldStatusName,
		LU.[LookupName] AS NewStatusName,V.VendorCode as VendorCode,V.VendorName as VendorName
		FROM CWI_History_JobMediaBuy JMB
		INNER JOIN CWI_User AS U ON JMB.ModifiedBy=U.Id
		INNER JOIN CWI_Vendor AS V ON V.Id=JMB.VendorId
		INNER JOIN [dbo].[Lookup] AS L ON L.Id=JMB.OldStatusId
		INNER JOIN [dbo].[Lookup] AS LU ON LU.Id=JMB.NewStatusId
				
		WHERE JobMediaBuyId = @inJobMediaBuyId

		ORDER BY HistoryId DESC		

	END TRY

	BEGIN CATCH	

		EXEC prc_CWI_AppRaiseError;

		THROW;   		

	END CATCH



END





' 
END
GO


