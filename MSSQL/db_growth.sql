----------------------------------------------------------------------
-- This will display monthly database growth based on backup size.  --
--                                                                  --
-- Created: 11/10/2021                                              --
-- Version: 1.0                                                     --
----------------------------------------------------------------------

-- This will create the BackupSize column that you will select later

WITH BackupSize AS (
SELECT TOP 1000
  rn = ROW_NUMBER() OVER(ORDER BY DATEPART(year,[backup_start_date]) ASC,
DATEPART(month,[backup_start_date]) ASC)
  ,[Year] = DATEPART(year,[backup_starT_date])
  ,[Month] = DATEPART(month,[backup_start_date])
  ,[Backup Size GB] = CONVERT(DECIMAL(10,2),ROUND(AVG([backup_size]/1024/1024/1024),4))
  ,[Compressed Backup Size GB] = CONVERT(DECIMAL(10,2),ROUND(AVG([compressed_backup_size]/1024/1024/1024),4))
FROM [msdb].[dbo].[backupset]
WHERE [database_name] = N'DATABASE_NAME' -- Put the database name
AND [Type] = 'D'
AND [backup_start_date] BETWEEN DATEADD(mm, -13, GETDATE()) AND GETDATE() --Goes back 1 year to give you the size for each month up until the current date
GROUP BY [database_name]
  ,DATEPART(yyyy,[backup_starT_date])
  ,DATEPART(mm,[backup_start_date])
ORDER BY [Year],[Month]
-- END

SELECT b.[Year]
  ,b.[Month]
  ,b.[Backup Size GB]
  ,0 AS deltaNormal
  ,b.[Compressed Backup Size GB]
  ,0 AS deltaCompressed
FROM BackupSize b
WHERE b.rn = 1
UNION
SELECT b.[Year]
  ,b.[Month]
  ,b.[Backup Size GB]
  ,b.[Backup Size GB] -d.[Backup Size GB] AS deltaNormal
  ,b.[Compressed Backup Size GB]
  ,b.[Compressed Backup Size GB] -d.[Compressed Backup Size GB] AS deltaCompressed
FROM BackupSize b
CROSS APPLY (
  SELECT bs.[Backup Size GB]
    ,bs.[Compressed Backup Size GB]
  FROM BackupSize bs
  WHERE bs.rn = b.rn - 1) AS d
  ORDER BY [Year],[Month]
