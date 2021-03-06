/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorLookupPredefinedSearch]    Script Date: 12/20/2013 5:14:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorLookupPredefinedSearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorLookupPredefinedSearch]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorLookupPredefinedSearch]    Script Date: 12/20/2013 5:14:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorLookupPredefinedSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorLookupPredefinedSearch
* Purpose : This PROC would be called TO do predefined vendors search
* Invoked from : VendorLookup.aspx  
* CREATED: MohanKumar SUndaram
* CREATED ON : 29May2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetVendorLookupPredefinedSearch  @option = ''B'', @Classifications = ''401''
@option = "B" - Budgeted Vendors
**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_GetVendorLookupPredefinedSearch]
	@option varchar(2),
	@Classifications varchar(max) = ''''
AS
BEGIN
	DECLARE @dtCutoff date
	SELECT @dtCutoff = dateadd(WEEK,-1*10, cast(getdate() as date))

	DECLARE @tblClassification TABLE
	(ClassId int)


	IF @option = ''B'' AND @Classifications = ''''
	BEGIN
		SELECT 
			V.VendorId,
			VendorCode,
			VendorName ,
			LastUsedOn,
			Circulation,
			Physical_StateName,
			Physical_City
		FROM
		(
		SELECT 
			distinct VendorID
		FROM 
			CWI_BudgetMonth BM
			INNER JOIN CWI_DivisionBudget
				ON	BM.DivisionBudgetID=CWI_DivisionBudget.Id
			Inner Join CWI_BudgetMonthClassification
				ON BM.ID=CWI_BudgetMonthClassification.BudgetMonthID 
			Inner Join CWI_BudgetMonthClassVendor
			ON
				CWI_BudgetMonthClassVendor.BudgetMonthClassificationID=CWI_BudgetMonthClassification.ID
			WHERE 	cast((cast(BM.Year as varchar(10)) + ''-'' + cast(BM.Month as varchar(2)) + ''-01''  ) as date) >= @dtCutoff
		) x
			Inner Join vw_CWI_VendorAddress V
			ON
				V.VendorId=x.VendorID
		ORDER BY VendorCode
	END
	IF @option = ''B'' AND @Classifications <> ''''
	BEGIN
		INSERT INTO @tblClassification
			SELECT CAST(Items as int) FROM dbo.fnc_utl_Split(@Classifications,'','')

		SELECT 
			V.VendorId,
			VendorCode,
			VendorName ,
			LastUsedOn,
			Circulation,
			Physical_StateName,
			Physical_City
		FROM
		(
		SELECT 
			distinct VendorID
		FROM 
			CWI_BudgetMonth BM
			INNER JOIN CWI_DivisionBudget
				ON	BM.DivisionBudgetID=CWI_DivisionBudget.Id
			Inner Join CWI_BudgetMonthClassification
				ON BM.ID=CWI_BudgetMonthClassification.BudgetMonthID 
			Inner Join CWI_BudgetMonthClassVendor
			ON
				CWI_BudgetMonthClassVendor.BudgetMonthClassificationID=CWI_BudgetMonthClassification.ID
			WHERE 	cast((cast(BM.Year as varchar(10)) + ''-'' + cast(BM.Month as varchar(2)) + ''-01''  ) as date) >= @dtCutoff
		) x
			Inner Join vw_CWI_VendorAddress V
			ON
				V.VendorId=x.VendorID AND V.statuslookupid =552 -- Active
				AND V.IsDeleted = 0
			INNER JOIN  @tblClassification C
				ON V.ClassificationLookupId = C.ClassId
		ORDER BY VendorCode
	END
END


' 
END
GO


