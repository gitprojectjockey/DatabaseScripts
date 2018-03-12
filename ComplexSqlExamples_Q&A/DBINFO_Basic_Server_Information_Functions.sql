----------------------------------------------------------------------------------------------
--simple @@functions that provide basic server information.
----------------------------------------------------------------------------------------------
-- Server and instance name 
	Select @@SERVERNAME as [Server\Instance]; 
	-- SQL Server Version 
	Select @@VERSION as SQLServerVersion; 
	-- SQL Server Instance 
	Select @@ServiceName AS ServiceInstance;
	-- Current Database 
	Select DB_NAME() AS CurrentDB_Name; 
---------------------------------------------------------------------------------------------
-- this is one method to tell when the database server was last restarted
----------------------------------------------------------------------------------------------

SELECT  @@Servername AS ServerName ,
	        create_date AS ServerStarted ,
	        DATEDIFF(s, create_date, GETDATE()) / 86400.0 AS DaysRunning ,
	        DATEDIFF(s, create_date, GETDATE()) AS SecondsRunnig
	FROM    sys.databases
	WHERE   name = 'PostalService'; 
	GO
------------------------------------------------------------------------------------------------
--take inventory of all the databases found on the server.
-------------------------------------------------------------------------------------------------
EXEC sp_helpdb; 
	--OR 
	EXEC sp_Databases; 
	--OR 
	SELECT  @@SERVERNAME AS Server ,
	        name AS DBName ,
	        recovery_model_Desc AS RecoveryModel ,
	        Compatibility_level AS CompatiblityLevel ,
	        create_date ,
	        state_desc
	FROM    sys.databases
	ORDER BY Name; 
	--OR 
	SELECT  @@SERVERNAME AS Server ,
	        d.name AS DBName ,
	        create_date ,
	        compatibility_level ,
	        m.physical_name AS FileName
	FROM    sys.databases d
	        JOIN sys.master_files m ON d.database_id = m.database_id
	WHERE   m.[type] = 0 -- data files only
	ORDER BY d.name; 
	GO
--------------------------------------------------------------------------------------------------------------------
--Active User Connections by Database
--------------------------------------------------------------------------------------------------------------------
SELECT  @@Servername AS Server ,
	        DB_NAME(database_id) AS DatabaseName ,
	        COUNT(database_id) AS Connections ,
	        Login_name AS LoginName ,
	        MIN(Login_Time) AS Login_Time ,
	        MIN(COALESCE(last_request_end_time, last_request_start_time))
                                                         AS Last_Batch
	FROM    sys.dm_exec_sessions
	WHERE   database_id > 0
	        AND DB_NAME(database_id) NOT IN ( 'master', 'msdb' )
	GROUP BY database_id ,
	         login_name
	ORDER BY DatabaseName;