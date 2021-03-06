/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediaBuy]    Script Date: 5/14/2014 3:13:15 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediaBuy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobMediaBuy]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediaBuy]    Script Date: 5/14/2014 3:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediaBuy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************  

* PROCEDURE: prc_CWI_GetJobMediaVendor 

* Purpose : This PROC would be called to retrieve the media vendor details for the list of vendors

* Invoked from : JobMediaBuy.aspx

* CREATED: Vijesh Mahi

* MODIFICATION HISTORY  

* DATE      AUTHOR          DESCRIPTION              



**********************************************************************  

Execution example :

********************************************************************** 

exec prc_CWI_GetJobMediaBuy 154

**********************************************************************/ 

  

CREATE PROCEDURE [dbo].[prc_CWI_GetJobMediaBuy]

@inJobId bigint

AS

BEGIN



	BEGIN TRY

		SELECT B.ID AS JobMediaBuyId, V.Id as VendorId,V.VendorCode as VendorCode,V.VendorName as VendorName,

		ISNULL(B.[MMRPO],'''') AS MMRPO,B.[StatusId],ISNULL(B.[ExpectedCost],0) AS [ExpectedCost],

		--CASE WHEN ISNULL(B.[ExpectedCost],0)=0 THEN dbo.fnc_CWI_AvgActualCost(B.VendorId,@inJobId)
		--ELSE B.[ExpectedCost] END AS ExpectedCost,

		--B.[ExpectedCost]= (SELECT dbo.fn_CWI_AvgActualCost(B.VendorId,@inJobId)),

		ISNULL([ExpectedInvoice],0) AS [ExpectedInvoice],ISNULL([ActualCost],0) AS [ActualCost],
		
		
		ISNULL([ActualInvoice],0) AS [ActualInvoice],--B.[ModifiedBy] AS [SelectedBy],

		U.Names as [SelectedBy],ISNULL(B.DNR,'''') AS DNR,

		B.[ModifiedOn] AS [SelectedDate],B.[JobId],ISNULL(B.[IsActualCostFreeze],0) AS [IsActualCostFreeze],

		ISNULL(B.IsActualInvoiceFreeze,0) AS IsActualInvoiceFreeze,ISNULL(B.IsComplimentary,0) AS IsComplimentary,

		L.[LookupName] AS StatusName,ISNULL(B.[IsComplimentaryInvoice],0) AS IsComplimentaryInvoice

		FROM [dbo].[CWI_JobMediaBuy] AS B

		INNER JOIN CWI_Vendor AS V ON V.Id=B.VendorId

		INNER JOIN [dbo].[Lookup] AS L ON L.Id=B.[StatusId]

		INNER JOIN CWI_User AS U ON B.[ModifiedBy]=U.Id

		WHERE B.JobId=@inJobId AND (IsRemoved=0 OR IsRemoved IS NULL)

		ORDER BY VendorName ASC

	END TRY

	BEGIN CATCH	

		EXEC prc_CWI_AppRaiseError;

		THROW;   		

	END CATCH



END

	' 
END
GO
