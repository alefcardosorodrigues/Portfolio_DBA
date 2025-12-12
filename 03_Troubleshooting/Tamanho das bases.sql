/*
Autor: Alef Rodrigues
Data: 2019-05-20
Descrição: Lista as bases por tamanho.
Versão: 1.0

Histórico:
1.0 - Criação do script
*/

IF OBJECT_ID('tempdb.dbo.#FileSize') IS NOT NULL
BEGIN
	DROP TABLE #FileSize;
END

CREATE TABLE #FileSize (dbName NVARCHAR(128), FileName NVARCHAR(128), type_desc NVARCHAR(128), CurrentSizeMB DECIMAL(10,2), FreeSpaceMB DECIMAL(10,2), [FreeSpace%] DECIMAL(4,2)
);
    
INSERT INTO #FileSize(dbName, FileName, type_desc, CurrentSizeMB, FreeSpaceMB, [FreeSpace%])
exec sp_msforeachdb 
'use [?]; 
 SELECT DB_NAME() AS DbName, 
        name AS FileName, 
        type_desc,
        size/128.0 AS CurrentSizeMB,  
        size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB,
		convert(decimal(4,2),((size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)*100)/(size/128.0)) AS [FreeSpace%]
FROM sys.database_files
WHERE type IN (0)';
    
SELECT DbName, [FileName], [type_desc], CurrentSizeMB, FreeSpaceMB, ROUND(CurrentSizeMB - FreeSpaceMB,0) AS UsedSpaceMB, [FreeSpace%]
, SUM(FreeSpaceMB) OVER(ORDER BY FreeSpaceMB DESC) AS [sum_FreeSpaceMB_partial]
, SUM(FreeSpaceMB) OVER(ORDER BY FreeSpaceMB DESC ROWS BETWEEN UNBOUNDED PRECEDING AND	UNBOUNDED FOLLOWING) AS [sum_FreeSpaceMB_total]
, COUNT(dbName) OVER(ORDER BY FreeSpaceMB DESC ROWS BETWEEN UNBOUNDED PRECEDING AND	UNBOUNDED FOLLOWING) AS qtde_bases
, 'USE ' + DbName + '; DBCC SHRINKFILE(''' + [FileName] + ''',' + CONVERT(VARCHAR,CONVERT(INT,ROUND((CurrentSizeMB - FreeSpaceMB)*1.1,0))) + ' );' AS cmd_shrink
FROM #FileSize
WHERE dbName NOT IN ('distribution', 'master', 'model', 'msdb', 'tempdb')
--AND CurrentSizeMB > 2048
--AND FreeSpaceMB > 1024
--AND [FreeSpace%] > 15
ORDER BY FreeSpaceMB DESC;