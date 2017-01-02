/****** Object:  StoredProcedure [dbo].[prc_APAS_GetCorrespondenceType]    Script Date: 8/19/2014 3:16:36 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetCorrespondenceType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_GetCorrespondenceType]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_GetCorrespondenceType]    Script Date: 8/19/2014 3:16:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetCorrespondenceType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_APAS_GetCorrespondenceType
* Purpose : This PROC would be called TO get the correspondence type and delivery method of id passed 
* Invoked from : Main.aspx
* CREATED: MohanKumar Sundaram 01AUG14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  

exec prc_APAS_GetCorrespondenceType @id = 1234
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_APAS_GetCorrespondenceType]
    @id bigint
AS
    
BEGIN

	
	SELECT  CorrespondenceTypeLookupId,  CD.DeliveryMethodLookupId FROM CWI_Correspondence C 
	INNER JOIN CWI_CorrespondenceDelivery CD
		ON C.Id = CD.CorrespondenceId 
	 WHERE CD.ID = @Id
END

' 
END
GO


