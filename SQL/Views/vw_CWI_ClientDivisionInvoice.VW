/****** Object:  View [dbo].[vw_CWI_ClientDivisionInvoice]    Script Date: 3/15/2014 9:46:26 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_ClientDivisionInvoice]'))
DROP VIEW [dbo].[vw_CWI_ClientDivisionInvoice]
GO

/****** Object:  View [dbo].[vw_CWI_ClientDivisionInvoice]    Script Date: 3/15/2014 9:46:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CWI_ClientDivisionInvoice]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vw_CWI_ClientDivisionInvoice]
As
SELECT *

FROM
(

SELECT 
	CASE WHEN ISNULL(CI.IsConsolidated ,0) = 1 THEN CI.IsConsolidated ELSE 0 END IsConsolidated,
	CASE WHEN ISNULL(CI.IsConsolidated ,0) = 1 THEN C.ClientId ELSE C.DivisionId END ClientId,
	CASE WHEN ISNULL(CI.IsConsolidated ,0) = 1 THEN CI.InvoiceTypeLookupId ELSE Di.InvoiceTypeLookupId END InvoiceTypeLookupId,
	C.DivisionId ClientDivId
FROM
(
SELECT 
	D.Id DivisionId, D.ParentID  ClientId
FROM CWI_Client D
WHERE ParentID IS NOT NULL
) C
LEFT OUTER JOIN CWI_ClientInvoice CI
	ON CI.clientId = C.ClientId
LEFT OUTER JOIN CWI_ClientInvoice DI
	ON DI.clientId = C.DivisionId
UNION ALL
SELECT 
	 CI.IsConsolidated IsConsolidated1,
	 CI.ClientId  ClientId1,
		CI.InvoiceTypeLookupId InvoiceTypeLookupId1,
		C.ClientId
FROM
(
SELECT 
	Id  ClientId, NULL ParentId
FROM CWI_Client 
WHERE ParentID IS NULL
) C
LEFT OUTER JOIN CWI_ClientInvoice CI
	ON CI.clientId = C.ClientId
) c
' 
GO


