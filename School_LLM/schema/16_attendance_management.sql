-- Record Daily Attendance
CREATE PROCEDURE dbo.sp_record_attendance
    @school_id INT,
    @class_id INT,
    @date DATE,
    @marked_by INT,
    @attendance_records dbo.AttendanceRecordType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate if attendance already exists
        IF EXISTS (
            SELECT 1 FROM dbo.attendance 
            WHERE school_id = @school_id 
            AND class_id = @class_id 
            AND date = @date
        )
        BEGIN
            RAISERROR('Attendance for this class and date already exists', 16, 1);
            RETURN;
        END

        -- Record attendance
        INSERT INTO dbo.attendance (
            school_id, student_id, class_id, date, 
            status, reason, marked_by, created_at
        )
        SELECT 
            @school_id,
            ar.student_id,
            @class_id,
            @date,
            ar.status,
            ar.reason,
            @marked_by,
            GETUTCDATE()
        FROM @attendance_records ar;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Get Attendance Report
CREATE PROCEDURE dbo.sp_get_attendance_report
    @school_id INT,
    @class_id INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SELECT 
        s.admission_number,
        s.first_name + ' ' + s.last_name AS student_name,
        COUNT(*) AS total_days,
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS days_present,
        SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS days_absent,
        SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS days_late,
        CAST(SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS attendance_percentage
    FROM dbo.students s
    LEFT JOIN dbo.attendance a ON s.student_id = a.student_id
        AND a.date BETWEEN @start_date AND @end_date
    WHERE s.school_id = @school_id
    AND s.current_class_id = @class_id
    GROUP BY s.admission_number, s.first_name, s.last_name;
END;
GO 