/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceDetailsForResend]    Script Date: 4/16/2014 2:46:11 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceDetailsForResend]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceDetailsForResend]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceDetailsForResend]    Script Date: 4/16/2014 2:46:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceDetailsForResend]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceDetailsForResend  
* Purpose : This PROC would be called TO get the invoice details to resend
* Invoked from : ManageInvoiceDelivery.aspx
* CREATED: MohanKumar Sundaram		27MAR14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetInvoiceDetailsForResend 4
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetInvoiceDetailsForResend] 
    @InvoiceId bigint  
AS
SET NOCOUNT ON
DECLARE @Method varchar(max) ='''',
	@Email varchar(max) =''''

DECLARE @tblMethod TABLE
(
	dummyId int,
	MethodId int,
	Email varchar(max)
)

DECLARE @isDefault bit = 0

IF EXISTS(SELECT top 1 1  FROM  CWI_Invoice I
			INNER JOIN CWI_ClientInvoiceDelivery CID
			ON CID.ClientId = I.ClientId 
				WHERE I.Id = @InvoiceId)
BEGIN
	SET @isDefault  = 1
END



INSERT INTO @tblMethod
SELECT 
	1,DeliveryLookupId , DeliveryEmail
FROM CWI_InvoiceDelivery 
WHERE
	InvoiceId = @InvoiceId
	AND IsDeleted = 0

	SELECT TOP 1 @Method = t.DeliveryMethods
	FROM
	(SELECT   
		dummyId,
            Stuff((SELECT '','' + CAST(ISNULL(MethodId ,0) AS varchar(max))
                        FROM   @tblMethod t2 
                        WHERE  t2.dummyId = t1.dummyId 
                        FOR XML PATH('''')), 1, 1, '''') DeliveryMethods 
        FROM   @tblMethod t1 
       group by dummyId
	) t

	SELECT TOP 1 @Email = t.Email
	FROM
	(SELECT   
		dummyId,
            Stuff((SELECT  '';'' + ISNULL(Email ,'''') 
                        FROM   @tblMethod t2 
                        WHERE  t2.dummyId = t1.dummyId  AND Email IS NOT NULL
                        FOR XML PATH('''')), 1, 1, '''') Email 
        FROM   @tblMethod t1 
       group by dummyId
	) t

SELECT 
	I.InvoiceNo,
	I.InvoiceDate,
	ISNULL(UD.Names ,'''') DeliveryBy,
	I.DeliveryOn,
	C.ClientCode + '' - '' + ClientName ClientName,
	CASE WHEN ISNULL(I.IsConsolidated,0) = 1 THEN ''Consolidated'' 
		ELSE ISNULL(LIT.LookupName,'''') END InvoiceType,
	I.InvoiceAmount,
	@isDefault isDefault,
	@Email Email,
	@Method DefaultMethod

FROM CWI_Invoice I
	INNER JOIN  CWI_Client C
		ON C.ID = I.ClientId
	LEFT OUTER JOIN Lookup LIT
		ON LIT.Id = I.InvoiceTypeLookupId
	LEFT OUTER JOIN CWI_User UD
		ON UD.Id = I.DeliveryBy
	
WHERE
	I.IsDeleted = 0
	AND I.Id = @InvoiceId
	
SET NOCOUNT OFF

' 
END
GO


