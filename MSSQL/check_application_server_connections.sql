SELECT hostname,
  ,loginame
  ,program_name AS App_Name
  ,db_name(dbid) AS Database_Name
FROM sys.sysprocesses
WHERE hostname != ''
