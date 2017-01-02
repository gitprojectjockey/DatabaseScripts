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

echo Executing RTMC Table Scripts
SQLCMD -E -S %1 -d %2 -i ..\Schema\RTMC_CreateApprovedPurchaseResponse.TBL >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\RTMC_UpdatePurchaseResponse.TBL >> RTMC.log

SQLCMD -E -S %1 -d %2 -i ..\Schema\RTMC_ClearedTransactionDataResponse.TBL >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\RTMC_LastProcessedTransactionData.TBL >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\RTMC_MemoTransactionDataResponse.TBL >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\Schema\RTMC_RejectTransactionDataResponse.TBL >> RTMC.log

echo Executing RTMC Alter Table Scripts
SQLCMD -E -S %1 -d %2 -i ..\AlterScripts\AlterTable_SettlementComDataCCNumber.TBL >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\AlterScripts\AlterTable_COMDATAReconcile.TBL >> RTMC.log

echo Executing RTMC Stored Procedures Scripts
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_GetApprovedPurchaseRequest.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_CreateApprovedPurchaseResponse.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_CreateVirtualCard.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_CreateGhostCard.PRC >> RTMC.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_GetUpdatePurchaseRequest.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_UpdatePurchaseResponse.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_UpdateVirtualCard.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_UpdateVirtualCardError.PRC >> RTMC.log

SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_GetClearedTransactionData.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_GetLastProcessedTransactionData.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_GetMemoTransactionData.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_GetRejectTransactionData.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_GetSettlementCreditCardNumber.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetClearedTransactionDataComplete.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetClearedTransactionDataResponse.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetComDataClearedReconcile.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetComDataMemoTransactions.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetComDataRejectTransactions.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetLastProcessedTransactionData.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetMemoTransactionDataComplete.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetMemoTransactionDataResponse.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetRejectTransactionDataComplete.PRC >> RTMC.log
SQLCMD -E -S %1 -d %2 -i ..\StoredProcedures\prc_RTMC_SetRejectTransactionDataResponse.PRC >> RTMC.log



ECHO Completed

goto end


:ParameterError
echo Parameters are incorrect; expecting ServerName and DatabaseName
goto :end

:end

