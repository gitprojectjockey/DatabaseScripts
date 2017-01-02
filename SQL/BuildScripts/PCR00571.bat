echo off
rem --------------------------------------------------------------------

rem ------------------------------------------------------------------------
rem parameters 
rem   %1 server name    (ex DEV05\DEV)
rem   %2 database name  (ex FB_DHLCOD)
rem ------------------------------------------------------------------------
rem  Ensure you are in the "Buildscripts" 
rem  directory when executing this batch file
rem ------------------------------------------------------------------------

If '%1'=='' goto ParameterError
If '%2'=='' goto ParameterError



echo Linked Server
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\LinkedServers.SQL >> services.log




echo Executing Service Table Scripts
SQLCMD -E -S %1 -d %2 -i ..\Schema\LookupType.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\Lookup.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_User.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_UserSkin.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Activity.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Application.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Comment.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ErrorLog.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Service.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_DocCategory.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_SupportingDocument.TBL >> services.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_Comment.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_SupportingDocument.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Menu.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_MenuActivity.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Group.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_GroupActivity.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_GroupDocument.TBL >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_GroupFeature.TBL >> services.log


ECHO Executing Alter scripts

SQLCMD -E -S %1 -d %2 -i ..\AlterScripts\AlterTable_SupportingDocument.PRC>> alter.Log


echo Executing Vendor Table Scripts


SQLCMD -E -S %1 -d %2 -i ..\Schema\Country.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\State.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Address.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_Address.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Vendor.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClassificationProduct.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_VendorContact.TBL >> vendor.log


SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_VendorCorrespondence.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_VendorProduct.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_VendorCorrespondenceDelivery.TBL >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_VendorCorrespondenceFTP.TBL >> vendor.log


echo Executing %~n0


echo Executing Client Table Scripts

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Client.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientActivation.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientClassification.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientCompanyProfile.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientContact.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientService.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientTeamRelationship.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientTearSheet.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CostCenter.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_Client.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_ClientClassification.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_ClientService.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_ClientTeamRelationship.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_CostCenter.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CompanyConfig.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientContactPortal.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_PortalUserPassword.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_PasswordRule.TBL >> client.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientBudget.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_DivisionBudget.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_BudgetMonth.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_BudgetMonthClassification.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_BudgetMonthClassVendor.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_BudgetMonthService.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_ClientBudget.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_DivisionBudget.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_BudgetMonth.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_BudgetMonthClassification.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_BudgetMonthClassVendor.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_BudgetMonthService.TBL >> client.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_VendorContactClient.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_VendorContactClient.TBL >> client.log


SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_Benefit.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_DriverPay.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_HiringPosition.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_LicenseClassType.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_Location.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_PayCycle.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_PayExperience.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_Route.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_SubLocation.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_TrailerExperience.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_TypeFreightHauled.TBL >> client.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfile.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileBenefit.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileBenefitDetail.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfilePayInformation.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileDriverPayDetail.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileHiringLocation.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileHiringPosition.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileHiringPositionDetail.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfilePayCycleDetails.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfilePayExperience.TBL >> client.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileRoute.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileTrailerExperience.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileTypeFreightHauled.TBL >> client.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_SiteTypes.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileDigitalMedia.TBL >> client.log


SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CPL_ResponseChannel.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientProfileResponseTranslation.TBL >> client.log



SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientInvoice.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientInvoiceDelivery.TBL >> client.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_BudgetMonthInvoice.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_BudgetMonthInvoice.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_BudgetMonthInvoiceVendor.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_BudgetMonthInvoiceVendor.TBL >> client.log


SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClientAssociation.TBL >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CorrespondenceDeliveryMethod.TBL >> client.log


echo Executing Invoice Table Scripts

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Invoice.TBL >> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_InvoiceDelivery.TBL >> Invoice.log




echo Executing Task Table Scripts

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskTemplate.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Task.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskNote.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskAssignee.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskAttachment.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_Task.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_TaskAssignee.TBL >> task.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskField.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskTemplateField.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskTemplateData.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_TaskTemplateData.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskTemplateClassification.TBL >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_TaskAttachment.TBL >> task.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskFilter.TBL >> task.log


echo Executing Job Table Scripts

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_MarketingPlan.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Action.TBL >> job.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Job.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobNewspaper.TBL >> job.log



SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_AdCopy.TBL >> job.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobMediaBuy.TBL >> job.log


SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobAssignee.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_JobAssignee.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_UserGroup.TBL >> job.log


SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClassificationJob_LifeCycle.TBL >> LifeCycle.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ClassificationJob_LifeCycle_Status.TBL >> LifeCycle.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\Zipcode.TBL >> job.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_History_JobMediaBuy.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobMediaBuyRundateTemplateData.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobApproval.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobApprovalContact.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Alert.TBL >> job.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobTemplateClassification.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobSummaryTemplateData.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobCostCenter.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_JobService.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\Holiday.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TemplateAssignee.TBL >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_TaskTemplateDuration.TBL >> job.log



echo Executing Correspondence Table Scripts

SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_EmailTemplate.TBL >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Correspondence.TBL >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CorrespondenceDelivery.TBL >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_FaxServer.TBL >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CorrespodenceDeliveryEmailTemplate.TBL >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_CorrespondenceEmailAttachment.TBL >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_MediabuyCancelConfirmation.TBL >> Correspondence.log

echo Executing Virtual Card Table Scripts

SQLCMD -E -S %1 -d %2 -i ..\Schema\CITI_AuthsReportWorking.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\Citi_AuthsTracking.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CITI_Lookup.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CITI_RawRequestData.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CITI_RawResponseData.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CITI_RawResponseData_Settlement_Mapping.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CITI_VCNAuthsWorking.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\COMDATACommunicationControl.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\COMDATATemplate.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\ComDataReconcile.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\COMDATATransaction.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_VCMediaBuy.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\SettlementComDataCCNumber.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CITI_CommunicationRequestResponse.TBL >> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_PayMethodMessage.TBL >> VirtualCard.log

echo Executing CallSource Table Scripts


SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ResponseCallSourceCustomer.TBL >> ResponseCallSource.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ResponseCallSourceCallDetails.TBL >> ResponseCallSource.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ResponseCallSourceCall.TBL >> ResponseCallSource.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ResponseCallSourceAddress.TBL >> ResponseCallSource.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ResponseCallSourceEmployee.TBL >> ResponseCallSource.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ResponseCallSourceSalesRep.TBL >> ResponseCallSource.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ResponseCallSourceStatus.TBL >> ResponseCallSource.log







ECHO Types

SQLCMD -E -S %1 -d %2 -i ..\Types\tt_Profile_PayExperience.TYPE >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Types\tt_Profile_TrailerExperience.TYPE >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Types\tt_CWI_JobActionAttribute.TYPE >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Types\tt_CWI_MediabuyActionAttribute.TYPE >> job.log


echo Executing Service and Vendor View Scripts

SQLCMD -E -S %1 -d %2 -i ..\Views\VW_Menus.VW >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_Address.VW >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_ProductLookup.VW >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorAddress.VW >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorContactType.VW >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorCorrespondenceDeliveryMethod.VW >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorCorrespondenceType.VW >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorStatusLookup.VW >> vendor.log




echo Executing Client View Scripts

SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_Address.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_Classification.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_ClientContactType.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_ClientSummaryBudget.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_ClientTeamRelation.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_ProductLookup.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorAddress.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorContactType.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorCorrespondenceDeliveryMethod.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorCorrespondenceType.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_VendorStatusLookup.VW >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Views\vw_CWI_ClientDivisionInvoice.VW >> invoice.log



echo Executing Functions Scripts
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_utl_Split.UDF >> services.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetMonths.UDF >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_SplitCommaSeparatedValuesIntoTable.UDF >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_FormatRemovalPhone.UDF >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetMonthFirstDay.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetMonthLastDay.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_EncryptPortalPassword.UDF >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_DecryptPortalPassword.UDF >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetMonth.UDF >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetClientsForUser.UDF >> client.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_SplitCSVIntoTableUsingCTE.UDF >> client.log


SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetDivisionMonthlyBudget.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetDivisionMonthlyClassBudget.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetDivisionMonthlyServiceBudget.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetLastInvoiceGeneratedDate.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetCommaSeperatedLookup.UDF >> task.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_AvgActualCost.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CalculateInvoice.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\MilesToKilometers.UDF >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\KilometersToMiles.UDF >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\CalculateDistance.UDF >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\CalculateBoundary.UDF >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetSingleLookupName.UDF >> vendor.log  
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetJobSummaryTemplateData.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetJobSummaryTemplateDataWithLookup.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetIncompleteJobLifecycle.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetJobClassCount.UDF >> job.log  
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetDivisionMarkupInvoice.UDF >> job.log  


SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetNextMMRPO.UDF >> Correspondence.log
 
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetJobMediabuyRundates.UDF >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetJobMediabuyRundatesScalar.UDF >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetJobAdType.UDF >> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetInvoiceValidation.UDF >> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetMaxDateTime.UDF >> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetJobMediaBuyAttributes.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetClientsForUser.UDF >> job.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_IsCorrespondenceReadyToCreate.UDF >> virtualcard.log

SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetUsersForClient.UDF >> apas.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_GetUsersEmailsForClientScalar.UDF >> apas.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_CWI_GetVendorCorresDeliveryScalar.UDF >> Correspondence.log


echo Executing Service Stored Procedures Scripts

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_AddDocumentDetail.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_AppRaiseError.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_CheckComment.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteDocumentDetails.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteService.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetActivitiesByPage.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetComments.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDocsByGroups.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDocumentCategories.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDocumentDetailsByCategory.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDocumentHistory.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDocumentTypesByGroupId.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetGroup.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetGroupFeaturesByGroup.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetGroupID.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetGroups.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetLookup.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetLookups.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetLookupTypes.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMenuActivitiesByGroupId.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMenusByGroups.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetService.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetServices.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetUsers.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetUserSkin.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetComment.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetDocumentDetail.PRC >> services.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetGroupDocument.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetGroupFeatureActivity.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetService.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetUser.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetUserSkin.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetUser.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDocumentDetailsByObject.PRC >> services.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetDocumentFile.PRC >> services.log 
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetSupportingDocument.PRC >> services.log 
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetDocumentsClientShare.PRC >> services.log 
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_InsertSupportingDocument.PRC >> services.log 
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetLookupById.PRC >> services.log 
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetUserGroups.PRC >> services.log 
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetDocumentTags.PRC >> services.log 
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetGroupsByUser.PRC >> services.log 
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetUserProfile.PRC >> services.log 


echo Executing Vendor Stored Procedures Scripts


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorProducts.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteVendor.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteVendorContact.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteVendorProduct.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClassificationProducts.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCountryList.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetStateListByCountryID.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendor.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorCities.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorContact.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorContactByEmail.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorContacts.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorCorrespondence.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorEmails.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorInfoByClassificationId.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorLookupGeneralSearch.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorLookupPredefinedSearch.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorProductCount.PRC >> vendor.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorProfile.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendors.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorsByVendorCode.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetAddress.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendor.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorContact.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorCorrespondence.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorProduct.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorProfile.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorStatus.PRC >> vendor.log


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetDeliveryEMail.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorEmails.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorCorrespondence.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorCorrespondenceFTP.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorFAX.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorCorrespondence.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorCorrespondenceFTP.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCustomers.PRC >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorCorrespondenceID.PRC  >> vendor.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteVendorContactClient.PRC  >> vendor.log



echo Executing %~n0

