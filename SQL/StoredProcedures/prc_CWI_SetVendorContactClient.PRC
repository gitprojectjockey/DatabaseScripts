IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorContactClient]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorContactClient]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorContactClient]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorContactClient
* Purpose : This PROC would be called to Add or Modify the customer to contact  
* Invoked from :AssignCustomerToContact.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_SetVendorContactClient] 
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetVendorContactClient] 
	@ID INT OUT,
	@VendorContactId INT,
	@ClientId INT,
	@UserId Int,
	@ErrorMsg varchar(MAX) out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
IF( @ID=0)
BEGIN

IF NOT EXISTS( SELECT * from CWI_VendorContactClient where VendorContactId=@VendorContactId AND ClientId=@ClientId and IsDeleted=0)
BEGIN

 -- Insert statements for procedure here
	INSERT INTO [dbo].[CWI_VendorContactClient]
           ([VendorContactId]
           ,[ClientId]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
			(@VendorContactId
           ,@ClientId	
           ,@UserId
           ,GETDATE()
           ,@UserId
           ,GETDATE());
		   SET @ID=SCOPE_IDENTITY();

END
ELSE	

BEGIN

 SET @ID=0;
					set @ErrorMsg = ''The customer relationship already exists!!!!!''
					return;
				
				

END

  

END
ELSE

BEGIN


INSERT INTO [dbo].[CWI_History_VendorContactClient]
           (
			[VendorContactClientID]
           ,[VendorContactId]
           ,[ClientId]
           ,[IsDeleted]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])	   
		   
	(SELECT ID
           ,[VendorContactId]
           ,[ClientId]
           ,[IsDeleted]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
	FROM
		[CWI_VendorContactClient] WHERE Id=@ID);

 UPDATE [dbo].[CWI_VendorContactClient]
	SET
			[VendorContactId]=@VendorContactId
           ,[ClientId]=@ClientId           
           ,[ModifiedBy]=@UserId
           ,[ModifiedOn]=GETDATE() 
	WHERE Id=@ID
	SET @ID=@ID;

END


   END TRY
   BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
END
' 
END
GO
