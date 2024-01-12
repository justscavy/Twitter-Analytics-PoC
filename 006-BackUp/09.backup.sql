--create backup for project
BACKUP DATABASE [SMA_final] 
TO DISK = N'C:\SQL-Kurs\project_right\backup\SMA_final.bak' 
WITH NOFORMAT, NOINIT,  NAME = N'FirmaUebung-Vollständig Datenbank Sichern', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10;
GO
