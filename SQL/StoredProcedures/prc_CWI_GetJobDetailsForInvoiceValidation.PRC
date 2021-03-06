/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobDetailsForInvoiceValidation]    Script Date: 7/10/2014 3:05:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobDetailsForInvoiceValidation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobDetailsForInvoiceValidation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobDetailsForInvoiceValidation]    Script Date: 7/10/2014 3:05:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobDetailsForInvoiceValidation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetInvoiceValidation  
* Purpose : This PROC would be called to check the validation before performing authorization
* Invoked from : ManageInvoice.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetJobDetailsForInvoiceValidation] 
@invoiceDate =''2013-10-20'',
@inClientId = 14163
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetJobDetailsForInvoiceValidation] 
	@invoiceDate DATETIME=NULL,
	@JobStatus varchar(max) = NULL,
	@ClientCode VARCHAR(MAX) = NULL,
	@ClientName VARCHAR(MAX) = NULL,
	@DivisionCode VARCHAR(MAX) = NULL,
	@DivisionName VARCHAR(MAX) = NULL,
	@IsConsolidated bit = NULL,
	@InvoiceType varchar(max) = NULL,
	@SearchType varchar(20)=NULL
		
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON

	DECLARE @tblInvoice TABLE
	(		
	   DivisionID INT,	
	   DivisionCode VARCHAR(5),
	   DivisionName VARCHAR(255),
	   ClientCode VARCHAR(5),
	   ClientName VARCHAR(255),
	   ClientID INT,
	   GroupClientId INT,
	   InvoiceDate DATETIME,			
	   TotalNet DECIMAL(18,2),
	   TotalGross DECIMAL(18,2),
       Margin DECIMAL(18,2),
       MarkupPercentage DECIMAL(18,2),  
	   ApprovedUserId INT,
	   ApprovedOn DATETIME,
	   ApprovedBy VARCHAR(200),
	   InvoiceType INT,
	   IsConsolidated BIT,
	   ValidationMessage VARCHAR(MAX),
	   IsDisabled BIT
	)

	
	INSERT INTO @tblInvoice
	EXEC prc_CWI_GetInvoiceByAdvanceSearch	@invoiceDate,@JobStatus,@ClientCode,@ClientName,@DivisionCode,@DivisionName,@IsConsolidated,@InvoiceType,@SearchType
	

			
		DECLARE @tblJob TABLE
		(	
			DivisionId INT,		
			JobNo BIGINT,
			MMRPO BIGINT,
			VendorId INT,
			VendorCode VARCHAR(50),
			VendorName VARCHAR(200),
			AdNet DECIMAL(18,2),
			AdGross DECIMAL(18,2),
			FreezeInvoice BIT,
			FreezeCost BIT,
			ComplimentaryInvoice BIT,
			ComplimentaryCost BIT,
			AdMargin DECIMAL(18,2),
			AdMarkupPercentage DECIMAL(18,2),			
			InvoiceDate DATETIME,
			PONumber VARCHAR(250) ,
			MediaBuyId BIGINT,
			IsService bit
			
		)		
		
		DECLARE @inClientID INT, @dtInvoiceDate DATETIME,@inCount INT
		
		SET @inCount = (SELECT COUNT(*) FROM @tblInvoice)

		WHILE (@inCount) > 0
		BEGIN

			SET @inClientID=(SELECT TOP 1 ClientId FROM @tblInvoice)
			SET @dtInvoiceDate = (SELECT TOP 1 CONVERT(DATETIME,InvoiceDate) FROM @tblInvoice)

			INSERT INTO @tblJob
				EXEC prc_CWI_GetInvoiceByAdvanceSearchForDivison @dtInvoiceDate,@inClientID			

			DELETE FROM @tblInvoice WHERE ClientId=(SELECT TOP 1 ClientId FROM @tblInvoice)

			SET @inCount = @inCount-1
		
		END
		
		SELECT DivisionId,MediaBuyId,JobNo,AdNet,AdGross,ComplimentaryInvoice,ComplimentaryCost FROM @tblJob
						

	END TRY

	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END



' 
END
GO
