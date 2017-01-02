/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespodenceFax]    Script Date: 9/17/2014 7:07:43 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespodenceFax]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCorrespodenceFax]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCorrespodenceFax]    Script Date: 9/17/2014 7:07:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCorrespodenceFax]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetCorrespodenceFax  
* Purpose : This PROC would be called TO get the fax numbers related to the correspondence''s vendor  
* Invoked from : Correspondence.aspx
* CREATED: MohanKumar Sundaram 12SEP14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_GetCorrespodenceFax 100
  
**********************************************************************/ 
  
CREATE PROCEDURE [dbo].[prc_CWI_GetCorrespodenceFax]
    @corresId bigint 
AS
	DECLARE @vendorId  bigint, @corresLookupId int
	SELECT @vendorId = VendorId, @corresLookupId = CorrespondenceTypeLookupId FROM CWI_Correspondence
	WHERE Id = @corresId

	exec prc_CWI_GetVendorFAX @vendorId,804/*Fax*/,@corresLookupId' 
END
GO


