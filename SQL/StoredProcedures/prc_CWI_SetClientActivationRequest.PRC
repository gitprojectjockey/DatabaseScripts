/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientActivationRequest]    Script Date: 1/7/2014 6:19:26 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientActivationRequest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetClientActivationRequest]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientActivationRequest]    Script Date: 1/7/2014 6:19:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetClientActivationRequest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientActivationRequest
* Purpose : This PROC would be called TO 
				-->insert Client Activation Request into [dbo].[CWI_ClientActivation] table.
				-->It will also insert a new System Generated Comment 
				-->It will also email Activation Request.
* Invoked from : Client_General.ascx  (from Client General Tab)
* CREATED: Ajay Thacker
* CREATED ON : 15 Mar2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
1/7/2013	Mohankumar		Email Addresses are taken from lookup table            

**********************************************************************  
Execution example :
**********************************************************************  
Select * from CWI_ClientActivation
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_SetClientActivationRequest]    
    @inClientID int,
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
				@vcClientCode varchar(5),
				@vcClientName varchar(255)

		select @vcprofilename = dbo.[fnc_CWI_GetSingleLookupName](16)

		SELECT 
			
			@vcRequestorDomainLoginName = Names + '' - '' + Domain + ''\'' + [Login] ,
			@vcRequestorNameAndEmail = [Names] + 
				 (CASE WHEN (ISNULL(Email,'''') = '''') THEN '''' ELSE '' ('' + Email + '')'' END)
			
		from CWI_User
		where ID = @inCreatedBy

		--Mail address is picked from Lookup table..lookuptypeid is 41
		select @vcEmailAddress = dbo.[fnc_CWI_GetSingleLookupName](41)

		IF(ISNULL(@vcEmailAddress,'''') = '''')
		begin
			set @vcEmailAddress = dbo.[fnc_CWI_GetSingleLookupName](43) -- default email address
		end

		SET @vcEmailAddress = REPLACE(@vcEmailAddress,'','','';'')
		
		select @vcClientCode = ClientCode,
				@vcClientName = ClientName
				from CWI_Client
				where ID = @inClientID 
	
		
		set @vcemailSubject = ''ClientWise : Request for Client Activation '' + @vcClientCode
		set @vcbody = ''This is a request from ClientWise Application to Activate Client. <br/>
					 Request has been submitted by '' + @vcRequestorNameAndEmail + '' on '' 
					  + FORMAT(SYSDATETIME(), ''MM/dd/yy hh:mm tt'') + ''. <br/>
					  Please Activate Client Code :'' + @vcClientCode + '', Client Name '' 
					  + @vcClientName + ''.<br/><br/>
					  Thank you<br/>
					  ClientWise Admin<br/>''
					  
		
		Insert into CWI_ClientActivation
		(
		ClientID,
		ActivationRequestedBy
		)
		values
		(
		@inClientID,
		@inCreatedBy
		)

		/******************************division level activation***************************/
		Insert into CWI_ClientActivation(ClientID,ActivationRequestedBy)
		SELECT [ID],@inCreatedBy FROM [dbo].[CWI_Client] WHERE [ParentID]=@inClientID
		/*****************************end******************************/

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
			202, --Client General
			@inClientID,
			''Request for Client Activation by '' + @vcRequestorDomainLoginName,
			getdate(),
			@systemuserid,
			getdate(),
			@systemuserid
		)
		/******************************division level activation***************************/		
		insert into CWI_Comment(ObjectLookupId,ObjectId,Comment,CreatedOn,CreatedBy,ModifiedOn,ModifiedBy)
			SELECT 202,[ID],''Request for Client Activation by '' + @vcRequestorDomainLoginName,
			getdate(),@systemuserid,getdate(),@systemuserid 
			FROM [dbo].[CWI_Client] WHERE [ParentID]=@inClientID			
		/*****************************end******************************/
			
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


