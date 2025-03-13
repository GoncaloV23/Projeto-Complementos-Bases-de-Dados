DROP DATABASE if exists WWIGlobal;
CREATE DATABASE WWIGlobal
ON PRIMARY (
    NAME = 'primary_filegroup',
    FILENAME = 'C:\sql_data\primary_filegroup.mdf',
    SIZE = 1 MB,
    FILEGROWTH = 1 MB,
	MAXSIZE = 10MB
),
FILEGROUP readOnly_filegroup
(
    NAME = 'readOnly_filegroup',
    FILENAME = 'C:\sql_data\readOnly_filegroup.ndf',
    SIZE = 10000KB
),
FILEGROUP intensive_filegroup
(
    NAME = 'intensive_filegroup',
    FILENAME = 'C:\sql_data\intensive_filegroup.ndf',
    SIZE = 10 MB,
    FILEGROWTH = 2 MB,
	MAXSIZE = 100MB
),
FILEGROUP log_filegroup 
(
    NAME = 'log_filegroup',
    FILENAME = 'C:\sql_data\log_filegroup.ndf',
    SIZE = 1 MB,
    FILEGROWTH = 1 MB,
	MAXSIZE = 10MB
)
LOG ON (
    NAME = 'log',
    FILENAME = 'C:\sql_data\log.ldf',
    SIZE = 10 MB,
    FILEGROWTH = 2 MB
)