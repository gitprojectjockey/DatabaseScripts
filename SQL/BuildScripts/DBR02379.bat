echo off
rem --------------------------------------------------------------------

rem ------------------------------------------------------------------------
rem parameters 
rem   %1 server name    (ex DEV05\DEV)
rem   %2 database name  (ex ClientWise)
rem ------------------------------------------------------------------------
rem  Ensure you are in the "Buildscripts" 
rem  directory when executing this batch file
rem ------------------------------------------------------------------------

If '%1'=='' goto ParameterError
If '%2'=='' goto ParameterError

echo Executing CWClientPortal Table Scripts
SQLCMD -E -S %1 -d %2 -i ..\AlterScripts\AlterTable_CWI_ClientContactPortal.TBL >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\AlterScripts\AlterTable_CWI_Job.TBL >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_Message.TBL >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_MessageAttachment.TBL >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_MessageRecipient.TBL >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_MessageTag.TBL >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\CWI_PortalUserMessageArchive.TBL >> CWClientPortal.log

echo Executing CWClientPortal Function Scripts
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_ClientPortal_GetRecipientNames.UDF >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_ClientPortal_GetRootMessageID.UDF >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\Functions\fnc_ClientPortal_GetUserName.UDF >> CWClientPortal.log

echo Executing CWClientPortal Storedprocedures Scripts
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_ApproveJob.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_ArchiveMessage.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_ChangeUserPassword.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_CheckPasswordHistory.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_CreateMessageAttachment.prc >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_CreateMessageRecipient.prc >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_CreateMessageTag.prc >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_CreateUserMessage.prc >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_DeleteMessageTag.prc >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_ForgotPassword.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetJob.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetMessage.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetMessageAttachment.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetMessageAttachments.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetMessageRecipients.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetMessageTags.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetPasswordRules.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetUserArchiveMessages.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetUserArchives.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetUserInfo.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetUserInfoByEmail.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetUserMessages.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetUserMessagesByTag.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetUserMessageThread.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_GetUserRecentlyUsedTags.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_UnExpireUser.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_UnlockUser.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_UpdateMessageTag.prc >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_UserLogin.PRC >> CWClientPortal.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_ClientPortal_ValidateUserPassword.PRC >> CWClientPortal.log

echo Executing CWClientPortal Lookup data Scripts
SQLCMD -E -S %1 -d %2 -i ..\Data\CWClientPortalLookupData.sql >> CWClientPortal.log


