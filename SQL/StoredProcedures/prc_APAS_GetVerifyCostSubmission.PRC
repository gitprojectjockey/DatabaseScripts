/****** Object:  StoredProcedure [dbo].[prc_APAS_GetVerifyCostSubmission]    Script Date: 8/19/2014 3:15:24 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetVerifyCostSubmission]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_APAS_GetVerifyCostSubmission]
GO

/****** Object:  StoredProcedure [dbo].[prc_APAS_GetVerifyCostSubmission]    Script Date: 8/19/2014 3:15:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_APAS_GetVerifyCostSubmission]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_APAS_GetVerifyCostSubmission  
* Purpose : This PROC would be called TO 
* Invoked from : PaperCostWizard.aspx
* CREATED: MohanKumar Sundaram 31JUL14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_APAS_GetVerifyCostSubmission @MMRPO = 277, @VendorCode = ''DNWCO''
  
**********************************************************************/ 
  
CREATE proc [dbo].[prc_APAS_GetVerifyCostSubmission]
  @MMRPO bigint, 
  @VendorCode varchar(50)
as
BEGIN TRY
	declare @publication varchar(50)
	declare @isInvoiced bit = NULL
	declare @mmr bigint= NULL
	declare @isCancelled bit
	declare @outMsg as varchar(1000)
	declare @outResponse int = 0

	set @outMsg=''''


	select 
		@mmr=MMRPO,
		@Publication =ltrim(rtrim(V.VendorCode)),
		@isInvoiced=CASE WHEN JMB.StatusId IN (20102, 20103, 20104) /*Selected,Generated,Cancelled*/ THEN 0 ELSE 1 END,
		@isCancelled=IsCancelled 
	from CWI_JobMediaBuy JMB
	INNER JOIN CWI_Vendor V
		ON JMB.VendorId = V.Id
	 where 
	  MMRPO=@MMRPO
	if @mmr is null
		begin
			set @outMsg = ''The MMRPO number is invalid.''
			set @outResponse = 1
		end
	else if @Publication<>@VendorCode
		begin
			set @outMsg = ''The MMRPO Number '' + CAST(@MMRPO AS varchar(50)) + '' is not associated with publication . You are not authorized to update or view this cost. Please review the MMRPO Number and ensure you have not entered it in error.<BR/>If you have not entered in error, please contact Multimedia Advertising.'' 
			set @outResponse = 2
		end
	else if @isCancelled = 1
		begin
			set @outMsg= ''The MMRPO has been cancelled. Please call MMR for any clarifications.''
			set @outResponse = 4
		
		end
	else if @isInvoiced = 1
		begin
			set @outMsg= ''The MMRPO has been invoiced. Please call MMR for any clarifications.''
			set @outResponse = 3
		end

	select  @outResponse  as Response , @outMsg as ResponseMessage

END TRY
BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
END CATCH

' 
END
GO


