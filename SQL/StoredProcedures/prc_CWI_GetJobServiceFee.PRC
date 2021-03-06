/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobServiceFee]    Script Date: 6/13/2014 6:14:19 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobServiceFee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobServiceFee]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobServiceFee]    Script Date: 6/13/2014 6:14:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobServiceFee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetJobServiceFee  
* Purpose : This PROC would be called TO get the job service details 
* Invoked from : JobService.aspx
* CREATED: MohanKumar Sundaram 16MAY14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetJobServiceFee 4,NULL
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetJobServiceFee]
    @JobId bigint = NULL,
	@JobServiceId bigint = NULL

AS
   	IF @JobServiceId IS NOT NULL
	BEGIN
		SELECT 
			JS.Id,
			Js.ServiceId,
			S.ServiceCode [Service],
			S.ServiceName [ServiceName],
			S.ServiceDescription [ServiceDesc],
			Js.ServiceDescription,
			Js.ServiceFee,
			Js.IsComplimentary,
			ISNULL(LGL.LookupName,'''') GLAccount, 
			Js.GLAccountLookupId,
			LS.LookupName [Status],
			Js.StatusLookupId,
			UC.Names CreatedBy,
			JS.CreatedOn,
			UM.Names ModifiedBy,
			JS.ModifiedOn,
			CS.LastUsedOn,
			JS.IsDeleted
		FROM CWI_JobService JS
		INNER JOIN 	CWI_Job J
			ON J.Id = JS.JobId
		INNER JOIN 	Lookup LS
			ON LS.Id = JS.StatusLookupId
		INNER JOIN 	CWI_User UC
			ON UC.Id = JS.CreatedBy
		INNER JOIN 	CWI_User UM
			ON UM.Id = JS.ModifiedBy
		LEFT OUTER JOIN 	Lookup LGL
			ON LGL.Id = JS.GLAccountLookupId
		LEFT OUTER JOIN CWI_Service S
			ON S.Id = JS.ServiceId
		LEFT OUTER JOIN CWI_ClientService CS
			ON CS.ServiceID = JS.ServiceId
				AND CS.ClientID = J.DivisionId
		WHERE
			JS.Id = @JobServiceId
			AND Js.IsDeleted = 0
	END

	ELSE IF @JobId IS NOT NULL
	BEGIN
		SELECT 
			JS.Id,
			Js.ServiceId,
			S.ServiceCode [Service],
			S.ServiceDescription [ServiceDesc],
			S.ServiceName [ServiceName],
			Js.ServiceDescription,
			Js.ServiceFee,
			Js.IsComplimentary,
			ISNULL(LGL.LookupName,'''') GLAccount, 
			Js.GLAccountLookupId,
			LS.LookupName [Status],
			Js.StatusLookupId,
			UC.Names CreatedBy,
			JS.CreatedOn,
			UM.Names ModifiedBy,
			JS.ModifiedOn,
			CS.LastUsedOn,
			JS.IsDeleted
		FROM CWI_JobService JS
		INNER JOIN 	CWI_Job J
			ON J.Id = JS.JobId
		INNER JOIN 	Lookup LS
			ON LS.Id = JS.StatusLookupId
		INNER JOIN 	CWI_User UC
			ON UC.Id = JS.CreatedBy
		INNER JOIN 	CWI_User UM
			ON UM.Id = JS.ModifiedBy
		LEFT OUTER JOIN 	Lookup LGL
			ON LGL.Id = JS.GLAccountLookupId
		LEFT OUTER JOIN CWI_Service S
			ON S.Id = JS.ServiceId
		LEFT OUTER JOIN CWI_ClientService CS
			ON CS.ServiceID = JS.ServiceId
				AND CS.ClientID = J.DivisionId
		WHERE
			JS.JobId = @JobId
			AND Js.IsDeleted = 0
	END







' 
END
GO
