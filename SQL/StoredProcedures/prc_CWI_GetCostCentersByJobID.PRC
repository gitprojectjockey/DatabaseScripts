/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCostCentersByJobID]    Script Date: 5/5/2014 5:02:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCostCentersByJobID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCostCentersByJobID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCostCentersByJobID]    Script Date: 5/5/2014 5:02:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCostCentersByJobID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*********************************************************************************************  
* PROCEDURE: prc_CWI_GetCostCentersByJobID
* Purpose : This PROC would be called TO get Cost Center Information for the JobId passed)
* Invoked from : Jobs.aspx
* CREATED: Saravanan m
* CREATED ON : 15Apr2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetCostCentersByJobID @inJobID=114
**********************************************************************/ 

CREATE PROCEDURE [dbo].[prc_CWI_GetCostCentersByJobID]    
    @inJobID bigint
	
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY

	DECLARE @inDivisionId int

	SELECT @inDivisionId = DivisionId FROM CWI_Job WHERE Id =@inJobId
	DECLARE @tblCostCenter TABLE
	(
		CCid int,
		Hierarchy int,
		CostCenterName varchar(255),
		CostCenterNumber varchar(50),
		BusinessUnit varchar(50),
		IsDeleted bit
	)

	INSERT INTO @tblCostCenter
	SELECT * FROM
		(
			SELECT 
				CC.ID as CostCenterID,
				2 as Hierarchy,
				CC.CostCenterName CostCenterName,
				CC.CostCenterNumber as CostCenterNumber,
				CC.BusinessUnit as BusinessUnit,
				CC.IsDeleted

			FROM dbo.CWI_Client AS C (NOLOCK)
				INNER JOIN dbo.CWI_CostCenter as CC (NOLOCK)
													ON C.ID = CC.ClientID
			WHERE CC.ClientID = @inDivisionId
			union --display parent''''s cost center too
			SELECT 
				CC.ID as CostCenterID,
				1 as Hierarchy,
				CC.CostCenterName CostCenterName,
				CC.CostCenterNumber as CostCenterNumber,
				CC.BusinessUnit as BusinessUnit,
				CC.IsDeleted

			FROM dbo.CWI_Client AS C (NOLOCK)
				INNER JOIN dbo.CWI_CostCenter as CC (NOLOCK)
						ON C.ID = CC.ClientID
			
			WHERE CC.ClientID =(Select ParentID from CWI_Client (NOLOCK) where id =@inDivisionId)
							
		) t
		ORDER BY Hierarchy

		

		SELECT * FROM
		(
		SELECT
			CJ.CostCenterID  JobCostCenterID,
			CC.IsDeleted,
			CC.CCId as CostCenterID,
			ISNULL(CJ.AllocationPercentage,0) AllocationPercentage,
			CC.CostCenterName as CostCenterName,
			CC.CostCenterNumber as CostCenterNumber,
			CC.BusinessUnit as BusinessUnit
		FROM CWI_JobCostcenter CJ (NOLOCK)
			RIGHT OUTER JOIN  @tblCostCenter AS CC
				ON CC.CCid=CJ.CostCenterID
				AND CJ.JobID = @inJobID
				) x
		WHERE 
			NOT (JobCostCenterID IS NULL AND IsDeleted = 1) order by ISNULL(AllocationPercentage,0) desc
		
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
	SET NOCOUNT OFF
END
	
' 
END
GO
