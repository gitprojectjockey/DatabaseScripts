/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCostCentersByClientID]    Script Date: 6/19/2013 2:19:07 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_GetCostCentersByClientID' )
 DROP PROCEDURE [dbo].[prc_CWI_GetCostCentersByClientID]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCostCentersByClientID]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************  
* PROCEDURE: prc_CWI_GetCostCentersByClientID
* Purpose : This PROC would be called TO get Cost Center Information for either Client or Division (from Cost Center Tab)
* Invoked from : Client_CostCenter.ascx
* CREATED: Ajay Thacker
* CREATED ON : 29Apr2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec dbo.prc_CWI_GetCostCentersByClientID @inClientID=14504
**********************************************************************/ 
  
  
  

CREATE PROCEDURE [dbo].[prc_CWI_GetCostCentersByClientID]    
    @inClientID int
	
AS
BEGIN
	BEGIN TRY
		SELECT * FROM
		(
			SELECT 
				CC.ID as CostCenterID,
				CC.ClientID as ClientID,
				C.ClientCode,
				C.ClientName,
				C.HierarchyTypeLookupID as ClientHierarchyType,
				L.LookupName HierarchyName,
				isnull(CC.CostCenterName,'') as CostCenterName,
				isnull(CC.CostCenterNumber,'') as CostCenterNumber,
				isnull(CC.BusinessUnit,'') as BusinessUnit,
				u.Names  as CreatedBy,
				CC.CreatedOn,
				case when CostCenterLastUsed is not null then 'NO'
						  else 'YES'
				end as IsRemoveCostCenterAllowed

			FROM dbo.CWI_Client AS C
				INNER JOIN dbo.CWI_CostCenter as CC
												 ON C.ID = CC.ClientID
				inner join CWI_User U
												 ON U.Id = CC.CreatedBy
				inner join Lookup L ON L.Id = C.HierarchyTypeLookupID
			
			WHERE CC.ClientID = @inClientID
							and CC.IsDeleted = 0

			union --display parent's cost center too
			SELECT 
				CC.ID as CostCenterID,
				CC.ClientID as ClientID,
				C.ClientCode,
				C.ClientName,
				C.HierarchyTypeLookupID as ClientHierarchyType,
				L.LookupName HierarchyName,
				isnull(CC.CostCenterName,'') as CostCenterName,
				isnull(CC.CostCenterNumber,'') as CostCenterNumber,
				isnull(CC.BusinessUnit,'') as BusinessUnit,
				U.Names  as CreatedBy,
				CC.CreatedOn,
				case when  CostCenterLastUsed is not null then 'NO'
						  else 'YES'
				end as IsRemoveCostCenterAllowed

			FROM dbo.CWI_Client AS C
				INNER JOIN dbo.CWI_CostCenter as CC
												 ON C.ID = CC.ClientID
				inner join CWI_User U
												 ON U.Id = CC.CreatedBy
				inner join Lookup L ON L.Id = C.HierarchyTypeLookupID
			
			WHERE CC.ClientID =(Select ParentID from CWI_Client where id =@inClientID)
							and CC.IsDeleted = 0
		) t
		ORDER BY ClientHierarchyType
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH

END
	

	
GO
