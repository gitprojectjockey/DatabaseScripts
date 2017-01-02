IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_AddDocumentDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_AddDocumentDetail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_AddDocumentDetail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_AddDocumentDetail  
* Purpose : This PROC would be called to Add the document detail based on Category 
* Invoked from : ManageSupportingDoc.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

            

**********************************************************************  
Execution example :
**********************************************************************  
Declare  @RowCount int
exec [prc_CWI_AddDocumentDetail] @Title=''Manage Sevice1'', @Summary=''testdnvnbd  dsabmhbjdmbd'', @DocTypeId=4,@ObjectId=2, @ObjectLookupId=1, @Version=2.0,@Author=8,@IsShared=true,@FilePath=''c:\test'',@RowCount= @RowCount output
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_AddDocumentDetail] 
				(
				@Title VARCHAR(MAX),
				@Summary VARCHAR(MAX),
				@DocCategoryId int,
				@ObjectId bigint,
				@ObjectLookupID INT,
				@Version decimal,
				@Author INT,
				@IsShared BIT,
				@FilePath Varchar(400),
				@DocId int = 0 output)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN

	  INSERT INTO [dbo].[CWI_SupportingDocument]
			   (
				[Title]
			   ,[DocCategoryId]
			   ,[ObjectID]
			   ,ObjectLookupID
			   ,[Summary]
			   ,[Version]
			   ,[CreatedOn]
			   ,[CreatedBy]  
			   ,[ModifiedBy] 
			   ,[ModifiedOn]       
			   ,[IsShared]
			   ,[FilePath])
		 VALUES
			   (
				@Title,
				@DocCategoryId,
				@ObjectId,
				@ObjectLookupID,
				@Summary,
				@Version,
				GETDATE(),
				@Author,
				@Author,
				GETDATE(),
				@IsShared,
				@FilePath
			   )
	END
	SET @DocId = SCOPE_IDENTITY()

END
'
END
GO
