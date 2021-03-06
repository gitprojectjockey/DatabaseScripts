/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileBenefit]    Script Date: 9/12/2013 2:39:38 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientProfileBenefit')
DROP PROCEDURE [dbo].[prc_CWI_SetClientProfileBenefit]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientProfileBenefit]    Script Date: 9/12/2013 9:07:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientProfileJobOverview 
* Purpose : This PROC would be called TO INSERT OR UPDATE the client profile company description
* Invoked from : Profile_CompanyDescription.aspx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientProfileJobOverview 14174,'looking for drivers','1,3','4,5',7
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_SetClientProfileBenefit]	
	@inClientId int,
	@vcBenefit varchar(max)=NULL,
	@vcRecruitingEmailAddress varchar(100)=NULL,	
	@vcPhoneNumber varchar(50)=NULL, 
	@vcExtension varchar(10)=NULL,
	@vcEmailToSendMail varchar(100)=NULL,
	@vcCompanyWebsiteURL1 varchar(100)=NULL,
	@vcCompanyWebsiteURL2 varchar(100)=NULL,
	@vcApplicationPageURL1 varchar(100)=NULL,
	@vcApplicationPageURL2 varchar(100)=NULL,
	@inUserId int,
	@inRowCount int OUTPUT  
AS
BEGIN	
	BEGIN TRY		
			
			IF NOT EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfile] WHERE ClientID=@inClientId)
			BEGIN									
				INSERT INTO [dbo].[CWI_ClientProfile] 
				([ClientID],[RecruitingEmailAddress],[PhoneNumber],[Extension],[EmailToSendMail],
				[CompanyWebsiteURL1],[CompanyWebsiteURL2],[ApplicationPageURL1],[ApplicationPageURL2],
				[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				VALUES
				(@inClientId,@vcRecruitingEmailAddress,@vcPhoneNumber,@vcExtension,@vcEmailToSendMail,
				@vcCompanyWebsiteURL1,@vcCompanyWebsiteURL2,@vcApplicationPageURL1,@vcApplicationPageURL2,
				GETDATE(),@inUserId,GETDATE(),@inUserId)
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
			END
			ELSE
			BEGIN
				UPDATE [dbo].[CWI_ClientProfile]
				SET [RecruitingEmailAddress]=@vcRecruitingEmailAddress,[PhoneNumber]=@vcPhoneNumber,
				[Extension]=@vcExtension,[EmailToSendMail]=@vcEmailToSendMail,
				[CompanyWebsiteURL1]=@vcCompanyWebsiteURL1,[CompanyWebsiteURL2]=@vcCompanyWebsiteURL2,
				[ApplicationPageURL1]=@vcApplicationPageURL1,[ApplicationPageURL2]=@vcApplicationPageURL2,
				[ModifiedBy]=@inUserId,[ModifiedOn]=GETDATE()
				WHERE [ClientID]=@inClientId
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
			END																
			
			IF @vcBenefit IS NOT NULL
			BEGIN
				IF EXISTS(SELECT ClientID FROM [dbo].[CWI_ClientProfileBenefit] WHERE ClientID=@inClientId)
				BEGIN
					DELETE FROM [dbo].[CWI_ClientProfileBenefit] WHERE [ClientID]=@inClientId					
				END							
				INSERT INTO [dbo].[CWI_ClientProfileBenefit]
				([ClientID],[BenefitID],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])					
				SELECT @inClientId,Items,
				GETDATE(),@inUserId,GETDATE(),@inUserId  FROM dbo.fnc_SplitCSVIntoTableUsingCTE(@vcBenefit,',')	
				SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)
			END
					
					
		
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END
	

	
GO
