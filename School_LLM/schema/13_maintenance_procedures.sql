CREATE PROCEDURE dbo.sp_cleanup_old_logs
    @retention_days INT = 90
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @cutoff_date DATETIME2 = DATEADD(DAY, -@retention_days, GETUTCDATE());
    
    -- Delete old integration logs
    DELETE FROM dbo.integration_logs
    WHERE created_at < @cutoff_date;
    
    -- Delete old audit logs
    DELETE FROM dbo.audit_logs
    WHERE created_at < @cutoff_date;
    
    -- Archive old notifications
    INSERT INTO dbo.archived_notifications
    SELECT *
    FROM dbo.notifications
    WHERE created_at < @cutoff_date;
    
    DELETE FROM dbo.notifications
    WHERE created_at < @cutoff_date;
END;
GO

-- Procedure for updating statistics
CREATE PROCEDURE dbo.sp_update_statistics_maintenance
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TableName NVARCHAR(128);
    DECLARE @sql NVARCHAR(500);
    
    DECLARE table_cursor CURSOR FOR
    SELECT table_name = QUOTENAME(OBJECT_SCHEMA_NAME(object_id)) + '.' + QUOTENAME(name)
    FROM sys.tables
    WHERE is_ms_shipped = 0;
    
    OPEN table_cursor;
    FETCH NEXT FROM table_cursor INTO @TableName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = N'UPDATE STATISTICS ' + @TableName + ' WITH FULLSCAN;';
        EXEC sp_executesql @sql;
        
        FETCH NEXT FROM table_cursor INTO @TableName;
    END;
    
    CLOSE table_cursor;
    DEALLOCATE table_cursor;
END;
GO 