/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientService]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientService' )
 DROP PROCEDURE [dbo].[prc_CWI_SetClientService]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientService]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
/*******************************************************************  
* PROCEDURE: prc_CWI_SetClientService
* Purpose : This PROC would be called TO Insert / Update Service Fee
				
* Invoked from : Client_Accounting.ascx  (from Client Accounting Tab)
* CREATED: Ajay Thacker
* CREATED ON : 3Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
declare @p2 xml
set @p2=convert(xml,N'<DocumentElement><ClientService><ClientServiceID>0</ClientServiceID><ServiceID>1</ServiceID><ServiceName>LeadFlex</ServiceName><ServiceDefaultFee>400.000</ServiceDefaultFee><ClientServiceFee>200</ClientServiceFee></ClientService><Cli

entService><ClientServiceID>0</ClientServiceID><ServiceID>2</ServiceID><ServiceName>Lead Flex Lite</ServiceName><ServiceDefaultFee>200.000</ServiceDefaultFee><ClientServiceFee>Default</ClientServiceFee></ClientService><ClientService><ClientServiceID>0</Cl

ientServiceID><ServiceID>3</ServiceID><ServiceName>Web Site Creation</ServiceName><ServiceDefaultFee>500.000</ServiceDefaultFee><ClientServiceFee>Default</ClientServiceFee></ClientService><ClientService><ClientServiceID>0</ClientServiceID><ServiceID>4</Se

rviceID><ServiceName>Creative Services</ServiceName><ServiceDefaultFee>350.000</ServiceDefaultFee><ClientServiceFee>Default</ClientServiceFee></ClientService><ClientService><ClientServiceID>0</ClientServiceID><ServiceID>5</ServiceID><ServiceName>Digital A

d Network</ServiceName><ServiceDefaultFee>500.000</ServiceDefaultFee><ClientServiceFee>Default</ClientServiceFee></ClientService></DocumentElement>')
exec dbo.prc_CWI_SetClientService @inClientID=13034,@xmlService=@p2,@inCreatedBy=13


**********************************************************************/ 
--select * from cwi_clientservice where clientid = 13034
  
CREATE PROCEDURE [dbo].[prc_CWI_SetClientService]    
    @inClientID int,
	@xmlService xml,
	@inCreatedBy int
	

AS
BEGIN


	BEGIN TRANSACTION Trans1
	BEGIN TRY
		DECLARE @tblClientService TABLE
		(
			ClientServiceID int,
			ServiceID int,
			ServiceFeeChar varchar(100),
			ServiceFee numeric(18,3)
		)	
	
		Insert into @tblClientService
		(
		ClientServiceID,ServiceID,ServiceFeeChar
		)
		select 
			COLX.value('(./ClientServiceID)[1]','int'),
			COLX.value('(./ServiceID)[1]','int'),
			case when COLX.value('(./ClientServiceFee)[1]','varchar(50)') = 'Default' then ISNULL(CAST(s.ServiceDefaultFee AS VARCHAR(50)), 'Default')
			else COLX.value('(./ClientServiceFee)[1]','varchar(50)')  end
		from 
		@xmlService.nodes('DocumentElement/ClientService') AS TABX(COLX)
			inner join CWI_Service S
			on COLX.value('(./ServiceID)[1]','int') = S.ID

			select * from @tblClientService
			UPDATE
				@tblClientService
			SET
				ServiceFee = CASE WHEN ISNUMERIC(ServiceFeeChar)=1 THEN CAST(ServiceFeeChar AS numeric(18,3)) ELSE NULL END


		--We Insert records in CWI_ClientService that do not exist
		Insert into CWI_ClientService
		(
		ClientID,ServiceID,ServiceFee,CreatedBy,CreatedOn
		)
		Select @inClientID,
					tmp.ServiceID,
					tmp.ServiceFee,
					@inCreatedBy,
					getdate()
		from @tblClientService tmp
		left join CWI_ClientService cs
			on tmp.ClientServiceID = cs.ID
		where CS.ID is null
			and tmp.ClientServiceID = 0 --for new, we pass id as 0 from front end

		--We Update records in CWI_ClientService table that already exist
		Update CWI_ClientService
			Set ServiceFee = tmp.ServiceFee,
					ModifiedBy = @inCreatedBy,
					ModifiedOn = getdate()
		from @tblClientService tmp
		inner join CWI_ClientService cs
		on tmp.ClientServiceID = cs.ID


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
	


GO