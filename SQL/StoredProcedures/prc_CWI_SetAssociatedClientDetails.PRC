/****** Object:  StoredProcedure [dbo].[prc_CWI_SetAssociatedClientDetails]    Script Date: 9/12/2014 1:51:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetAssociatedClientDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetAssociatedClientDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetAssociatedClientDetails]    Script Date: 9/12/2014 1:51:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetAssociatedClientDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_SetAssociatedClientDetails]
* Purpose : This PROC would be called TO save the client corporate relation
* Invoked from : Client.aspx
* CREATED: Vijesh Mahi
* CREATED ON : 4 Sep 2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

********************************************************************** 
exec dbo.prc_CWI_SetAssociatedClientDetails NULL,15674,14183,''2014-09-04'',7

**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetAssociatedClientDetails] 
@inCorporateId int,
@inClientId int,
@dtEffective datetime,
@inUserId int,
@inRowCount int output
AS
BEGIN
	
	BEGIN TRY
		BEGIN TRANSACTION Trans1
		BEGIN TRY
			SET NOCOUNT ON;

			Declare @inAssociationId int=NULL,@vcCorporateName varchar(500)

			select @inAssociationId = Id from [dbo].[CWI_ClientAssociation] 
			where CoporateId=@inCorporateId and ClientId=@inClientId 
			and IsRemoved=0
	
			if @inAssociationId is null
			begin
				insert into [dbo].[CWI_ClientAssociation]
				([CoporateId],[ClientId],[EffectiveDate],[CreatedOn],[CreatedBy],[ModifiedOn],[ModifiedBy])
				values
				(@inCorporateId,@inClientId,@dtEffective,GETDATE(),@inUserId,GETDATE(),@inUserId)
					
				SET @inRowCount =  SCOPE_IDENTITY()
			end
			else
			begin
				update [dbo].[CWI_ClientAssociation]
				set EffectiveDate=@dtEffective,
				[ModifiedOn]=GETDATE(),
				[ModifiedBy]=@inUserId
				where Id=@inAssociationId
				
				SET @inRowCount = (SELECT @@ROWCOUNT)
			end

			SET NOCOUNT OFF;
		END TRY
		BEGIN CATCH	  
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
			EXEC prc_CWI_AppRaiseError;
			THROW;
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;
	END TRY
	BEGIN CATCH	  
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH

END	






	





' 
END
GO
