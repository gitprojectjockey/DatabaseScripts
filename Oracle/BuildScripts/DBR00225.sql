accept CONN             prompt 'Enter DB Connection for RIC: '
accept SCHEMAOWNER      prompt 'Enter RIC Schema owner [RICOWNER]: ' DEFAULT 'RICOWNER'

set echo on
set feedback on
spool &&CONN._dbr00225.log


prompt Enter password RIC Schema Owner ....
conn &&SCHEMAOWNER@&&CONN 

--Tables
@..\Tables\RIC_Transaction_TBL.sql
show errors
--Packages
@..\PkgSpec\RIC_TEISTripData_PKG.sql
show errors
@..\PkgBody\RIC_TEISTripData_PKG.sql
show errors
set echo off
set feedback off

PROMPT *
PROMPT *
PROMPT *
PROMPT *
PROMPT *
PROMPT *********** End of Masterscript *********
PROMPT ** Applied to: &&SCHEMAOWNER.@&&CONN     
PROMPT *****************************************

spool off

