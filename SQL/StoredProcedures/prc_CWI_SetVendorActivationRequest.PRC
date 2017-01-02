/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorActivationRequest]    Script Date: 1/7/2014 6:39:00 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorActivationRequest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorActivationRequest]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorActivationRequest]    Script Date: 1/7/2014 6:39:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorActivationRequest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorActivationRequest
* Purpose : This PROC would be called TO 
				-->It will insert a new System Generated Comment 
				-->It will also email Activation Request.
* Invoked from : VendorLookup.aspx  (through stored procedure prc_CWI_AddVendorFromLookup)
* CREATED: Mohankumar Sundaram
* CREATED ON : 07 Jan2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
[prc_CWI_SetVendorActivationRequest] 1,1
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetVendorActivationRequest]    
    @inVendorID int,
	@inCreatedBy int
	

AS
BEGIN
	BEGIN TRANSACTION Trans1
	BEGIN TRY
		

		declare @vcRequestorDomainLoginName varchar(100),
				@vcRequestorNameAndEmail varchar(255),
				@vcbody NVARCHAR(MAX),
				@vcprofilename varchar(255), 
				@vcemailSubject varchar(255),
				@vcEmailAddress varchar(255),
				@vcVendorCode varchar(15),
				@vcVendorName varchar(255)

		select @vcprofilename = dbo.[fnc_CWI_GetSingleLookupName](16)

		SELECT 
			
			@vcRequestorDomainLoginName = Names + '' - '' + Domain + ''\'' + [Login] ,
			@vcRequestorNameAndEmail = [Names] + 
				 (CASE WHEN (ISNULL(Email,'''') = '''') THEN '''' ELSE '' ('' + Email + '')'' END)
			
		from CWI_User
		where ID = @inCreatedBy

		--Mail address is picked from Lookup table..lookuptypeid is 42
		select @vcEmailAddress = dbo.[fnc_CWI_GetSingleLookupName](42)

		IF(ISNULL(@vcEmailAddress,'''') = '''')
		begin
			set @vcEmailAddress = dbo.[fnc_CWI_GetSingleLookupName](43) -- default email address
		end

		SET @vcEmailAddress = REPLACE(@vcEmailAddress,'','','';'')
		
		select @vcVendorCode = VendorCode,
				@vcVendorName = VendorName
				from CWI_Vendor
				where ID = @inVendorID
	
		
		set @vcemailSubject = ''ClientWise : Request for Vendor Activation '' + @vcVendorCode
		set @vcbody = ''This is a request from ClientWise Application to Activate Vendor. <br/>
					 Request has been submitted by '' + @vcRequestorNameAndEmail + '' on '' 
					  + FORMAT(SYSDATETIME(), ''MM/dd/yy hh:mm tt'') + ''. <br/>
					  Please Activate Vendor Code :'' + @vcVendorCode + '', Vendor Name '' 
					  + @vcVendorName + ''.<br/><br/>
					  Thank you<br/>
					  ClientWise Admin<br/>''
					  
		

		DECLARE @systemuserid int
		SET @systemuserid = NULL
		SELECT @systemuserid = Id FROM CWI_User WHERE Names = ''System''
		IF @systemuserid IS NULL
		begin 
			SET @systemuserid = @inCreatedBy
		end

		insert into CWI_Comment
		(
		ObjectLookupId,
		ObjectId,
		Comment,
		CreatedOn,
		CreatedBy,
		ModifiedOn,
		ModifiedBy
		)
		values
		(
			203, --Vendor General
			@inVendorID,
			''Request for Vendor Activation by '' + @vcRequestorDomainLoginName,
			getdate(),
			@systemuserid,
			getdate(),
			@systemuserid
		)
			
			--Send Email
			EXEC msdb.dbo.sp_send_dbmail 
													@profile_name=@vcprofilename, 
													@recipients = @vcEmailAddress,
													--@copy_recipients= '''',
													--@blind_copy_recipients = '''',
													@subject = @vcemailSubject, 
													@body = @vcbody,
													@body_format = ''HTML''	 


	END TRY
	BEGIN CATCH	
	IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;

END

' 
END
GO


