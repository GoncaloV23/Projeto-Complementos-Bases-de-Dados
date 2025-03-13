use WWIGlobal
go

DROP PROCEDURE  IF EXISTS generate_insert_sp
go
CREATE PROCEDURE generate_insert_sp (@table_name varchar(255), @schema_name varchar(255))
AS
BEGIN
    DECLARE @columns_list varchar(max),
            @params_list varchar(max),
			@params_list_value varchar(max),
            @query varchar(max);
    
    SELECT @columns_list = COALESCE(@columns_list + ', ', '') + c.name
    FROM sys.columns c
    JOIN sys.tables t ON c.object_id = t.object_id
    WHERE t.name = @table_name AND c.is_identity = 0;
    
    SELECT @params_list = COALESCE(@params_list + ', ', '') + '@' + c.name + ' ' + tp.name
    FROM sys.columns c
    JOIN sys.tables t ON c.object_id = t.object_id
    JOIN sys.types tp ON tp.user_type_id = c.user_type_id
    WHERE t.name = @table_name AND c.is_identity = 0;

	SELECT @params_list_value = COALESCE(@params_list_value + ', ', '') + '@' + c.name
    FROM sys.columns c
    JOIN sys.tables t ON c.object_id = t.object_id
    JOIN sys.types tp ON tp.user_type_id = c.user_type_id
    WHERE t.name = @table_name AND c.is_identity = 0;
    
    SET @query = 'CREATE PROCEDURE insert_' + @table_name + ' (' + @params_list + ') AS BEGIN INSERT INTO ' + @schema_name + '.' + @table_name + ' (' + @columns_list + ') VALUES (' + @params_list_value + '); END';
    
	

	DECLARE @search_string NVARCHAR(10) = 'varchar';
	DECLARE @replace_string NVARCHAR(20) = 'varchar(100)';

	WHILE CHARINDEX(@search_string, @query) > 0
	BEGIN
		SET @query = STUFF(@query, CHARINDEX(@search_string, @query), LEN(@search_string), 's_s_s');

		
	END;

	WHILE CHARINDEX('s_s_s', @query) > 0
	BEGIN
		SET @query = STUFF(@query, CHARINDEX('s_s_s', @query), LEN('s_s_s'), @replace_string);

		
	END;

	
	PRINT @query;
    EXEC (@query);
END;
go 

DROP PROCEDURE  IF EXISTS generate_update_sp
go
CREATE PROCEDURE generate_update_sp (@table_name varchar(255), @schema_name varchar(255))
AS
BEGIN
    DECLARE @columns_list varchar(max),
            @params_list varchar(max),
            @query varchar(max),
			@primary_key varchar(100);
    
    SELECT @columns_list = COALESCE(@columns_list + ', ', '') + c.name + ' = @' + c.name
    FROM sys.columns c
    JOIN sys.tables t ON c.object_id = t.object_id
    WHERE t.name = @table_name AND c.is_identity = 0;
    
    SELECT @params_list = COALESCE(@params_list + ', ', '') + '@' + c.name + ' ' + tp.name
    FROM sys.columns c
    JOIN sys.tables t ON c.object_id = t.object_id
    JOIN sys.types tp ON tp.user_type_id = c.user_type_id
    WHERE t.name = @table_name AND c.is_identity = 0;
    
	SET @primary_key = (SELECT col.name
			FROM sys.indexes idx
			JOIN sys.index_columns index_col ON idx.object_id = index_col.object_id AND idx.index_id = index_col.index_id
			JOIN sys.columns col ON index_col.object_id = col.object_id AND index_col.column_id = col.column_id
			WHERE idx.object_id = OBJECT_ID(@table_name) AND idx.is_primary_key = 1);

	DECLARE @aux varchar(20);
	SET @aux = (SELECT tp.name
			FROM sys.indexes idx
			JOIN sys.index_columns index_col ON idx.object_id = index_col.object_id AND idx.index_id = index_col.index_id
			JOIN sys.columns col ON index_col.object_id = col.object_id AND index_col.column_id = col.column_id
			JOIN sys.types tp ON tp.user_type_id = col.user_type_id
			WHERE idx.object_id = OBJECT_ID('wwiuser') AND idx.is_primary_key = 1);


    SET @query = 'CREATE PROCEDURE update_' + @table_name + ' (@' + @primary_key + ' ' + @aux + ', ' + @params_list + ') AS BEGIN UPDATE ' + @schema_name + '.' + @table_name + ' SET ' + @columns_list + ' WHERE ' + @primary_key+ ' = @' + @primary_key + '; END';
    
	DECLARE @search_string NVARCHAR(10) = 'varchar';
	DECLARE @replace_string NVARCHAR(20) = 'varchar(100)';

	WHILE CHARINDEX(@search_string, @query) > 0
	BEGIN
		SET @query = STUFF(@query, CHARINDEX(@search_string, @query), LEN(@search_string), 's_s_s');

		
	END;

	WHILE CHARINDEX('s_s_s', @query) > 0
	BEGIN
		SET @query = STUFF(@query, CHARINDEX('s_s_s', @query), LEN('s_s_s'), @replace_string);

		
	END;

	
	PRINT @query;
    EXEC (@query);
END;
go

