/****** Object:  StoredProcedure [dbo].[prc_CWI_GetImportColumnMappingByFile]    Script Date: 8/26/2014 9:51:18 AM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetImportColumnMappingByFile' )
 DROP PROCEDURE [dbo].[prc_CWI_GetImportColumnMappingByFile]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetImportColumnMappingByFile]    Script Date: 8/26/2014 9:51:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************************************************************************************  
* PROCEDURE: prc_CWI_GetImportColumnMappingByFile
* Purpose : This PROC would be called to get the import column mapping for a 
*			particular integration file, whose ID is passed as parameter
* Invoked from : <TBD>
* CREATED: Lino Garcia
* MODIFICATION HISTORY  
* DATE            AUTHOR          DESCRIPTION              
  08/19/2014
**********************************************************************  
Execution example :
********************************************************************** 
exec prc_CWI_GetImportColumnMappingByFile 1
********************************************************************************************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetImportColumnMappingByFile]
@FileID INTEGER
AS
BEGIN

	BEGIN TRY
		SELECT 
			icm.[ImportColumnName],
			icm.[ColumnID],
			ic.[ColumnName],
			ic.[ColumnDisplayName],
			ic.[ColumnDataType],
			idt.[ColumnDataTypeName],
			ic.[Required],
			ic.[Length],
			ic.[Format]
		FROM [dbo].[CWI_ImportColumnMap] icm 
		INNER JOIN [dbo].[CWI_ImportColumn] ic 
			ON ic.[ColumnID] = icm.[ColumnID]
		INNER JOIN [dbo].[CWI_ImportDataType] idt 
			ON idt.[ColumnDataTypeID] = ic.[ColumnDataType]
		WHERE icm.[FileID] = @FileID
		order by icm.[Order]
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END

GO


