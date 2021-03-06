/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorContact]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorContact]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorContact]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorContact]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorContact]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorContact  
* Purpose : This PROC would be called TO insert/update the contact details
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetVendorContact
  
**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_SetVendorContact]
	@ContactId int = 0 OUT,
	@VendorId int=0,
	@Name varchar(100),
	@ContactTypeLookupId int = NULL,
	@Title varchar(50) = NULL,
	@Address varchar(200) = NULL,
	@Email varchar(100),
	@PhoneWork varchar(50),
	@PhoneCell varchar(50) = NULL,
	@PhoneOther varchar(50) = NULL,
	@Fax varchar(50) = NULL,
	@DOB datetime = NULL,
	@Interests varchar(200) = NULL,
	@Notes varchar(1000) = NULL,
	@Author int
AS

IF EXISTS(SELECT top 1 1 FROM CWI_VendorContact (NOLOCK) WHERE Email = @Email AND IsDeleted = 0
			AND VendorId = @VendorId AND ID <> @ContactId)
BEGIN
	declare @message NVARCHAR(2000) = ''Email '' + @Email + '' already exists for the vendor'';
	THROW 50000,@message , 1; 
END
	

IF @ContactId = 0
BEGIN
	INSERT CWI_VendorContact(VendorId, Name, ContactTypeLookupId, Title, Address, Email, PhoneWork, PhoneCell, PhoneOther, Fax, DOB, Interests, Notes, CreatedBy, ModifiedBy)
	VALUES (@VendorId, @Name, @ContactTypeLookupId, @Title, @Address, @Email, @PhoneWork, @PhoneCell, @PhoneOther, @Fax, @DOB, @Interests, @Notes, @Author, @Author)
	SET @ContactId = SCOPE_IDENTITY()

	

	RETURN
END 

UPDATE	CWI_VendorContact
SET	
	Name = @Name,
	ContactTypeLookupId = @ContactTypeLookupId,
	Title = @Title,
	Address = @Address,
	Email = @Email,
	PhoneWork = @PhoneWork,
	PhoneCell = @PhoneCell,
	PhoneOther = @PhoneOther,
	Fax = @Fax,
	DOB = @DOB,
	Interests = @Interests,
	Notes = @Notes,
	ModifiedBy = @Author
WHERE 	Id = @ContactId


RETURN

' 
END
GO
