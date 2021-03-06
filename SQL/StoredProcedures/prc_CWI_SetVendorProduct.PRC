/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorProduct]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorProduct]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorProduct]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorProduct]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorProduct]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorProduct  
* Purpose : This PROC would be called TO save vendor product
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetVendorProduct 3,3,1000,''Product Desc'', ''Product Detail'',1
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetVendorProduct]
    @VendorId int,
	@Author int,
	@ClassProductId int,
	@ProductDesc varchar(100),
	@ProductDetail varchar(1000),
	@IsActive bit
AS
BEGIN
	BEGIN TRY
		DECLARE @Id int
		SET @Id = 0

		SELECT @Id  =Id FROM CWI_VendorProduct
		WHERE VendorId = @VendorId AND ClassificationProductId = @ClassProductId AND IsDeleted = 0

		IF @Id =0
		BEGIN
			INSERT INTO [dbo].[CWI_VendorProduct]
				   ([VendorId]
				   ,[ClassificationProductId]
				   ,[ProductDesc]
				   ,[ProductDetails]
				   ,IsActive
				   ,[CreatedBy]
				   ,[CreatedOn]
				   ,[ModifiedBy]
				   ,[ModifiedOn])
			 VALUES
				   (
					@VendorId,
					@ClassProductId,
					@ProductDesc,
					@ProductDetail,
					@IsActive,
					@Author,
					GETDATE(),
					@Author,
					GETDATE()
					)

		END
		ELSE
		BEGIN
			UPDATE [dbo].[CWI_VendorProduct]
			SET 
				[VendorId] = @VendorId,
				[ClassificationProductId] = @ClassProductId,
		  		[ProductDesc] = @ProductDesc,
				[ProductDetails] = @ProductDetail,
				IsActive = @IsActive,
				[ModifiedBy] = @Author,
				[ModifiedOn] = GETDATE()
			 WHERE Id  = @Id

		END

		EXEC prc_CWI_GetVendorProducts @VendorId
	END TRY

	BEGIN CATCH
		EXEC prc_CWI_AppRaiseError; 
		THROW;
	END CATCH

END



' 
END
GO
