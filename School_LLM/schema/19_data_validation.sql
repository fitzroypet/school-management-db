-- Custom Types for Data Validation
CREATE TYPE dbo.EmailAddress FROM NVARCHAR(255);
CREATE TYPE dbo.PhoneNumber FROM NVARCHAR(20);
GO

-- Validation Functions
CREATE FUNCTION dbo.fn_validate_email
(
    @email NVARCHAR(255)
)
RETURNS BIT
AS
BEGIN
    RETURN CASE 
        WHEN @email LIKE '%_@__%.__%' 
        AND PATINDEX('%[^a-z0-9@._-]%', @email) = 0 
        THEN 1 
        ELSE 0 
    END;
END;
GO

CREATE FUNCTION dbo.fn_validate_phone
(
    @phone NVARCHAR(20)
)
RETURNS BIT
AS
BEGIN
    RETURN CASE 
        WHEN @phone LIKE '[0-9+-]%'
        AND LEN(@phone) BETWEEN 10 AND 20
        THEN 1 
        ELSE 0 
    END;
END;
GO

-- Business Rules Validation Procedures
CREATE PROCEDURE dbo.sp_validate_class_capacity
    @school_id INT,
    @class_id INT
AS
BEGIN
    DECLARE @current_count INT;
    DECLARE @capacity INT;
    
    SELECT @capacity = capacity 
    FROM dbo.classes 
    WHERE class_id = @class_id AND school_id = @school_id;
    
    SELECT @current_count = COUNT(*) 
    FROM dbo.students 
    WHERE current_class_id = @class_id AND school_id = @school_id;
    
    IF @current_count >= @capacity
        THROW 50001, 'Class capacity exceeded', 1;
        
    SELECT @capacity - @current_count AS available_slots;
END;
GO

-- Subscription Limit Validation
CREATE PROCEDURE dbo.sp_validate_subscription_limits
    @school_id INT
AS
BEGIN
    DECLARE @current_students INT;
    DECLARE @current_teachers INT;
    DECLARE @max_students INT;
    DECLARE @max_teachers INT;
    
    -- Get current counts
    SELECT @current_students = COUNT(*) 
    FROM dbo.students 
    WHERE school_id = @school_id;
    
    SELECT @current_teachers = COUNT(*) 
    FROM dbo.teachers 
    WHERE school_id = @school_id;
    
    -- Get subscription limits
    SELECT 
        @max_students = sp.max_students,
        @max_teachers = sp.max_teachers
    FROM dbo.school_subscriptions ss
    JOIN dbo.subscription_plans sp ON ss.plan_id = sp.plan_id
    WHERE ss.school_id = @school_id
    AND ss.status = 'Active';
    
    -- Return validation results
    SELECT 
        CASE 
            WHEN @max_students IS NULL THEN 1
            WHEN @current_students < @max_students THEN 1
            ELSE 0
        END AS can_add_students,
        CASE 
            WHEN @max_teachers IS NULL THEN 1
            WHEN @current_teachers < @max_teachers THEN 1
            ELSE 0
        END AS can_add_teachers,
        @max_students - @current_students AS remaining_student_slots,
        @max_teachers - @current_teachers AS remaining_teacher_slots;
END;
GO

-- Data Integrity Triggers
CREATE TRIGGER trg_validate_student_insert
ON dbo.students
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate class capacity
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN dbo.classes c ON i.current_class_id = c.class_id
        JOIN (
            SELECT current_class_id, COUNT(*) as student_count
            FROM dbo.students
            GROUP BY current_class_id
        ) sc ON c.class_id = sc.current_class_id
        WHERE sc.student_count > c.capacity
    )
    BEGIN
        ROLLBACK;
        THROW 50001, 'Class capacity would be exceeded', 1;
    END
    
    -- Validate subscription limits
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN dbo.school_subscriptions ss ON i.school_id = ss.school_id
        JOIN dbo.subscription_plans sp ON ss.plan_id = sp.plan_id
        JOIN (
            SELECT school_id, COUNT(*) as student_count
            FROM dbo.students
            GROUP BY school_id
        ) sc ON i.school_id = sc.school_id
        WHERE sp.max_students IS NOT NULL 
        AND sc.student_count > sp.max_students
    )
    BEGIN
        ROLLBACK;
        THROW 50002, 'School subscription student limit would be exceeded', 1;
    END
END;
GO 