echo Executing Client Stored Procedures Scripts


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_AddClientBudget.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_AddDivisionBudget.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteClientContact.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteCostCenter.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetMonthClassificationByMonthId.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClassificationIdsByVendorCode.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientAccountingInfo.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientAddress.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientBudget.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientClassificationMarkup.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientContact.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientContactByEmail.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientContacts.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientCWPortalAccess.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientDivision.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientEmails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientEntityUser.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientGeneralInfo.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfile.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientSearchChildDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientSearchDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientSearchParentDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientService.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientStatus.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientTeamRelationships.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientTearSheet.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCostCentersByClientID.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDashboardBudgetClientDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDashboardBudgetDivisionDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDashboardClientActivity.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDashboardClientBudget.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDashboardClientDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDashboardDivisionDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionAllBudgetDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionBudgetDetailByDivisionID.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionBudgetDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetIsClientTeamRelationship.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTeamClientEntities.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTeamClientReleationships.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTeamClientReleationshipsByUser.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorInfoByClassificationId.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorsByVendorCode.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCompanyConfigAddress.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetPasswordRules.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetPasswordHistoryValidation.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetPortalRelationships.PRC >> client.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientAccountingInfo.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientActivation.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientActivationRequest.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientBudget.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientClassificationMarkup.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientContact.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientCWPortalAccess.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetPortalAccess.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientGeneralInfo.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfile.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientService.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientSettings.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientTeamRelationship.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientTearSheet.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCostCenter.PRC >> client.log


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetTeamClientRelationship.PRC >> client.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientHierarchy.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetActivitiesByPageWithoutIcons.PRC >> client.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_AddClientBudget.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_AddDivisionBudget.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetClassVendorIdsByBudgetMonthClassificationID.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetMonthClassificationByMonthId.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetMonthClassificationIDsByMonthId.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetMonthClassificationsByMonthId.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetMonthServiceIDsByMonthId.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClassificationIdsByVendorCode.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientBudget.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionAllBudgetDetails.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionBudgetDetailByDivisionID.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionBudgetDetails.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorInfoByClassificationId.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorsByVendorCode.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClassificationMonthBudgetHistory.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorBudgetHistory.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetMonthBudgetHistory.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClassificationMonthBudget.PRC>> Client.Log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientBudget.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCopyBudgetMonthDetailsByMonthID.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCopyClassificationDetailsByClassificationID.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCopyMonthClassVendorDetailsByClassVendorID.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCopyMonthServiceBudgetByMonthServiceID.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetDivisionBudget.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetMonthBudget.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetServiceBudget.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorBudget.PRC>> Client.Log


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetMonthInvoiceByMonthId.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetInvoiceMonthBudget.PRC>> Client.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetInvoiceVendorByClassificationId.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetMonthInvoiceIdByBudgetMonthClassID.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetBudgetMonthInvoiceVendor.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetMonthInvoiceBudget.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgetMonthInvoiceVendorID.PRC >> client.log  






SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileBenefit.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileBenefitSetting.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileCompanyDescription.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileCompanyDetails.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileDriverPay.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileHiringLocationDetails.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileHiringPosition.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileJobOverview.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileLead.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileLocation.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileOwnerOperatorSoloTeam.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfilePayCycleDetail.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfilePayExperience.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileRoute.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileTrailerExperience.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileTypeFreightHauled.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileUnloadPayDetail.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLBenefitSetting.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLDriverPay.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLHiringPosition.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLLicenseClassType.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLPayCycle.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLRoute.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLSubLocation.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLTypeFreightHauled.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileBenefit.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileCompanyDescription.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileCompanyDetails.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileHiringLocation.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileHiringLocationDetails.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileJobOverview.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileLead.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfilePayInformation.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileTrailerExperience.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileUnloadPayDetails.prc >> client.log


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorContactClient.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorContactClient.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorContactIDByEmailID.PRC >> client.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientInvoice.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientInvoice.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetAlert.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_BudgetUpdate.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDBClientBudgetDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientActivitySummary.PRC >> client.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileSocialMedia.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileSocialMedia.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetBudgets.prc >> client.log



SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLSiteTypes.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileDigitalMedia.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileDigitalMedia.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileRemoveDigitalMedia.prc >> client.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorporateSearchDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientListforCorporate.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetAssociatedClients.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetAssociatedClientDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetAssociatedClientDetails.PRC >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteAssociatedClient.PRC >> client.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCPLResponseChannel.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCPLResponseChannel.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileResponseTranslation.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientProfileResponseTranslationDetails.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientProfileResponseTranslation.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClientContactPortalProfile.prc >> client.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorrespondenceDeliveryMethod.prc >> client.log



echo Executing Job Stored Procedures Scripts

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClassificationLifeCycleStatus.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobLifeCycleStatus.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetClassificationLifeCycleStatus.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobMediaBuyAttributes.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobMediaBuyStatus.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobCostCenter.PRC>> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetAction.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetAction.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetMarketingPlan.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMarketingPlan.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMarketingPlans.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMarketingPlanBySearch.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteMarketingPlan.PRC >> job.log


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientLookupByUserId.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetPlanClassSummary.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobsByPlanClass.PRC >> job.log


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJob.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobSummaryTemplateData.PRC >> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobNewspaperAdCopy.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobNewspaperAdCopy.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClientImages.PRC >> job.log


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobMediaBuy.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobMediaBuy.PRC >> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobStatus.PRC >> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobAssignee.PRC >> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetUserGroupByUser.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetUserGroups.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetUsersGroups.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobAssignee.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJob.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetUserGroup.PRC >> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetBudgetFromMediaBuy.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobCostInvoiceForMediaBuy.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobDNR.PRC >> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobRemoveMediaBuy.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobSelectVendor.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionJobSummary.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionMarkupClassification.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobCostInvoiceFreeze.PRC >> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetHistoryJobMediaBuy.PRC >> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobMediaBuyRundateTemplateData.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobMediaBuyRundateTemplateData.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobTemplateByTemplateID.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobSummaryTemplateData.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetLastInvoiceDateByDivisionID.PRC >> job.log



SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorsByZipCodes.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorsByCityState.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorZipcodesByPolygon.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVendorsByPoints.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVendorActivationRequest.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_AddVendorFromLookup.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetRunDate.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMMRPO.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobInsertionOrder.PRC>> job.log  
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMarketingPlansByDivision.PRC>> job.log  
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCopyJob.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCopyJobSummaryTemplateData.PRC>> job.log

  

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobApproval.PRC>> job.log  
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobContact.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobApproval.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobApprovalEmail.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCostCentersByJobID.PRC>> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCostCentersByJobID.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobActionAttributes.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobAwaitingInvoiceApproval.PRC>> job.log  
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobAssigneeDetails.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteJobAssignee.PRC>> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobService.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetDivisionServiceFee.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteJobService.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobServiceFee.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetServicesForFee.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobMediaBuyCosts.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskStatusByJob.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetHoliday.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetFinalAdCopy.PRC>> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCreativeAdCopyOnPickupJob.PRC>> job.log




echo Executing Task Stored Procedures Scripts

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskNotes.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTasks.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskAssignee.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTasksBySearch.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetTaskNote.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetTaskAttachment.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetTaskTemplateData.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetTask.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetHistoryTask.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetHistoryTaskAssignee.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskTemplateData.PRC>> task.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskTemplates.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskTemplateByTemplateID.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTasksBySearch.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskTemplateByTaskId.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetClassificationByJobId.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_DeleteTaskAttachment.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskAttachment.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_UpdateTaskAttachment.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetAllJobsByAdvancedSearch.PRC>> task.log


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobTaskTemplates.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetLookupTypes.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskFields.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTemplateClass.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTemplateFieldDetails.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetTemplateFieldTaskJob.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobTemplates.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMyTasks.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskAssigneesEmailing.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobAssigneesEmailing.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetEmailTemplate.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskTemplateDuration.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTemplateAssignee.PRC>> task.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskFilter.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetTaskFilter.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetTaskName.PRC>> task.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetPlanTasks.PRC>> task.log


echo Executing Correspondence Stored Procedures Scripts

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondence.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobMediaBuyCancellation.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobGenerateInsertion.PRC >> job.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceDelivery.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorrespondence.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetFaxServer.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobSummary.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceStatus.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondence.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetWebDelivery.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorrespondenceByAdvancedSearch.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceDeliveryResubmit.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceEmailAttachment.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceDeliveryIndividual.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorrespondenceDeliveryEmails.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceConsolidatedStatus.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceFile.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorrespondenceDelivery.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetAdcopyToProcess.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceResubmit.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetCorrespondenceArchive.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorrespondenceEmailAttachments.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorresDeliveryFile.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorrespodenceFax.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetCorrespondenceDetails.PRC>> Correspondence.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RF_GetFaxesToSend.PRC>> Correspondence.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RF_GetFaxesToUpdateStatus.PRC>> Correspondence.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobMediabuyFinalAdcopies.PRC>> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobFinalAdToSend.PRC>> job.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobSubmissionOrderDetails.PRC>> job.log  
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetJobSubmitChangeOrder.PRC>> job.log



echo Executing Settlement Stored Procedures Scripts

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetSettlement.PRC>> Settlement.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetSettlementBySearch.PRC>> Settlement.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetSettlement.PRC>> Settlement.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetRelatedSettlements.PRC>> Settlement.log


