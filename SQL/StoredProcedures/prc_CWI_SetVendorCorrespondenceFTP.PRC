/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorCorrespondenceFTP]    Script Date: 9/18/2013 7:50:14 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorCorrespondenceFTP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorCorrespondenceFTP]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorCorrespondenceFTP]    Script Date: 9/18/2013 7:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorCorrespondenceFTP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorCorrespondenceFTP
* Purpose : This PROC would be called to Add or Modify the contact FTP Details
* Invoked from :Vendor.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_SetVendorCorrespondenceFTP] 
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_SetVendorCorrespondenceFTP]
	@ID INT OUT,
	@Server varchar(400),
	@Port INT,
	@UserName varchar(300),
	@Password varchar(300),
	@VendorCorrespondenceID int,
	@Author int
AS
BEGIN
declare @count int=0;
BEGIN TRY
set @count=(select COUNT(*) from CWI_VendorCorrespondenceFTP where VendorCorrespondenceID=@VendorCorrespondenceID);
IF( @ID=0 AND @count=0)
BEGIN
	INSERT INTO [dbo].[CWI_VendorCorrespondenceFTP]
			   ([Server]
			   ,[Port]
			   ,[UserName]
			   ,[Password]
			   ,[VendorCorrespondenceID]
			   ,[CreatedBy]
			   ,[CreatedOn]
			   ,[ModifiedBy]
			   ,[ModifiedOn])
	 VALUES
				(@Server,
				@Port,
				@UserName,
				@Password,
				@VendorCorrespondenceID,
				@Author,
				GETDATE(),
				@Author,
				GETDATE());
				SET @ID=SCOPE_IDENTITY();
END
ELSE
BEGIN
declare @UpdateId int=0;
Set @UpdateId= (select Id from CWI_VendorCorrespondenceFTP where VendorCorrespondenceID=@VendorCorrespondenceID);
	UPDATE [dbo].[CWI_VendorCorrespondenceFTP]
	SET
		[Server]=@Server
		,[Port]=@Port
		,[UserName]=@UserName
		,[Password]=@Password					   
		,[ModifiedBy]=@Author
		,[ModifiedOn]=GETDATE() WHERE ID=@UpdateId;
		SET @ID=@UpdateId;
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
