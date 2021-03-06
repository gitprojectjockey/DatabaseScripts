/****** Object:  StoredProcedure [dbo].[prc_Citi_SetRequestRawData]    Script Date: 7/7/2014 2:41:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Citi_SetRequestRawData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_Citi_SetRequestRawData]
GO
/****** Object:  StoredProcedure [dbo].[prc_Citi_SetRequestRawData]    Script Date: 7/7/2014 2:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_Citi_SetRequestRawData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************    
* PROCEDURE: prc_Citi_SetRequestRawData
* Purpose : This PROC would be invoked from Citi console apps 
                    
* CREATED:  Ajay Thacker on 15may2012
* MODIFICATION HISTORY    
* DATE  AUTHOR   DESCRIPTION    
**********************************************************************    
    
grant execute on  to  


    select * from CITI_RawResponseData
    
**********************************************************************    
**********************************************************************/    
    
CREATE PROCEDURE [dbo].[prc_Citi_SetRequestRawData]  
@intRAWRequestDataID bigint,
@vcRAWXMLFilePath varchar(max)

AS     

update dbo.CITI_RawRequestData
SET XMLFilePath = @vcRAWXMLFilePath,
	ModifiedBy = ''prc_Citi_SetRequestRawData'',
	ModifiedOn = getdate()
where ID = @intRAWRequestDataID

update dbo.CITI_CommunicationRequestResponse
set 
	RequestDateTime = getdate()
where RawRequestDataID = @intRawRequestDataID

  


' 
END
GO
