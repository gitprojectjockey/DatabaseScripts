/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediabuyFinalAdcopies]    Script Date: 5/22/2014 7:11:20 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediabuyFinalAdcopies]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobMediabuyFinalAdcopies]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobMediabuyFinalAdcopies]    Script Date: 5/22/2014 7:11:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobMediabuyFinalAdcopies]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobMediabuyFinalAdcopies 
* Purpose : This PROC would be called to retrieve the media vendor details for the list of vendors
* Invoked from : CreativeAdCopy.aspx
* CREATED: Mohankumar Sundaram 21MAY14

* MODIFICATION HISTORY  

* DATE      AUTHOR          DESCRIPTION              



**********************************************************************  

Execution example :

********************************************************************** 

exec prc_CWI_GetJobMediabuyFinalAdcopies 154

**********************************************************************/ 

  

CREATE PROCEDURE [dbo].[prc_CWI_GetJobMediabuyFinalAdcopies]
	@inJobId bigint
AS

BEGIN

	BEGIN TRY

		SELECT 
			B.ID AS JobMediaBuyId, 
			V.Id as VendorId,
			V.VendorCode as VendorCode,
			V.VendorName as VendorName,
			B.[MMRPO] AS MMRPO,
			B.[StatusId],
			L.[LookupName] AS StatusName,
			B.FinalAdCopyFileName
		FROM [dbo].[CWI_JobMediaBuy] AS B
			INNER JOIN CWI_Vendor AS V ON V.Id=B.VendorId
			INNER JOIN [dbo].[Lookup] AS L ON L.Id=B.[StatusId]
			INNER JOIN CWI_User AS U ON B.[ModifiedBy]=U.Id
		WHERE 
			B.JobId=@inJobId 
			AND (IsRemoved=0 OR IsRemoved IS NULL)
			AND IsCancelled = 0
			AND DNR = 0
	END TRY
	BEGIN CATCH	

		EXEC prc_CWI_AppRaiseError;

		THROW;   		

	END CATCH



END

	

' 
END
GO


