/****** Object:  StoredProcedure [dbo].[prc_CWI_SetDeliveryEMail]    Script Date: 11/11/2014 2:35:48 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetDeliveryEMail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetDeliveryEMail]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetDeliveryEMail]    Script Date: 11/11/2014 2:35:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetDeliveryEMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetDeliveryEMail
* Purpose : This PROC would be called TO get all the emails related to Vendor
* Invoked from : Vendor.aspx
* CREATED: Saravanan Mahalingam 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetDeliveryEMail @vendorID=7072,@CorrespondenceLookupId=701,@DeliveryMethodLookupId=801,@Email=''tests@gmail.com'',@Author=8
  
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetDeliveryEMail] 
	@vendorID int,	
	@CorrespondenceLookupId INT,
	@DeliveryMethodLookupId int,
	@Email varchar(150),
	@IsAssociatedClients bit,
	@isActive bit=1,
	@Author int
AS
BEGIN
	Declare @ID int=NULL,@count int=0;

	IF ( @isActive = 0)
	begin
		SET @IsAssociatedClients = 0
	end

	

	SELECT @ID = Id FROM CWI_VendorCorrespondence 
	WHERE CorrespondenceLookupId=@CorrespondenceLookupId AND VendorID=@vendorID
				AND DeliveryMethodLookupId=@DeliveryMethodLookupId

	IF (@ID IS NULL)
	BEGIN
		
		INSERT INTO [dbo].[CWI_VendorCorrespondence]
					([VendorId]
					,[CorrespondenceLookupId]
					,[DeliveryMethodLookupId] 
					,[CreatedBy]
					,[CreatedOn]
					,[ModifiedBy]
					,[ModifiedOn])
			VALUES
				(@vendorID,
				@CorrespondenceLookupId,
				@DeliveryMethodLookupId,
				@Author,
				GETDATE(),
				@Author,
				GETDATE());
		set @ID=SCOPE_IDENTITY();
	
		INSERT INTO CWI_VendorCorrespondenceDelivery 
					([VendorCorrespondenceID],
					[EMailID],
					[IsAssociatedClients],
					[CreatedBy]
					,[CreatedOn]
					,[ModifiedBy]
					,[ModifiedOn]
					, isActive)
			VALUES	
					(@ID,
					@Email,
					@IsAssociatedClients,
					@Author,
					GETDATE(),
					@Author,
					GETDATE(),
					@isActive);

	END
	ELSE
	BEGIN
		DECLARE @corredDeliveryId int = NULL
		Select top 1 @corredDeliveryId = Id from CWI_VendorCorrespondenceDelivery 
					where VendorCorrespondenceID=@ID and EmailID=@Email
		if (@corredDeliveryId IS NULL)
		BEGIN

			INSERT INTO CWI_VendorCorrespondenceDelivery 
					([VendorCorrespondenceID],
					[EMailID],
					[IsAssociatedClients],
					[CreatedBy]
					,[CreatedOn]
					,[ModifiedBy]
					,[ModifiedOn]
					, isActive)
			VALUES	
					(@ID,
					@Email,
					@IsAssociatedClients,
					@Author,
					GETDATE(),
					@Author,
					GETDATE(),
					@isActive);

		END
		else
		BEGIN

			UPDATE CWI_VendorCorrespondenceDelivery
			SET
				EmailID=@Email,
				IsAssociatedClients=@IsAssociatedClients,
				[ModifiedBy]=@Author
				,[ModifiedOn]=GETDATE()
				, IsActive = @isActive
			WHERE 
				VendorCorrespondenceId=@ID AND EMailID=@Email; 

		END

		

	END
END

' 
END
GO


