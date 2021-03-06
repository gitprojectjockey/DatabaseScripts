/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobCostCenter]    Script Date: 5/29/2014 2:31:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobCostCenter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetJobCostCenter]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetJobCostCenter]    Script Date: 5/29/2014 2:31:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetJobCostCenter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/****************************************************************************************
* PROCEDURE: prc_CWI_SetJobCostCenter
* Purpose : This Proc will be called to insert/update the Job Cost Center details
* Invoked from : Jobs.aspx
* CREATED: Saravanan Mahalingam 

* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
**********************************************************************  

**********************************************************************  
Execution example :CWI_JobCostCenter 
**********************************************************************  
exec prc_CWI_SetJobCostCenter 1675, 3,
	''<DocumentElement><CostDetails><CostCenterId>37</CostCenterId><AllocationPercentage>100</AllocationPercentage></CostDetails></DocumentElement>''
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetJobCostCenter]
	
	@JobId Int,	
	@Author	int,
	@CostDetails XML	
AS


BEGIN TRANSACTION
	BEGIN TRY
	DECLARE @AuthorName varchar(1000)
	DECLARE @dt varchar(50);
	SET @dt  =FORMAT( getdate(), ''MM/dd/yyyy hh:mm tt'');
	SELECT @AuthorName = Names FROM CWI_User WHERE Id = @Author
		DECLARE @tblCostDetails TABLE
			(CostCenterId int, Percentage decimal)
		
		INSERT INTO @tblCostDetails
				(
				CostCenterId,
				Percentage
				)
		SELECT 
			COLX.value(''(./CostCenterId)[1]'',''int'') ccId,
			COALESCE(NULLIF(COLX.value(''(./AllocationPercentage)[1]'',''varchar(max)''),''''),NULL) APer
		FROM @CostDetails.nodes(''DocumentElement/CostDetails'') AS TABX(COLX);

		DECLARE @delimiter CHAR(1) = CHAR(225);
		
	DECLARE @tblJob TABLE
(
       comment varchar(max)
)
			select * from @tblCostDetails
	UPDATE CWI_JOBCOSTCENTER
		SET
			AllocationPercentage=T.Percentage
			OUTPUT
			CASE WHEN INSERTED.AllocationPercentage<>DELETED.AllocationPercentage THEN ''''+CC.CostCenterName+ '' - Allocation percentage modified from ''+convert(varchar,DELETED.AllocationPercentage)+ '' to '' +convert(varchar,INSERTED.AllocationPercentage)+@delimiter  ELSE '''' end 
			INTO @tblJob 
		FROM 
			CWI_JOBCOSTCENTER JCC
		INNER JOIN 
			CWI_CostCenter CC ON CC.ID=JCC.CostCenterID
		INNER JOIN		
			@tblCostDetails T ON JCC.CostCenterId=T.CostCenterId and JCC.JobId=@JobId

				DECLARE @updHistory varchar(max),@ActionVal varchar(max);
				--SELECT @updHistory = comment from @tblJob
				SET @updHistory=(SELECT SUBSTRING((SELECT '','' + comment FROM @tblJob FOR XML PATH('''')), 2,200000))	

				DECLARE @tblAction TABLE
				(
					   ObjLookupId INt,
					   ObjectId INT,
					   ActionLookupId INT,
					   ActionVal Varchar(max)
	   
				)
		INSERT INTO @tblAction SELECT  205,@JobId,10007,Items FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@updHistory,@delimiter) WHERE LTRIM(RTRIM(items)) <> '''';
			UPDATE @tblAction SET ActionVal= REPLACE( ActionVal,'','','''')---this line added for removing all leading & trailing commas---
		
		INSERT INTO CWI_Action Select TA.ObjLookupId,TA.ObjectId,TA.ActionLookupId,TA.ActionVal+ '' by '' + @AuthorName + '' on '' + @dt,TA.ActionVal,@Author,GETDATE() from @tblAction TA where TA.ActionVal <>'''';

		INSERT INTO	CWI_JOBCOSTCENTER
			([JobID]
           ,[CostCenterID]
           ,[AllocationPercentage]
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
		SELECT 
			@JobId,
			T.CostCenterId,
			T.Percentage,
			@Author,
			GETDATE(),
			@Author,
			GETDATE()
		FROM
			@tblCostDetails T
		LEFT OUTER JOIN CWI_JOBCOSTCENTER JCC
		ON JCC.CostCenterId=T.CostCenterId and JCC.JobId=@JobId WHERE JCC.ID IS NULL;
		
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW

		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;

		RETURN


		


' 
END
GO
