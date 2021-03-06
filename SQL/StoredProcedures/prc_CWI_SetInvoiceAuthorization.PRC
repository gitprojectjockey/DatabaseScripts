/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceAuthorization]    Script Date: 7/10/2014 3:05:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceAuthorization]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetInvoiceAuthorization]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoiceAuthorization]    Script Date: 7/10/2014 3:05:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoiceAuthorization]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetInvoiceAuthorization  
* Purpose : This PROC would be called to authorize invoice
* Invoked from : ManageInvoice.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetInvoiceAuthorization] 
@invoiceData = ,
@vcJobId = ''1313,1324'',
@inUserId=7
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetInvoiceAuthorization] 
@invoiceData XML,
@inUserId INT,
@vcMessage varchar(max) OUTPUT  
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON

	DECLARE @isAuthorize bit=1
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
		FROM @invoiceData.nodes(''DocumentElement/InvoiceDataTable'') AS TABX(COLX)	
	
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
	DECLARE @tblClient TABLE
	(
		ClientId INT,
		InvoiceDate VARCHAR(50),
		IsConsolidated BIT,
		InvoiceTypeLookupId INT,
		InvoiceAmount MONEY		
	)	
	
	INSERT INTO @tblClient 
		SELECT * FROM @tblInvoice

	DECLARE @inClientID INT, @dtInvoiceDate DATETIME,@inCount INT
		
	SET @inCount = (SELECT COUNT(*) FROM @tblClient)

	WHILE (@inCount) > 0
	BEGIN

		SET @inClientID=(SELECT TOP 1 ClientId FROM @tblClient)
		SET @dtInvoiceDate = (SELECT TOP 1 CONVERT(DATETIME,InvoiceDate) FROM @tblClient)

		INSERT INTO @tblJob
			EXEC prc_CWI_GetInvoiceByAdvanceSearchForDivison @dtInvoiceDate,@inClientID

		DELETE FROM @tblClient WHERE ClientId=(SELECT TOP 1 ClientId FROM @tblClient)

		SET @inCount = @inCount-1
		
	END
	
	----------------------INVOICE VALIDATIONS--------------------------	
		DELETE FROM @tblClient

		INSERT INTO @tblClient 
			SELECT * FROM @tblInvoice

		DECLARE @tblInvoiceValidation TABLE 
		(
			ClientId INT,
			ValidationMessage VARCHAR(MAX),
			IsDisabled BIT
		)

		SET @inCount = (SELECT COUNT(*) FROM @tblClient)
		
		WHILE @inCount > 0
		BEGIN
			DECLARE @intClientID INT, @dateInvoice DATETIME

			SET @intClientID=(SELECT TOP 1 ClientId FROM @tblClient)
			SET @dateInvoice = (SELECT TOP 1 CONVERT(DATETIME,InvoiceDate) FROM @tblClient)

			INSERT INTO @tblInvoiceValidation
				SELECT *  FROM fnc_CWI_GetInvoiceValidation(@dateInvoice,@intClientID )

			DELETE FROM @tblClient WHERE ClientId=@intClientID

			SET @inCount = @inCount-1
		END
		
		IF (SELECT COUNT(*) FROM @tblInvoiceValidation WHERE IsDisabled=1) > 0 
		BEGIN
			SET @isAuthorize = 0
			SET @vcMessage = ''Invoice authorization is not allowed for the selected division(s)._Please move the cursor to disabled checkbox to get more details.''
			--SET @vcMessage = (SELECT DISTINCT STUFF((SELECT ''_'' + ValidationMessage FROM @tblInvoiceValidation FOR XML PATH('''')) ,1,1,'''') AS ValidationMessage)
			RETURN
		END

		-----Removed validation from here----------------

	-----------------AUTHORIZE IF ALL CONDITION SATISFIED--------
		IF @isAuthorize = 1
		BEGIN
			BEGIN TRANSACTION TRAN1
			BEGIN TRY
					
					DECLARE @inInvoiceCount INT,@inInvoiceId INT,@inInvClientId INT
		
					SET @inInvoiceCount = (SELECT COUNT(*) FROM @tblInvoice)

					WHILE (@inInvoiceCount) > 0
					BEGIN				
						SET @inInvClientId=(SELECT TOP 1 ClientId FROM @tblInvoice)		
							INSERT INTO CWI_Invoice 
							(
								ClientId,
								InvoiceDate,
								IsConsolidated,
								StatusLookupId,
								InvoiceTypeLookupId,
								InvoiceAmount,
								CreatedBy,
								CreatedOn,
								ModifiedBy,
								ModifiedOn		
							)
							SELECT TOP 1
								ClientId,
								CONVERT(DATE,InvoiceDate),
								IsConsolidated,
								8008,  -- JOB STATUS 8008 - Pending Invoice Processing
								InvoiceTypeLookupId,
								InvoiceAmount,
								@inUserId,
								GETDATE(),
								@inUserId,
								GETDATE()
							FROM @tblInvoice	
							
							SET @inInvoiceId = (SELECT SCOPE_IDENTITY())

							IF EXISTS(SELECT DivisionId FROM @tblJob  WHERE DivisionId=@inInvClientId)
							BEGIN
								UPDATE CWI_Job 
									SET JobStatusLookupId=8008, -- JOB STATUS 8008 - Pending Invoice Processing
									InvoiceId = @inInvoiceId,
									InvoiceGeneratedDate=GETDATE(),
									ModifiedBy=@inUserId,
									ModifiedOn=GETDATE()
								WHERE ID IN (SELECT DISTINCT JobNo FROM @tblJob WHERE DivisionId=@inInvClientId)

								UPDATE CWI_JobMediaBuy SET StatusId = 20105,---Invoiced
								ModifiedBy=@inUserId,ModifiedOn=GETDATE()
								FROM CWI_JobMediaBuy  JMB
								INNER JOIN CWI_JOB  J
								ON J.Id = JMB.JobId
								WHERE J.InvoiceId = @inInvoiceId 
									AND JMB.IsRemoved=0
									AND JMB.IsCancelled = 0
									AND JMB.DNR = 0
								
							END
							ELSE
							BEGIN
								DECLARE @TBL_DIVISIONS TABLE(DivId INT)

								INSERT INTO @TBL_DIVISIONS
									SELECT ID FROM CWI_Client WHERE ParentID=@inInvClientId

								UPDATE CWI_Job 
									SET JobStatusLookupId=8008, -- JOB STATUS 8008 - Pending Invoice Processing
									InvoiceId = @inInvoiceId,
									InvoiceGeneratedDate=GETDATE(),
									ModifiedBy=@inUserId,
									ModifiedOn=GETDATE()
								WHERE ID IN (SELECT DISTINCT JobNo FROM @tblJob J INNER JOIN @TBL_DIVISIONS D ON D.DivId=J.DivisionId)

								UPDATE CWI_JobMediaBuy SET StatusId = 20105,---Invoiced
								ModifiedBy=@inUserId,ModifiedOn=GETDATE()
								FROM CWI_JobMediaBuy  JMB
								INNER JOIN CWI_JOB  J
								ON J.Id = JMB.JobId
								WHERE J.InvoiceId = @inInvoiceId 
									AND JMB.IsRemoved=0
									AND JMB.IsCancelled = 0
									AND JMB.DNR = 0

							END


						DELETE FROM @tblInvoice WHERE ClientId=@inInvClientId

						SET @inInvoiceCount = @inInvoiceCount-1
		
					END					

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT >0 
					ROLLBACK TRANSACTION TRAN1;
				EXEC prc_CWI_AppRaiseError;
				THROW;
			END CATCH
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION TRAN1;
		
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
