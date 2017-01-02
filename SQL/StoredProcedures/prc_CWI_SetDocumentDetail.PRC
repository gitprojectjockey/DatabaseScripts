IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetDocumentDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetDocumentDetail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetDocumentDetail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetDocumentDetail  
* Purpose : This PROC would be called to Update the document detail based on Category 
* Invoked from : ManageSupportingDoc.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 
Declare  @RowCount int
exec [prc_CWI_SetDocumentDetail] @ID=1, @Title=''Manage Sevice1'', @DocCategoryId= ''2'',''dsdsdsd'',@ObjectId=2,
 @ObjectLookupID=1, @Version=1.0,@Author=7,@IsShared=true,@FilePath=''c:\test'', @RowCount= @RowCount output
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetDocumentDetail] 
	(
				@ID INT,
				@Title VARCHAR(MAX),
				@DocCategoryId int = null,
				@Summary Varchar(MAX),
				@ObjectID INT,
				@ObjectLookupID INT,
				@Version decimal,
				@Author int,
				@IsShared BIT,
				@FilePath Varchar(400),
				@RowCount int output
	)
AS
BEGIN
SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY
	--Update History Table
		/*INSERT INTO [dbo].[CWI_History_SupportingDocument]
			   (
				[Title],
				DocCategoryId,
			    [Summary],
				[Version]
			   ,[ModifiedOn]
			   ,[ModifiedBy]
			   ,[FilePath]
			   ,SupportingDocumentId)			
			   
			Select 
				Title,
				DocCategoryId,
				Summary,
				[Version]
				,ModifiedOn
				,ModifiedBy
				,FilePath
				,Id
			 from
				 [dbo].[CWI_SupportingDocument]	
			where id=@ID;
			*/
		UPDATE [dbo].[CWI_SupportingDocument]
		   SET 
				[Title] = @Title,
				DocCategoryId = @DocCategoryId,
				[ObjectLookupID] = @ObjectLookupID,
				[ObjectID]=@ObjectID,				
				[Version] = @Version, 	
				[Summary]=@Summary,			
				[ModifiedOn] = GETDATE(),
				[ModifiedBy] = @Author,
				[IsShared] = @IsShared, 
				[FilePath] = @FilePath
			WHERE 
				[Id]=@ID;
			 
	

	  SET @RowCount = (SELECT @@ROWCOUNT as RowAffected)
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError; 
		THROW;
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;
END





' 
END
GO
