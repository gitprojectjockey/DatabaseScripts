

IF NOT EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'KBCDB1')
BEGIN
EXEC master.dbo.sp_addlinkedserver @server = N'KBCDB1', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'kbcdb1\dc4', @catalog=N'TMIMMRDB'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'KBCDB1',@useself=N'False',@locallogin=NULL,@rmtuser=N'adworks',@rmtpassword='@dw)rks'
END
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'KBCDB1', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


IF NOT EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'MMIS')
BEGIN
EXEC master.dbo.sp_addlinkedserver @server = N'MMIS', @srvproduct=N'sql', @provider=N'SQLNCLI', @datasrc=N'dcvsql2k5d01', @catalog=N'TMIMMRDB'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'MMIS',@useself=N'False',@locallogin=NULL,@rmtuser=N'adworks',@rmtpassword='@dw)rks'
END
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'MMIS', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


