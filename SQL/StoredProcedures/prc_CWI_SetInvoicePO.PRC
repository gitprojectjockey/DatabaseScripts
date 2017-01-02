/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoicePO]    Script Date: 3/15/2014 9:07:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoicePO]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetInvoicePO]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetInvoicePO]    Script Date: 3/15/2014 9:07:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetInvoicePO]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetInvoicePO 
* Purpose : This PROC would be called TO set PO details for job
* Invoked from : ManageInvoice.aspx
* CREATED: MohanKumar Sundaram  03/15/2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetInvoicePO
	@JobId = 6,
	@PO = ''PO12345''
  
**********************************************************************/ 



CREATE PROC [dbo].[prc_CWI_SetInvoicePO]
	@JobId bigint,
	@PO varchar(max)
AS
UPDATE CWI_Job SET PONumber = @PO
WHERE
	Id = @JobId' 
END
GO


