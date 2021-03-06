/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientSearchDetails]    Script Date: 4/7/2014 8:15:08 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientSearchDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientSearchDetails]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetClientSearchDetails]    Script Date: 4/7/2014 8:15:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientSearchDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: [prc_CWI_GetClientSearchDetails]
* Purpose : This PROC would be called TO get Client Search
* Invoked from : Client.aspx
* CREATED: Mohankumar Sundaram
* CREATED ON : 03 Mar 2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  

exec dbo.prc_CWI_GetClientSearchDetails @ClientCode='''',@ClientName='''',@DivisionCode=''ALTC'',@DivisionName=''ALTC-AS'',@ClientStatus=''All'', @UserId = 3

**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetClientSearchDetails] 
	@ClientCode varchar(max),	
	@ClientName varchar(max),
	@DivisionCode varchar(max),
	@DivisionName varchar(max),
	@ClientStatus varchar(max),
	@UserId	int = 0
	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @tblClient TABLE
	(
		ClientId int,
		ParentId int
	)
	
	IF ISNULL(@UserId,0) <> 0
	BEGIN
		INSERT INTO @tblClient
		SELECT 
			C.Id,
			C.ParentID
		FROM 
			dbo.CWI_Client AS C
			INNER JOIN dbo.fnc_GetClientsForUser(@UserId, ''A'') UC
				ON UC.ClientId = C.ID
	END
	ELSE
	BEGIN
		INSERT INTO @tblClient
		SELECT 
			D.Id,
			D.ParentID
		
		FROM CWI_Client C
		INNER JOIN CWI_Client D
			ON D.ParentID = C.Id
		INNER JOIN 	dbo.Lookup LSC
			ON  C.ClientStatusLookupID = LSC.ID
		INNER JOIN 	dbo.Lookup LSD
			ON  D.ClientStatusLookupID = LSD.ID
		INNER JOIN 	dbo.Lookup LHC
			ON  C.HierarchyTypeLookupID = LHC.ID
		INNER JOIN 	dbo.Lookup LHD
			ON  D.HierarchyTypeLookupID = LHD.ID
		WHERE
			C.ClientCode like ''%'' + @ClientCode + ''%''
			AND C.ClientName like ''%'' + @ClientName + ''%''
			AND D.ClientCode like ''%'' + @DivisionCode + ''%''
			AND D.ClientName like ''%'' + @DivisionName + ''%''
			AND  LSC.LookupName= CASE WHEN @ClientStatus = ''All'' THEN LSC.LookupName ELSE @ClientStatus END
			AND  LSD.LookupName = CASE WHEN @ClientStatus = ''Active'' OR @ClientStatus = ''InActive''  
									THEN @ClientStatus ELSE LSD.LookupName  END
	END

	INSERT INTO @tblClient
	select distinct t.ParentID, NULL from @tblClient t

	SELECT 
				C.Id as ClientID,			
				C.ClientCode,
				C.ClientName,
				A.StateName +''/''+A.City  as ClientAddress,
				L1.ID as ClientStatusLookup,
				L1.LookupName as ClientStatus,
				L2.ID as ClientHierarchyType,
				ISNULL( C.ParentID,0) as ParentId,
				L2.LookupName,			
				C.LastStatusModifiedBy,
				C.LastStatusModifiedOn,
				C.CreatedBy,
				C.CreatedOn,
				ISNULL( convert(varchar(20),C.LastInvoicedDate,101) , '''') as LastDateInvoiced,
				ISNULL(BudgetForecast,0) as	BudgetForecast, 
				ISNULL(BudgetAvailable,0) as BudgetTotalValue,
				ISNULL(BudgetUsed,0) as BudgetUsedValue,	
				ISNULL(BudgetCommitted,0) as BudgetCommitted		
			
		FROM (SELECT distinct* FROM @tblClient) t
			INNER JOIN 
				dbo.CWI_Client AS C
				ON C.Id  =t.ClientId
			
				INNER JOIN

					dbo.Lookup L1
				ON 
					C.ClientStatusLookupID = L1.ID
				INNER JOIN 
					dbo.Lookup L2
				ON 
					C.HierarchyTypeLookupID = L2.ID
				INNER JOIN 
					dbo.vw_CWI_Address A
				ON
					C.AddressID = A.ID
				LEFT OUTER JOIN vw_CWI_ClientSummaryBudget B ON B.ClientID = C.Id AND B.[HierarchyId] = C.HierarchyTypeLookupID


	SET NOCOUNT OFF;

END	




	


' 
END
GO


