/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorsByVendorCode]    Script Date: 7/2/2013 3:04:47 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorsByVendorCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorsByVendorCode]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorsByVendorCode]    Script Date: 7/2/2013 3:04:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorsByVendorCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorsByVendorCode 
* Purpose : This PROC would be called TO get all the active and pending vendors 
* Invoked from : Client_Budget.ascx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetVendorsByVendorCode @VendorCode=''ABEMD,ABESD'',@ClassificationId=401
  
**********************************************************************/ 
  
CREATE PROC [dbo].[prc_CWI_GetVendorsByVendorCode]
@VendorCode varchar(MAX),
@ClassificationId int
AS
BEGIN
	
	select 
		V.Id as VendorId
		--VendorCode +'' - ''+ VendorName as VendorName , 
		
		--ISNULL(CWI_BudgetMonthClassVendor.BudgetForecast,0.00) as BudgetForecast,
		--ISNULL(CWI_BudgetMonthClassVendor.BudgetUsed,0.00) as BudgetUsed
		--A.StateName,
		--A.City,
		--A.StateName+''/''+A.City PhysicalAddress,
		--ISNULL(LKT.LookupName,'''') VendorType,
		--ISNULL(LKT.LookupName,'''') VendorGroup,
		--LKC.LookupName Classification, 
		--LKS.LookupName [Status], 
		--U.Names,
		--V.CreatedOn,
		--LastUsedOn
	from CWI_Vendor V (NOLOCK)
	INNER JOIN vw_CWI_Address A (NOLOCK) ON A.ID = V.AddressId_Physical
	INNER JOIN Lookup LKS (NOLOCK) ON LKS.ID = V.StatusLookupId
	INNER JOIN Lookup LKC (NOLOCK) ON LKC.ID = V.ClassificationLookupId
	INNER JOIN CWI_User U (NOLOCK) ON u.Id = V.CreatedBy
	LEFT OUTER JOIN Lookup LKT (NOLOCK) ON LKS.ID = V.VendorTypeLookUpId
	LEFT OUTER JOIN Lookup LKG (NOLOCK) ON LKG.ID = V.VendorGroupLookupId
	Left OUTER join CWI_BudgetMonthClassVendor ON CWI_BudgetMonthClassVendor.VendorID=V.Id
	WHERE  V.IsDeleted = 0 And LKC.id=@ClassificationId And VendorCode IN(Select Items From fnc_SplitCommaSeparatedValuesIntoTable(@VendorCode,'','')) 
	ORDER BY
		LKC.LookupName, --Classification
		A.StateName,A.City
	
		
END



' 
END
GO
