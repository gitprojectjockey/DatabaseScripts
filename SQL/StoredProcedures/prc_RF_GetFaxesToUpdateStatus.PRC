/****** Object:  StoredProcedure [dbo].[prc_RF_GetFaxesToUpdateStatus]    Script Date: 10/7/2014 6:22:21 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_RF_GetFaxesToUpdateStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_RF_GetFaxesToUpdateStatus]
GO

/****** Object:  StoredProcedure [dbo].[prc_RF_GetFaxesToUpdateStatus]    Script Date: 10/7/2014 6:22:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_RF_GetFaxesToUpdateStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************************
Author: Ajay Thacker
Date: 2Apr2010
Description: This proc would be called from C#.net Console Application RFInterOp
			 It would get the records from tblfaxserver where faxstatus = ''Send''
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  06OCT14	Mohankumar		New tables are referred   
exec prc_RF_GetFaxesToUpdateStatus
--


select top 5 * from tblfaxserver
*******************************************************************************/

create Procedure [dbo].[prc_RF_GetFaxesToUpdateStatus]
as

delete from CWI_FaxServer where timefaxrequested < getdate() - 14 

Select S.Id FaxID,
	   S.CorrespondenceDeliveryId ImageID,
	   S.FaxStatus
	   
	  
From
	CWI_FaxServer S
WHERE S.FaxStatus in (''Sending'',''Pending'',''Failed'',''Error'')
order by Id 



' 
END
GO


