/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendor]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendor]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendor]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendor  
* Purpose : This PROC would be called TO insert/update the vendor details
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetVendor
  
**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_SetVendor]
	@VendorId	int = 0 out,
	@VendorCode	varchar(50),
	@VendorName	varchar(200),
	@VendorTypeLookUpId	int = null,
	@BillingAddressLine1 varchar(255),
	@BillingAddressLine2 varchar(255),
	@BillingAddressCity varchar(50),
	@BillingAddressZip varchar(20),
	@BillingAddressStateId int,
	@BillingAddressCountryId int,
	@BillingAddressPhone varchar(50),
	@BillingAddressExt varchar(10),
	@BillingAddressFax varchar(50),
	@PhysicalAddressLine1 varchar(255),
	@PhysicalAddressLine2 varchar(255),
	@PhysicalAddressCity varchar(50),
	@PhysicalAddressZip varchar(20),
	@PhysicalAddressStateId int,
	@PhysicalAddressCountryId int,
	@PhysicalAddressPhone varchar(50),
	@PhysicalAddressExt varchar(10),
	@PhysicalAddressFax varchar(50),
	@VendorGroupLookupId	int,
	@VendorURL	varchar(100),
	@ClassificationLookupId	int = null,
	@Note	varchar(1000),
	@StatusLookupId	int,
	@AgencyDisc	numeric(18,3),
	@AccountRefID	varchar(100) = null,
	@PayMethodLookupId	int,
	@Author	int

AS
BEGIN
	DECLARE @AddressId_Billing int
	DECLARE @AddressId_Physical int
	
	

	IF (ISNULL(@AccountRefID,'''') = '''' AND @StatusLookupId = 552) OR (@StatusLookupId=0) --If Acc Ref id is empty and status is active or status is not passed, make the status as Pending
	begin
		SET @StatusLookupId = 551
	end

	If @VendorId = 0
	begin
		begin try
			IF EXISTS(SELECT top 1 1 FROM CWI_Vendor WHERE VendorCode = @VendorCode)
			begin
				declare @message NVARCHAR(2000) = ''Vendor Code '' + @VendorCode + '' already exists'';
				THROW 50000,@message , 1; 
			end
			--return;
		end try
		begin catch
			throw;

		end catch

		SET @AddressId_Billing=0
		SET @AddressId_Physical=0

		BEGIN TRANSACTION
		BEGIN TRY
			EXEC [prc_CWI_SetAddress]
			@AddressId = @AddressId_Billing OUTPUT,
			@AddressLine1 = @BillingAddressLine1 ,
			@AddressLine2 = @BillingAddressLine2,
			@CountryID = @BillingAddressCountryId,
			@StateID = @BillingAddressStateId,
			@City = @BillingAddressCity,
			@Zip  = @BillingAddressZip,
			@WorkPhone = @BillingAddressPhone,
			@WorkExtn = @BillingAddressExt,
			@WorkFax = @BillingAddressFax,
			@Author = @author

			EXEC [prc_CWI_SetAddress]
			@AddressId = @AddressId_Physical OUTPUT,
			@AddressLine1 = @PhysicalAddressLine1 ,
			@AddressLine2 = @PhysicalAddressLine2,
			@CountryID = @PhysicalAddressCountryId,
			@StateID = @PhysicalAddressStateId,
			@City = @PhysicalAddressCity,
			@Zip  = @PhysicalAddressZip,
			@WorkPhone = @PhysicalAddressPhone,
			@WorkExtn = @PhysicalAddressExt,
			@WorkFax = @PhysicalAddressFax,
			@Author = @author

			INSERT INTO [dbo].[CWI_Vendor]
			   ([VendorCode]
			   ,[VendorName]
			   ,[VendorTypeLookUpId]
			   ,[AddressId_Billing]
			   ,[AddressId_Physical]
			   ,[VendorGroupLookupId]
			   ,[VendorURL]
			   ,[ClassificationLookupId]
			   ,[Note]
			   ,[StatusLookupId]
			   ,[AgencyDisc]
			   ,[AccountRefID]
			   ,[PayMethodLookupId]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn])
		 VALUES
			   (@VendorCode,
				@VendorName,
				@VendorTypeLookUpId	,
				@AddressId_Billing	,
				@AddressId_Physical	,
				@VendorGroupLookupId	,
				@VendorURL	,
				@ClassificationLookupId	,
				@Note	,
				@StatusLookupId	,
				@AgencyDisc	,
				@AccountRefID	,
				@PayMethodLookupId	,
				@Author,getdate(),@Author,getdate()	)

		



		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;

		SET @VendorId = SCOPE_IDENTITY()

		RETURN
	end

	ELSE
	BEGIN	
		BEGIN TRANSACTION
		BEGIN TRY
	
			UPDATE [dbo].[CWI_Vendor]
		   SET [VendorName] = @VendorName
			  ,[VendorTypeLookUpId] = @VendorTypeLookUpId
			  ,[VendorGroupLookupId] = @VendorGroupLookupId
			  ,[VendorURL] = @VendorURL
			  ,[ClassificationLookupId] = @ClassificationLookupId
			  ,[Note] = @Note
			  ,[StatusLookupId] = @StatusLookupId
			  ,[AgencyDisc] = @AgencyDisc
			  ,[AccountRefID] = @AccountRefID
			  ,[PayMethodLookupId] = @PayMethodLookupId
			  ,[ModifiedBy] = @Author
			  ,[ModifiedOn] = GETDATE()
		 WHERE Id= @VendorId

			SELECT @AddressId_Billing= V.AddressId_Billing, @AddressId_Physical= V.AddressId_Physical  FROM CWI_Vendor V
			WHERE V.Id = @VendorId

			EXEC [prc_CWI_SetAddress]
				@AddressId = @AddressId_Billing OUTPUT,
				@AddressLine1 = @BillingAddressLine1 ,
				@AddressLine2 = @BillingAddressLine2,
				@CountryID = @BillingAddressCountryId,
				@StateID = @BillingAddressStateId,
				@City = @BillingAddressCity,
				@Zip  = @BillingAddressZip,
				@WorkPhone = @BillingAddressPhone,
				@WorkExtn = @BillingAddressExt,
				@WorkFax = @BillingAddressFax,
				@Author = @author

			EXEC [prc_CWI_SetAddress]
				@AddressId = @AddressId_Physical OUTPUT,
				@AddressLine1 = @PhysicalAddressLine1 ,
				@AddressLine2 = @PhysicalAddressLine2,
				@CountryID = @PhysicalAddressCountryId,
				@StateID = @PhysicalAddressStateId,
				@City = @PhysicalAddressCity,
				@Zip  = @PhysicalAddressZip,
				@WorkPhone = @PhysicalAddressPhone,
				@WorkExtn = @PhysicalAddressExt,
				@WorkFax = @PhysicalAddressFax,
				@Author = @author

		


		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;

	END		


	--select * from CWI_Vendor
END



' 
END
GO
