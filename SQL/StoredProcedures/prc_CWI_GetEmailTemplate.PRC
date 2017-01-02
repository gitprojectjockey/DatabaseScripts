/****** Object:  StoredProcedure [dbo].[prc_CWI_GetEmailTemplate]    Script Date: 7/10/2014 6:40:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetEmailTemplate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetEmailTemplate]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetEmailTemplate]    Script Date: 7/10/2014 6:40:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetEmailTemplate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetEmailTemplate

* Purpose : This PROC would be called TO get the email template details for the template id
* Invoked from : Multiple
* CREATED: MohanKumar Sundaram  07JUL2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
DECLARE @p1 varchar(max), @p2 varchar(max)
exec prc_CWI_GetEmailTemplate @TemplateId=23, @TemplateFile = @p1 out,  @TemplateSubject = @p2 out
select @p1, @p2
**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetEmailTemplate]
	@TemplateId int,
	@TemplateFile varchar(max)='''' out,
	@TemplateSubject varchar(max)='''' out

AS
	
	
	SELECT TOP 1 @TemplateFile = TemplateFile, 
				@TemplateSubject = TemplateSubject
	FROM CWI_EmailTemplate  
	WHERE Id= @TemplateId AND  IsActive = 1


' 
END
GO


