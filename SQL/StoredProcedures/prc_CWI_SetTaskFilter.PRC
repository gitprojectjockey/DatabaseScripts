/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTaskFilter]    Script Date: 10/10/2014 9:22:08 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTaskFilter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetTaskFilter]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetTaskFilter]    Script Date: 10/10/2014 9:22:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetTaskFilter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  
* PROCEDURE: prc_CWI_SetTaskFilter 
* Purpose : This PROC would be called TO save the filter values for the task grid column in dashboard page
* Invoked from : MyTasks.ascx
* CREATED: Vijesh  10/8/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetTaskFilter
	''Open'', 
	''Status'', 
	7,
	@vcMessage varchar(max)=NULL output
  
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_SetTaskFilter]
@FilterDetails XML, 
@Author INT,
@inRowCount int output
As	

	BEGIN TRANSACTION TRAN1
		BEGIN TRY
			
			IF EXISTS (SELECT CreatedBy FROM CWI_TaskFilter WHERE CreatedBy=@Author)
			BEGIN
				UPDATE CWI_TaskFilter SET 
				IsRemoved=1,
				ModifiedBy=@Author,
				ModifiedOn=GETDATE()
				WHERE 
				CreatedBy=@Author
			END

			INSERT INTO CWI_TaskFilter
			(FilterColumn,FilterValue,IsRemoved,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
			
			SELECT 
				COLX.value(''(./FilterColumn)[1]'',''VARCHAR(200)'') FilterColumn,
				COLX.value(''(./FilterValue)[1]'',''VARCHAR(250)'') FilterValue,
				0,
				@Author,
				GETDATE(),
				@Author,
				GETDATE()
			FROM @FilterDetails.nodes(''DocumentElement/TaskFilterDataTable'') AS TABX(COLX)	

			SET @inRowCount = (SELECT @@ROWCOUNT AS rowaffected)


		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION TRAN1;
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION TRAN1;
		



' 
END
GO
