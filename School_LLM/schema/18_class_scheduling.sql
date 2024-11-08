-- Create Class Schedule
CREATE PROCEDURE dbo.sp_create_class_schedule
    @school_id INT,
    @class_id INT,
    @academic_year_id INT,
    @schedule_items dbo.ScheduleItemType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate schedule conflicts
        ;WITH schedule_conflicts AS (
            SELECT 
                si.day_of_week,
                si.start_time,
                si.end_time,
                COUNT(*) as conflict_count
            FROM @schedule_items si
            GROUP BY si.day_of_week, si.start_time, si.end_time
            HAVING COUNT(*) > 1
        )
        SELECT * FROM schedule_conflictsS
        IF EXISTS (SELECT 1 FROM schedule_conflicts)
        BEGIN
            RAISERROR('Schedule has time conflicts', 16, 1);
            RETURN;
        END

        -- Create schedule
        INSERT INTO dbo.class_schedules (
            school_id, class_id, academic_year_id,
            subject_id, teacher_id, day_of_week,
            start_time, end_time, room_number
        )
        SELECT 
            @school_id,
            @class_id,
            @academic_year_id,
            si.subject_id,
            si.teacher_id,
            si.day_of_week,
            si.start_time,
            si.end_time,
            si.room_number
        FROM @schedule_items si;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Get Class Schedule
CREATE PROCEDURE dbo.sp_get_class_schedule
    @school_id INT,
    @class_id INT,
    @academic_year_id INT
AS
BEGIN
    SELECT 
        cs.day_of_week,
        cs.start_time,
        cs.end_time,
        s.subject_name,
        t.first_name + ' ' + t.last_name AS teacher_name,
        cs.room_number
    FROM dbo.class_schedules cs
    JOIN dbo.subjects s ON cs.subject_id = s.subject_id
    JOIN dbo.teachers t ON cs.teacher_id = t.teacher_id
    WHERE cs.school_id = @school_id
    AND cs.class_id = @class_id
    AND cs.academic_year_id = @academic_year_id
    ORDER BY 
        cs.day_of_week,
        cs.start_time;
END;
GO 