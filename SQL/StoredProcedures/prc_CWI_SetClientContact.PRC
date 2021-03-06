/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientContact]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientContact' )
 DROP PROCEDURE [dbo].[prc_CWI_SetClientContact]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientContact]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientContact  
* Purpose : This PROC would be called TO insert/update the contact details
* Invoked from : Client.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientContact @ContactId = 0 OUT,
	@ClientId =22478,
	@Name = 'Mohan',
	@ContactTypeLookupId  = 6101,
	@Title varchar(50) = '',
	@Address  = '',
	@Email = 'Ajay@,acs.com'
	@PhoneWork = '8661234567',
	@PhoneCell ='',
	@PhoneOther ='',
	@Fax ='',
	@DOB datetime = NULL,
	@Interests ='',
	@Notes ='',
	@Author int,
	@IsCWPortalUser = 0
  
**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_SetClientContact]
	@ContactId int = 0 OUT,
	@ClientId int=0,
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
	@Author int,
	@IsCWPortalUser bit= 0
AS

IF @ContactId = 0
BEGIN
	INSERT CWI_ClientContact(ClientId, Name, ContactTypeLookupId, Title, Address, Email, PhoneWork, PhoneCell, PhoneOther, Fax, DOB, Interests, Notes, CreatedBy, ModifiedBy, IsCWPortalUser)
	VALUES (@ClientId, @Name, @ContactTypeLookupId, @Title, @Address, @Email, @PhoneWork, @PhoneCell, @PhoneOther, @Fax, @DOB, @Interests, @Notes, @Author, @Author,@IsCWPortalUser)
	SET @ContactId = SCOPE_IDENTITY()

	RETURN
END 

UPDATE	CWI_ClientContact
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
	ModifiedBy = @Author,
	IsCWPortalUser = @IsCWPortalUser,
	IsDeleted = 0
WHERE 	Id = @ContactId

RETURN


GO