DROP PROCEDURE  IF EXISTS generate_delete_sp
go
CREATE PROCEDURE generate_delete_sp (@table_name varchar(255), @schema_name varchar(255))
AS
BEGIN
    DECLARE @query varchar(max),
			@primary_key varchar(100);
    

	SET @primary_key = (SELECT col.name
			FROM sys.indexes idx
			JOIN sys.index_columns index_col ON idx.object_id = index_col.object_id AND idx.index_id = index_col.index_id
			JOIN sys.columns col ON index_col.object_id = col.object_id AND index_col.column_id = col.column_id
			WHERE idx.object_id = OBJECT_ID(@table_name) AND idx.is_primary_key = 1);

	DECLARE @aux varchar(20);
	SET @aux = (SELECT tp.name
			FROM sys.indexes idx
			JOIN sys.index_columns index_col ON idx.object_id = index_col.object_id AND idx.index_id = index_col.index_id
			JOIN sys.columns col ON index_col.object_id = col.object_id AND index_col.column_id = col.column_id
			JOIN sys.types tp ON tp.user_type_id = col.user_type_id
			WHERE idx.object_id = OBJECT_ID('wwiuser') AND idx.is_primary_key = 1);

    SET @query = 'CREATE PROCEDURE delete_' + @table_name + ' (@'+ @primary_key + ' ' + @aux + ') AS BEGIN DELETE FROM ' + @schema_name + '.' + @table_name + ' WHERE ' + @primary_key+ ' = @' + @primary_key + '; END';
    
	DECLARE @search_string NVARCHAR(10) = 'varchar';
	DECLARE @replace_string NVARCHAR(20) = 'varchar(100)';

	WHILE CHARINDEX(@search_string, @query) > 0
	BEGIN
		SET @query = STUFF(@query, CHARINDEX(@search_string, @query), LEN(@search_string), 's_s_s');

		
	END;

	WHILE CHARINDEX('s_s_s', @query) > 0
	BEGIN
		SET @query = STUFF(@query, CHARINDEX('s_s_s', @query), LEN('s_s_s'), @replace_string);

		
	END;

	
	PRINT @query;
    EXEC (@query);
END;
go

DROP PROCEDURE  IF EXISTS GenerateStoredProcedures
go
CREATE PROCEDURE GenerateStoredProcedures
AS
BEGIN
	EXEC generate_insert_sp 'wwiuser', 'users';
	EXEC generate_update_sp 'wwiuser', 'users';
	EXEC generate_delete_sp 'wwiuser', 'users';

	EXEC generate_insert_sp 'token', 'users';

	EXEC generate_insert_sp 'promotion', 'sales';
	EXEC generate_update_sp 'promotion', 'sales';
	EXEC generate_delete_sp 'promotion', 'sales';
	
	EXEC generate_insert_sp 'stock_promotion', 'sales';
END;
go
EXEC GenerateStoredProcedures
go

DROP PROCEDURE  IF EXISTS sp_generate_table_info
go
CREATE PROCEDURE sp_generate_table_info
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @table_name SYSNAME,
            @column_name SYSNAME,
            @data_type VARCHAR(50),
            @character_maximum_length INT,
            @is_nullable VARCHAR(3),
            @constraint_type VARCHAR(50),
            @constraint_name SYSNAME;
    
    DECLARE cursor_tables CURSOR FOR
    SELECT name
    FROM sys.tables;
    
    OPEN cursor_tables;
    
    FETCH NEXT FROM cursor_tables INTO @table_name;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE cursor_columns CURSOR FOR
        SELECT c.name, t.name, c.max_length, c.is_nullable,
               k.type_desc, k.name
        FROM sys.columns c
        JOIN sys.types t ON c.user_type_id = t.user_type_id
        LEFT JOIN sys.key_constraints k ON c.object_id = k.parent_object_id
                                         AND c.column_id = k.unique_index_id
        WHERE c.object_id = OBJECT_ID(@table_name);
        
        OPEN cursor_columns;
        
        FETCH NEXT FROM cursor_columns INTO @column_name, @data_type,
                                           @character_maximum_length,
                                           @is_nullable, @constraint_type,
                                           @constraint_name;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO logs.table_info (tablee_info_name,
						tablee_info_column_name ,
						tablee_info_column_data_type ,
						tablee_info_column_maximum_length ,
						tablee_info_column_is_nullable ,
						tablee_info_column_constraint_type ,
						tablee_info_column_constraint_name )
            VALUES (@table_name, @column_name, @data_type,
                    @character_maximum_length, @is_nullable,
                    @constraint_type, @constraint_name);
            
            FETCH NEXT FROM cursor_columns INTO @column_name, @data_type,
                                               @character_maximum_length,
                                               @is_nullable,
                                               @constraint_type,
                                               @constraint_name;
        END;
        
        CLOSE cursor_columns;
        DEALLOCATE cursor_columns;
        
        FETCH NEXT FROM cursor_tables INTO @table_name;
    END;
    
    CLOSE cursor_tables;
    DEALLOCATE cursor_tables;
END;
go

DROP PROCEDURE  IF EXISTS sp_TableStats
go
CREATE PROCEDURE sp_TableStats
AS
BEGIN
   SET NOCOUNT ON;
   
   DECLARE @table_name sysname;
   DECLARE @row_count int;
   DECLARE @reserved_size_mb float;
   DECLARE @unused_size_mb float;
   
   DECLARE cursor_tables CURSOR FOR
   SELECT name 
   FROM sys.tables;
   
   OPEN cursor_tables;
   FETCH NEXT FROM cursor_tables INTO @table_name;
   
   WHILE @@FETCH_STATUS = 0
   BEGIN
      EXEC sp_spaceused @table_name, @row_count OUTPUT, @reserved_size_mb OUTPUT, @unused_size_mb OUTPUT;
      
      INSERT INTO logs.TableStats (TableStats_table_name,
							TableStats_row_count,
							TableStats_reserved_size_mb,
							TableStats_unused_size_mb,
							TableStats_stats_date)
      VALUES (@table_name, @row_count, @reserved_size_mb, @unused_size_mb, GETDATE());
      
      FETCH NEXT FROM cursor_tables INTO @table_name;
   END;
   
   CLOSE cursor_tables;
   DEALLOCATE cursor_tables;
END;