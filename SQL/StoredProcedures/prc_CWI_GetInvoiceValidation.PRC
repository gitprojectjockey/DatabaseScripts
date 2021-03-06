/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceValidation]    Script Date: 7/16/2014 7:14:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceValidation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetInvoiceValidation]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetInvoiceValidation]    Script Date: 7/16/2014 7:14:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetInvoiceValidation]') AND type in (N'P', N'PC'))
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
exec [prc_CWI_GetInvoiceValidation] 
@InvoiceFromDt =''2013-08-04'',
@inClientId = 14163
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetInvoiceValidation] 
	@invoiceDetails XML,
	@jobDetails XML,
	@inUserId INT,
	@vcMessage varchar(max) OUTPUT  
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON

	
	SET @vcMessage = ''''
	----------------------------------GETTING THE INVOICE & JOB DETAILS----------------
	DECLARE @tblInvoice TABLE
	(
		ClientId INT,
		InvoiceDate VARCHAR(50),
		IsConsolidated BIT,
		InvoiceTypeLookupId INT,
		InvoiceAmount MONEY		
	)

	INSERT INTO @tblInvoice
		SELECT 
			COLX.value(''(./ClientID)[1]'',''INT'') ClientId,
			COLX.value(''(./InvoiceDate)[1]'',''VARCHAR(50)'') InvoiceDate,
			COLX.value(''(./IsConsolidated)[1]'',''BIT'') IsConsolidated,
			COLX.value(''(./InvoiceTypeLookupId)[1]'',''INT'') InvoiceTypeLookupId,		
			COLX.value(''(./InvoiceAmount)[1]'',''DECIMAL(18,2)'') InvoiceAmount
		FROM @invoiceDetails.nodes(''DocumentElement/InvoiceDataTable'') AS TABX(COLX)	
	
	DECLARE @tblJobDetails TABLE
	(
		DivisionId INT,
		MediaBuyId BIGINT,
		JobId BIGINT,
		AdNet DECIMAL(18,2),
		AdGross DECIMAL(18,2),
		IsComplimentary BIT,
		IsComplimentaryInvoice BIT
	)

	INSERT INTO @tblJobDetails
		SELECT 
			COLX.value(''(./DivisionId)[1]'',''INT'') DivisionId,
			COLX.value(''(./MediaBuyId)[1]'',''BIGINT'') MediaBuyId,
			COLX.value(''(./JobNo)[1]'',''BIGINT'') JobId,
			COLX.value(''(./AdNet)[1]'',''DECIMAL(18,2)'') AdNet,
			COLX.value(''(./AdGross)[1]'',''DECIMAL(18,2)'') AdGross,		
			COLX.value(''(./ComplimentaryCost)[1]'',''BIT'') IsComplimentary,
			COLX.value(''(./ComplimentaryInvoice)[1]'',''BIT'') IsComplimentaryInvoice
		FROM @jobDetails.nodes(''DocumentElement/JobDataTable'') AS TABX(COLX)	
			
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
			PONumber VARCHAR(250),
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
				
			----------------------INVOICE VALIDATIONS--------------------------	
			
			if ((select count(*) from @tblJob) <>( select count(*) from @tblJobDetails))
			begin
				SET @vcMessage = ''Unable to perform Authorization. Information has changed since your last update. Please Refresh your Page.''
				RETURN
			end		
			
			if(select convert(decimal(18,2),InvoiceAmount) from @tblInvoice where ClientId=@inClientID)<>(select sum(AdGross) from @tblJob)-- where DivisionId=@inClientID)
			begin
				SET @vcMessage = ''Unable to perform Authorization. Information has changed since your last update. Please try again.''
				RETURN
			end			
			
			DECLARE @tblJobVal TABLE
			(
				DivisionId INT,
				MediaBuyId INT,
				JobId INT,
				AdNet DECIMAL(18,2),
				AdGross DECIMAL(18,2),
				IsComplimentary BIT,
				IsComplimentaryInvoice BIT
			)

			INSERT INTO @tblJobVal
				SELECT DivisionId,MediaBuyId,JobNo,AdNet,AdGross,ComplimentaryCost,ComplimentaryInvoice 
				FROM @tblJob
				EXCEPT
				SELECT DivisionId,MediaBuyId,JobId,AdNet,AdGross,IsComplimentary,IsComplimentaryInvoice
				FROM @tblJobDetails WHERE DivisionId IN (SELECT DISTINCT DivisionId FROM @tblJob) 				
			

			IF (SELECT COUNT(*) FROM @tblJobVal) >0
			BEGIN
				SET @vcMessage = ''Unable to perform Authorization. Information has changed since your last update. Please Refresh your Page.''
				RETURN
			END
			ELSE
			BEGIN
				DELETE FROM @tblJobVal
			END

			DELETE FROM @tblInvoice WHERE ClientId=(SELECT TOP 1 ClientId FROM @tblInvoice)

			SET @inCount = @inCount-1
		
		END
						

	END TRY

	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END








' 
END
GO
