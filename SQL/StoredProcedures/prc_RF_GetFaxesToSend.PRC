/****** Object:  StoredProcedure [dbo].[prc_RF_GetFaxesToSend]    Script Date: 10/7/2014 6:20:42 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_RF_GetFaxesToSend]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_RF_GetFaxesToSend]
GO

/****** Object:  StoredProcedure [dbo].[prc_RF_GetFaxesToSend]    Script Date: 10/7/2014 6:20:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_RF_GetFaxesToSend]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/*******************************************************************************
Author: Ajay Thacker
Date: 31Mar2010
Description: This proc would be called from C#.net Console Application RFInterOp
			 It would get the records from tblfaxserver where faxstatus = ''Send''
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  06OCT14	Mohankumar		New table are referred            

exec prc_RF_GetFaxesToSend
--
update tblfaxserver set faxstatus = ''Send'' 
		where imageid = 929323

update tblfaximage set faxnumber = 3039173749
		where imageid = 929323

update tblfaximage set faxnumber = 3032940424
		where imageid = 929323

update tblfaximage set faxnumber = 3032198984
		where imageid = 929323
update tblfaximage set location = ''\\NIKE\MMR\Images\18276A.fmr''
where imageid = 929284

select DISTINCT FAXRESPONSE from tblfaxserver where imageid = 928708

select  * from tblfaxserver where imageid = 929284
select  * from tblfaximage where imageid = 929284

select distinct FaxResponse from tblfaxserver
*******************************************************************************/

CREATE  Procedure [dbo].[prc_RF_GetFaxesToSend]
as
Select S.Id FaxID,
	   S.CorrespondenceDeliveryId ImageID,
	   S.FaxStatus,
	   isnull(P.VendorName,''MULTI PUBS'') as PaperName,
	   CD.FilePath + CD.[File] as ImagePath,
	   CD.Fax FaxNumber
From
	CWI_FaxServer S
	inner join CWI_CorrespondenceDelivery CD
		on S.CorrespondenceDeliveryId = CD.Id
	inner join CWI_Correspondence C
		on C.Id = CD.CorrespondenceId
	left join CWI_Vendor P
		on P.Id = C.VendorId
where
	 S.FaxStatus in (''Send'')

' 
END
GO


