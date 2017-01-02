/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobApprovalEmail]    Script Date: 7/23/2014 2:11:43 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobApprovalEmail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetJobApprovalEmail]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetJobApprovalEmail]    Script Date: 7/23/2014 2:11:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetJobApprovalEmail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************************************
* PROCEDURE: prc_CWI_GetJobApprovalEmail
* Purpose : This PROC would be called TO get the details required to email for ad approval
* Invoked from : JobApprovalContact.aspx
* CREATED: Mohankumar	22APR14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  23JUL14	Mohankumar		Adcopy is returned          

*************************************************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_GetJobApprovalEmail] @jobId = 1
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_GetJobApprovalEmail]
	@jobId bigint
AS
	DECLARE @InvoiceDate Datetime = NULL,
	@TemplateFile varchar(max)='''',
	@TemplateSubject varchar(max)='''',
	@AdCopy varchar(max) = ''''

	SELECT @InvoiceDate = InvoiceDate from CWI_Job
	WHERE Id = @jobId

	SELECT @AdCopy = AdCopyFileName from CWI_JobNewspaper
	WHERE JobId = @jobId

	SELECT TOP 1 @TemplateFile = TemplateFile, 
			@TemplateSubject = TemplateSubject
	FROM CWI_EmailTemplate  
	WHERE Id= 17 AND  IsActive = 1

	SELECT @InvoiceDate InvoiceDate,  @TemplateFile  TemplateFile, 
			@TemplateSubject  TemplateSubject,ISNULL(@AdCopy,'''') AdCopy

' 
END
GO


