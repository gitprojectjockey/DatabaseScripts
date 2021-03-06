/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceDelivery]    Script Date: 5/2/2014 1:41:45 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceDelivery]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceDelivery]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceDelivery]    Script Date: 5/2/2014 1:41:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceDelivery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceDelivery  
* Purpose : This PROC would be called to get invoice delivery related fields
* Invoked from : InvoiceDelivery.aspx
* CREATED: Saravanan m
* CREATED ON:  03/18/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example : 
exec prc_CWI_GetInvoiceDelivery
	@InvoiceDate  = NULL,
       @Status  = NULL,
       @ClientCode  =  NULL,
       @ClientName  = NULL,
       @DivisionCode = NULL,
       @DivisionName = ''high'',
       @DeliveryMethod  = NULL,
       @InvoiceNumber  = NULL
***********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetInvoiceDelivery] 
	   @InvoiceDate datetime = NULL,
       @Status int = NULL,
       @ClientCode varchar(1000) =  NULL,
       @ClientName varchar(1000) = NULL,
       @DivisionCode varchar(1000) = NULL,
       @DivisionName varchar(1000) = NULL,
       @DeliveryMethod varchar(1000) = NULL,
       @InvoiceNumber bigint = NULL
AS
BEGIN
	DECLARE @tblDeliveryMethod TABLE
	(
		   MethodId int
	)


	IF @DeliveryMethod IS NOT NULL
	BEGIN
		   INSERT INTO @tblDeliveryMethod
		   SELECT CAST(Items as int) FROm dbo.fnc_SplitCommaSeparatedValuesIntoTable(@DeliveryMethod,'','')
	END
       
	IF ISNULL(@DivisionCode,'''') = '''' AND ISNULL(@DivisionName,'''') = ''''
	Begin
		select 
	
				I.Id InvoiceId,
			   I.InvoiceDate,
			   InvStatus.LookupName InvoiceStatus,
			   CASE WHEN ISNULL(I.isconsolidated,0)= 1 THEN ''Consolidated'' 
					  ELSE ISNULL(LInvType.LookupName,'''') END InvoiceType,
			   I.InvoiceAmount,
			   ISNULL(C.ClientCode,D.ClientCode) ClientCode,
			   ISNULL(C.ClientName,D.ClientName) ClientName,
			   I.InvoiceNo,
			   D.ID DivisionId,
			   CI.Email,
			   U.Names DeliveryBy,
			   I.DeliveryOn,
			   CID.DeliveryMethods,
			   I.StatusLookupId
			FROM CWI_Invoice I
			INNER JOIN CWI_Client D
				   ON D.Id = I.ClientId
			INNER JOIN Lookup InvStatus
				   ON InvStatus.Id = I.StatusLookupId
			LEFT OUTER JOIN
				   (
              
				   SELECT ClientId, 
										  Stuff((SELECT '','' + CAST(ISNULL(DeliveryMethodLookupId ,0) AS varchar(max))
													   FROM   CWI_ClientInvoiceDelivery t2 
													   WHERE  t2.ClientId = t1.ClientId AND IsActive=1
													   FOR XML PATH('''')), 1, 1, '''') DeliveryMethods
									   FROM   CWI_ClientInvoiceDelivery t1 
									   GROUP  BY ClientId
									   ) CID
				   ON CID.ClientId = I.ClientId
			LEFT OUTER JOIN CWI_User U
				   ON U.Id = I.DeliveryBy
			LEFT OUTER JOIN CWI_ClientInvoice CI
				   ON CI.ClientId = I.ClientId
			LEFT OUTER JOIN CWI_Client C
				   ON C.Id = D.ParentID
			LEFT OUTER JOIN Lookup LInvType
				   ON LInvType.Id = I.InvoiceTypeLookupId
			WHERE
			   I.IsDeleted = 0
			   AND (@InvoiceDate IS NULL OR I.InvoiceDate = @InvoiceDate)
			   AND (@Status IS NULL OR I.StatusLookupId = @Status)
			   AND (@ClientCode IS NULL OR D.ClientCode like ''%'' +  @ClientCode + ''%'')
			   AND (@ClientName IS NULL OR D.ClientName like ''%'' +  @ClientName + ''%'')
			   --AND (@DivisionCode IS NULL OR D.ClientCode like ''%'' + @DivisionCode + ''%'')
			   --AND (@DivisionName IS NULL OR D.ClientName like ''%'' + @DivisionName + ''%'')
			   AND I.StatusLookupId <> 8008 
			   AND 
			   ( 
					  @DeliveryMethod IS NULL OR 
					  EXISTS (
							 SELECT top 1 1 FROM @tblDeliveryMethod t
							 INNER JOIN CWI_ClientInvoiceDelivery CD ON t.MethodId = CD.DeliveryMethodLookupId
							 WHERE CD.ClientId = I.ClientId AND CD.IsActive = 1
							 ) 
			   )
			   AND (@InvoiceNumber IS NULL OR I.InvoiceNo =   @InvoiceNumber )

			   RETURN
		End

		select 
			DISTINCT
				I.Id InvoiceId,
			   I.InvoiceDate,
			   InvStatus.LookupName InvoiceStatus,
			   CASE WHEN ISNULL(I.isconsolidated,0)= 1 THEN ''Consolidated'' 
					  ELSE ISNULL(LInvType.LookupName,'''') END InvoiceType,
			   I.InvoiceAmount,
			   ISNULL(C.ClientCode,D.ClientCode) ClientCode,
			   ISNULL(C.ClientName,D.ClientName) ClientName,
			   I.InvoiceNo,
			   D.ID DivisionId,
			   CI.Email,
			   U.Names DeliveryBy,
			   I.DeliveryOn,
			   CID.DeliveryMethods,
			   I.StatusLookupId
			FROM CWI_Invoice I
			INNER JOIN CWI_Client D
				   ON D.Id = I.ClientId
			INNER JOIN Lookup InvStatus
				   ON InvStatus.Id = I.StatusLookupId
			INNER JOIN CWI_Job J
				ON J.InvoiceId = I.Id
			INNER JOIN CWI_Client JD
				   ON JD.Id = J.DivisionId
			LEFT OUTER JOIN
				   (
              
				   SELECT ClientId, 
										  Stuff((SELECT '','' + CAST(ISNULL(DeliveryMethodLookupId ,0) AS varchar(max))
													   FROM   CWI_ClientInvoiceDelivery t2 
													   WHERE  t2.ClientId = t1.ClientId AND IsActive=1
													   FOR XML PATH('''')), 1, 1, '''') DeliveryMethods
									   FROM   CWI_ClientInvoiceDelivery t1 
									   GROUP  BY ClientId
									   ) CID
				   ON CID.ClientId = I.ClientId
			LEFT OUTER JOIN CWI_User U
				   ON U.Id = I.DeliveryBy
			LEFT OUTER JOIN CWI_ClientInvoice CI
				   ON CI.ClientId = I.ClientId
			LEFT OUTER JOIN CWI_Client C
				   ON C.Id = D.ParentID
			LEFT OUTER JOIN Lookup LInvType
				   ON LInvType.Id = I.InvoiceTypeLookupId
			WHERE
			   I.IsDeleted = 0
			   AND (@InvoiceDate IS NULL OR I.InvoiceDate = @InvoiceDate)
			   AND (@Status IS NULL OR I.StatusLookupId = @Status)
			   AND (@ClientCode IS NULL OR D.ClientCode like ''%'' +  @ClientCode + ''%'')
			   AND (@ClientName IS NULL OR D.ClientName like ''%'' +  @ClientName + ''%'')
			   AND 
			   (
					(
						(@DivisionCode IS NULL OR D.ClientCode like ''%'' + @DivisionCode + ''%'') AND
						 (@DivisionName IS NULL OR D.ClientName like ''%'' + @DivisionName + ''%'')
					)
					OR 
					(
						(@DivisionCode IS NULL OR JD.ClientCode like ''%'' + @DivisionCode + ''%'')
						AND (@DivisionName IS NULL OR JD.ClientName like ''%'' + @DivisionName + ''%'')
					)
				)
			   AND I.StatusLookupId <> 8008 
			   AND 
			   ( 
					  @DeliveryMethod IS NULL OR 
					  EXISTS (
							 SELECT top 1 1 FROM @tblDeliveryMethod t
							 INNER JOIN CWI_ClientInvoiceDelivery CD ON t.MethodId = CD.DeliveryMethodLookupId
							 WHERE CD.ClientId = I.ClientId AND CD.IsActive = 1
							 ) 
			   )
			   AND (@InvoiceNumber IS NULL OR I.InvoiceNo =   @InvoiceNumber )
END








' 
END
GO
