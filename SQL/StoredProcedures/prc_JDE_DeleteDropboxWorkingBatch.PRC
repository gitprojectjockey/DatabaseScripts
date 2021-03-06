IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_JDE_DeleteDropboxWorkingBatch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_JDE_DeleteDropboxWorkingBatch]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


/*******************************************************************

* PROCEDURE: prc_JDE_DeleteDropboxWorkingBatch
* Purpose : This PROC is called from JDEdwards.JDEDropboxExport.aspx.cs page
			It would delete all records from JDE_DropboxWorkingBatch Table
			
* CREATED:	Ajay Thacker 27mar2009
* MODIFICATION HISTORY
* DATE		AUTHOR			DESCRIPTION
**********************************************************************

**********************************************************************


 Copyright ACS, Inc.
**********************************************************************/

create proc [dbo].[prc_JDE_DeleteDropboxWorkingBatch]
	
as
BEGIN 

DECLARE 
	
	 
	 --Variables used in catch block of Error handling. 
	 @vcProcName varchar(30),  
	 @vcErrorText varchar(255),  
	 @intErrorNum int,  
	 @vcSeverity varchar(255),  
	 @vcState varchar(255),  
	 @intErrorline int,  
	 @intExtendedErrorNum int,  
	 @vcExtendedErrorText varchar(Max)
	 
		 
		 
BEGIN TRY  
	SET NOCOUNT ON;
	
	delete from jde_dropboxworkingbatch
	

END TRY  
    
BEGIN CATCH

 PRINT 'error'
	  SELECT   
	  @vcProcName = 'prc_JDE_DeleteDropboxWorkingBatch',  
	  @intErrorNum = ERROR_NUMBER(),  
	  @vcSeverity = ERROR_SEVERITY(),  
	  @vcState = ERROR_STATE(),  
	  @intErrorline = ERROR_LINE(),  
	  @intExtendedErrorNum = 1001,  
	  @vcErrorText = ERROR_MESSAGE(),  
	  @vcExtendedErrorText = 'Error: prc_JDE_DeleteDropboxWorkingBatch failed. ' 

 
	  EXEC prc_JDE_AppRaiseError  
		  @vcProcName,  
		  @intErrorNum,  
		  @vcErrorText,  
		  @vcSeverity,   
		  @vcState,  
		  @intErrorline,  
		  'N', 'Y',  
		  @intExtendedErrorNum,  
		  @vcExtendedErrorText  
END CATCH;  
END


GO
GRANT EXECUTE ON [prc_JDE_DeleteDropboxWorkingBatch] TO [ESPAdministration]
GO