echo Executing Invoice Stored Procedures Scripts

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceByAdvanceSearch.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceByAdvanceSearchForDivison.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetLastInvoiceProcessedDate.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoicePO.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetInvoicePO.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceFile.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceDetailsForReport.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetAuthorizedInvoiceToProcess.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetInvoiceDelivery.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetInvoiceNo.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetInvoiceFile.PRC>> Invoice.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetInvoiceAuthorization.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceValidation.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetJobDetailsForInvoiceValidation.PRC>> Invoice.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetInvoiceDeliveryResend.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceDetailsForResend.PRC>> Invoice.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceFiles.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetGenerateInvoiceDelivery.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceDelivery.PRC>> Invoice.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetInvoiceDeliveryToProcess.PRC>> Invoice.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVCDetail.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CITI_CreateApprovedPurchaseResponse.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_Citi_SetRequestRawData.PRC>> VirtualCard.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_Citi_XMLCreateApprovedPurchaseRequest.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetMediabuyCalculatedInvoice.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVCDetailTransaction.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVCMediabuyStatusCount.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\VCM_GetVirtualCardTransactions.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\VCM_UpdateAPStatus.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVCMediabuyStatusDetails.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVCPaymentMethod.PRC>> VirtualCard.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetVCLimitAndTransCount.PRC>> VirtualCard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetVCLimitAndTransCount.PRC>> VirtualCard.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetFollowUp.PRC>> Virtualcard.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetFollowUp.PRC>> VirtualCard.log

echo Executing APAS Stored Procedures Scripts
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_GetCorrespondenceByEmailId.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_GetCorrespondenceType.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_GetFinalAdcopy.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_GetMMRPODetails.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_GetSubmitCostResults.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_GetVerifyCostSubmission.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_SetCorrespondenceACKStatus.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_SetMediabuyCost.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_APAS_SetCancelConfirmation.PRC>> apas.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RF_SetFaxStatus.PRC>> Correspondence.log

echo Executing Response Call Source Stored Procedures Scripts
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetResponseCallSourceStatus.PRC>> ResponseCallSource.log

echo Executing Trigger Scripts

SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_Task_Insert.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_Task_Update.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_TaskAssinee_Insert.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_TaskAssignee_Update.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_TaskAttachment_Insert.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_TaskAttachment_Update.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_JobMediaBuy_Update.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_COMDATACommunicationControl_Insert.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_COMDATAReconcile_Insert.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_COMDATAReconcile_Update.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_COMDATATransaction_Insert.TRG>> trigger.log
SQLCMD -E -S %1 -d %2 -i ..\Triggers\CWI_TR_COMDATATransaction_Update.TRG>> trigger.log












echo Data Porting Stored Procedures


SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_Data_SetClientDataFromTMIMMRDB.PRC>> dataport.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_Data_SetClientDataToTMIMMRDB.PRC>> dataport.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_Data_SetTeamClientRelationShipDataToTMIMMRDB.PRC>> dataport.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_Data_SetVendorDataFromTMIMMRDB.PRC>> dataport.Log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_Data_SetVendorDataToTMIMMRDB.PRC>> dataport.Log



ECHO User and data
SQLCMD -E -S %1 -d %2 -i ..\User\CWI_AdminUser.SQL>> user.Log
SQLCMD -E -S %1 -d %2 -i ClientwiseAdminUserSetupFirstTime.SQL >> dataport.log

ECHO Executing Data Integration Scripts
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ImportFile.TBL >> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ImportDataType.TBL >> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ImportColumn.TBL >> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ImportColumnMap.TBL >> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_ImportFileHistory.TBL >> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Integration_Twitter.TBL >> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Integration_Facebook.TBL >> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Integration_DigitalLeads.TBL >> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Integration_DigitalResponse.TBL >> dataintegration.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_GetImportColumnMappingByFile.PRC>> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetImportFileHistory.PRC>> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetIntegrationTwitterResponse.PRC>> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetIntegrationFacebookResponse.PRC>> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetIntegrationDigitalLeads.PRC>> dataintegration.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_CWI_SetIntegrationDigitalResponse.PRC>> dataintegration.log

SQLCMD -E -S %1 -d %2 -i ..\Data\Integration_InitialData.sql>> dataintegration.log


ECHO Executing Last script file which requires more time to complete- 
ECHO Loading data in to the table zipcode  
ECHO Please be patient for approximately 2 Hours to load 916788 Records 
SQLCMD -E -S %1 -d %2 -i ..\Schema\ZipCode.DAT >> zip.log

ECHO Completed


goto end


:ParameterError
echo Parameters are incorrect; expecting ServerName and DatabaseName
goto :end

:end

