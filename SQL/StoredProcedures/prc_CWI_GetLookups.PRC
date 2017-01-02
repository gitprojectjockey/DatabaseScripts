

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLookups]    Script Date: 4/25/2013 2:44:26 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetLookups')
DROP PROCEDURE [dbo].[prc_CWI_GetLookups]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetLookups]    Script Date: 4/25/2013 2:44:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_GetLookup 
* Purpose : This PROC would be called TO get all the lookup values based on LookupTypeIds passed as comma seperated values
* Invoked from : Multiple Pages
* CREATED: MohanKumar Sundaram
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetLookups @LooupTypeIds = '1,2,3,4,5'

**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetLookups]    
	@LooupTypeIds	varchar(4000)
AS
BEGIN

	BEGIN TRY
		
		DECLARE @tbl TABLE(Item int)
		--comma seperated lookup type ids are inserted into the temp table
		INSERT INTO @tbl
		select cast(Items as int) FROM dbo.fnc_utl_Split(@LooupTypeIds,',')
		WHERE Items <> ''
		

		SELECT Id,[LookupName], L.LookupTypeId FROM [dbo].[Lookup] L
		INNER JOIN @tbl t ON L.LookupTypeId = t.Item
		WHERE  [IsActive]=1	
		ORDER BY LookupTypeId,SortOrder,LookupName
		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	
GO

