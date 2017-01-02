/****** Object:  StoredProcedure [dbo].[prc_CWI_AddVendorFromLookup]    Script Date: 1/7/2014 6:36:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_AddVendorFromLookup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_AddVendorFromLookup  
* Purpose : This PROC would be called TO insert the vendor from Vendor Lookup
* Invoked from : VendorLookup.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
 7 JAN13	Mohankumar		Email Sending code added            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_AddVendorFromLookup]
  
**********************************************************************/ 


ALTER PROC [dbo].[prc_CWI_AddVendorFromLookup]
	@name varchar(500),
    @address varchar(500),
    @zip varchar(100),
	@phone varchar(100),
    @web varchar(500),
    @classid int,
	@city varchar(100),
	@state varchar(100),
	@country varchar(100),
	@lat decimal(29,10),
	@lng decimal(29,10),
	@Author	int
	

AS
BEGIN

	DECLARE
	@VendorId	int = 0 ,
	@VendorCode	varchar(50),
	@VendorName	varchar(200) = @name,
	@VendorTypeLookUpId	int = null,
	@BillingAddressLine1 varchar(255) = @address,
	@BillingAddressLine2 varchar(255)='''',
	@BillingAddressCity varchar(50),
	@BillingAddressZip varchar(20),
	@BillingAddressStateId int,
	@BillingAddressCountryId int,
	@BillingAddressPhone varchar(50),
	@BillingAddressExt varchar(10),
	@BillingAddressFax varchar(50),
	@PhysicalAddressLine1 varchar(255)=@address,
	@PhysicalAddressLine2 varchar(255)='''',
	@PhysicalAddressCity varchar(50),
	@PhysicalAddressZip varchar(20),
	@PhysicalAddressStateId int,
	@PhysicalAddressCountryId int,
	@PhysicalAddressPhone varchar(50),
	@PhysicalAddressExt varchar(10),
	@PhysicalAddressFax varchar(50),
	@VendorGroupLookupId	int,
	@VendorURL	varchar(100) = @web,
	@ClassificationLookupId	int = @classid,
	@Note	varchar(1000),
	@StatusLookupId	int,
	@AgencyDisc	numeric(18,3),
	@AccountRefID	varchar(100) = null,
	@PayMethodLookupId	int = 852
	

	DECLARE @AddressId_Billing int
	DECLARE @AddressId_Physical int
	
	

	--make the status as Pending
	SET @StatusLookupId = 551
	

	
	begin
		begin try
			SET @VendorCode = SUBSTRING(@name,1, 5)
			declare @inc int=0
			declare @strinc varchar(10)

			WHILE EXISTS(SELECT top 1 1 FROM CWI_Vendor WHERE VendorCode = @VendorCode)
			begin
				SET @inc = @inc +1
				SET @strinc = cast(@inc as varchar(10))
				SET @VendorCode = SUBSTRING(@VendorCode,1,len(@VendorCode)-len(@strinc)) +
								  @strinc
			end
			
			if @zip = '''' OR @state = '''' OR @city = '''' OR @country = ''''
			begin
				if @zip <> ''''
				BEGIN
					SELECT  top 1 @state = ProvinceAbbr, @city = CityName, @country = CountryName  
					FROM ZipCode zips
					where zips.ZipCode = @zip AND zips.CityType = ''D'' 
				END
				ELSE
				BEGIN
					SELECT  top 1 @state = ProvinceAbbr, @city = CityName, @country = CountryName  
					FROM ZipCode zips
					WHERE
					zips.CityType = ''D'' AND
					dbo.CalculateDistance(@lat, @lng, [zips].[Latitude], [zips].[Longitude], ''Miles'') <100
					order by 
						dbo.CalculateDistance(@lat, @lng, [zips].[Latitude], [zips].[Longitude], ''Miles'')
				END
			end

			if @zip= '''' 
			begin
				SET @zip = ''00000''
			end
			SET @PhysicalAddressZip = @zip
			SET @BillingAddressZip = @zip
			
			if @city=''''
			begin
				SET @city = ''UNKNOWN''
			end
			SET @PhysicalAddressCity = @city
			SET @BillingAddressCity = @city
			if @country = ''CAN'' OR @country = ''CA'' OR @country = ''CANADA''
			begin
				SET @PhysicalAddressCountryId = 2
			end
			else
			begin
				SET @PhysicalAddressCountryId = 1
			end
			SET @BillingAddressCountryId = @PhysicalAddressCountryId 
			
			SET @PhysicalAddressStateId = NULL
			select top 1 @PhysicalAddressStateId = ID from state
			where StateCode = @state	OR StateName = @state
			if ISNULL(@PhysicalAddressStateId ,0) = 0
			begin
				SET @PhysicalAddressStateId = 2
			end
			SET @BillingAddressStateId = @PhysicalAddressStateId
			
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

		EXECUTE prc_CWI_SetVendorActivationRequest @VendorId,@Author

		RETURN
	end



	--select * from CWI_Vendor
END




' 
END