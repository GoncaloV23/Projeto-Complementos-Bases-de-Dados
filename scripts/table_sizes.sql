use WWIGlobal;
--Espaço ocupado por cada tabela com o número atual de registos
GO
DROP PROCEDURE if exists GetTableSize
GO
CREATE PROCEDURE GetTableSize
AS
BEGIN
SELECT
    t.name AS TableName,
	p.rows as RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB
FROM 
    sys.tables t
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
    INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    i.object_id > 255 
GROUP BY 
    t.name, p.rows
ORDER BY 
    TotalSpaceKB DESC
END
GO	
--Espaço ocupado por registo de cada tabela
DROP TABLE IF exists record_sizes_table
	CREATE TABLE record_sizes_table(
		Tabela  varchar(max),
		 size int
	)
DROP PROCEDURE if exists GetMaxRecordSize
GO
CREATE PROCEDURE GetMaxRecordSize(@TableName varchar(255))
AS
BEGIN
	
    DECLARE @MaxSize int
    SET @MaxSize = 0

	DECLARE @ColumnName varchar(50)
    DECLARE @ColumnSize int
    DECLARE @DataType varchar(50)

    DECLARE ColumnCursor CURSOR FOR
    SELECT name, max_length
    FROM sys.columns
    WHERE object_id = OBJECT_ID(@TableName)

    OPEN ColumnCursor
    FETCH NEXT FROM ColumnCursor INTO @ColumnName, @ColumnSize

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @MaxSize = @MaxSize + COALESCE(@ColumnSize, 0)

        FETCH NEXT FROM ColumnCursor INTO @ColumnName, @ColumnSize
    END

    CLOSE ColumnCursor
    DEALLOCATE ColumnCursor

	insert into record_sizes_table values(@TableName, @MaxSize)
END


GO
DROP PROCEDURE if exists GetAllMaxRecordSize
GO
CREATE PROCEDURE GetAllMaxRecordSize
AS
BEGIN
    DECLARE @tablename nvarchar(255)
	DECLARE @schema nvarchar(MAX)
	

	DECLARE tables_cursor CURSOR FOR
	SELECT name, SCHEMA_NAME(schema_id) FROM sys.tables

	OPEN tables_cursor

	FETCH NEXT FROM tables_cursor INTO @tablename, @schema

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @aux varchar(max)
		set @aux = @schema + '.' +@tablename
		 EXEC GetMaxRecordSize  @aux

		 FETCH NEXT FROM tables_cursor INTO @tablename,@schema
	END

	CLOSE tables_cursor
	DEALLOCATE tables_cursor
END

exec GetTableSize

exec GetAllMaxRecordSize

select * from record_sizes_table